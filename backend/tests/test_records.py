"""学习记录端点测试。

覆盖关键场景：
- Bug 6 防御：用户 A 读不到用户 B 的记录
- Bug 7 防御：重复上传不创建重复行
- upsert：不存在 INSERT / 已存在覆盖
- user_id 由 Token 决定，不由请求体决定
"""

from __future__ import annotations

import os
from datetime import datetime, timezone

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

os.environ["JWT_SECRET"] = "test-secret-for-pytest-only"

from app.db.base import Base  # noqa: E402
from app.db.session import get_session  # noqa: E402
from app.db.seed import run_seed_if_needed  # noqa: E402
from app.main import app  # noqa: E402


@pytest.fixture(scope="function")
def client() -> TestClient:
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

    import app.db.seed as seed_mod
    original = seed_mod.SessionLocal
    seed_mod.SessionLocal = TestingSessionLocal
    run_seed_if_needed()
    seed_mod.SessionLocal = original

    def override_get_session():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_session] = override_get_session
    yield TestClient(app)
    app.dependency_overrides.clear()


def _register_and_login(client: TestClient, username: str, password: str = "secret123") -> str:
    client.post(
        "/api/v1/auth/register",
        json={"username": username, "email": f"{username}@example.com", "password": password},
    )
    return client.post(
        "/api/v1/auth/login",
        json={"username": username, "password": password},
    ).json()["access_token"]


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


def _make_record_item(
    word_book_id: int = 1,
    word_id: int = 1,
    *,
    repetition_count: int = 1,
    easiness_factor: float = 2.6,
    interval: int = 1,
    learned: bool = False,
    mastery: float = 0.0,
) -> dict:
    """构造一条 ReviewRecordSyncItem 字典。"""
    now = datetime.now(timezone.utc).isoformat()
    return {
        "word_book_id": word_book_id,
        "word_id": word_id,
        "repetition_count": repetition_count,
        "easiness_factor": easiness_factor,
        "interval": interval,
        "next_review_at": now,
        "last_review_at": now,
        "learned": learned,
        "mastery": mastery,
        "client_updated_at": now,
    }


# ---- Bug 6 防御：用户隔离 ----

def test_user_a_cannot_read_user_b_records(client: TestClient) -> None:
    """Alice 上传记录，Bob GET /records 看不到。"""
    alice_token = _register_and_login(client, "alice")
    bob_token = _register_and_login(client, "bob")

    # Alice 上传 1 条记录
    item = _make_record_item(word_book_id=1, word_id=1)
    client.post(
        "/api/v1/records/sync",
        headers=_auth_headers(alice_token),
        json={"records": [item]},
    )

    # Alice 自己能看到
    alice_records = client.get(
        "/api/v1/records", headers=_auth_headers(alice_token)
    ).json()["records"]
    assert any(r["word_id"] == 1 for r in alice_records)

    # Bob 看不到 Alice 的记录
    bob_records = client.get(
        "/api/v1/records", headers=_auth_headers(bob_token)
    ).json()["records"]
    assert all(r["word_id"] != 1 for r in bob_records)


# ---- Bug 7 防御：重复上传不创建重复行 ----

def test_repeated_upload_does_not_duplicate(client: TestClient) -> None:
    """同一记录重复上传 N 次，数据库仍只有 1 行。"""
    token = _register_and_login(client, "alice")
    item = _make_record_item(word_book_id=1, word_id=1, repetition_count=1)

    # 上传 3 次
    for _ in range(3):
        client.post(
            "/api/v1/records/sync",
            headers=_auth_headers(token),
            json={"records": [item]},
        )

    records = client.get(
        "/api/v1/records", headers=_auth_headers(token)
    ).json()["records"]
    matching = [r for r in records if r["word_id"] == 1 and r["word_book_id"] == 1]
    assert len(matching) == 1


# ---- upsert：不存在 INSERT / 已存在覆盖 ----

def test_upsert_insert_then_update(client: TestClient) -> None:
    """第一次 INSERT，第二次覆盖（更新字段值）。"""
    token = _register_and_login(client, "alice")

    # 第一次：repetition_count=1
    item_v1 = _make_record_item(word_book_id=1, word_id=1, repetition_count=1, mastery=0.0)
    r1 = client.post(
        "/api/v1/records/sync",
        headers=_auth_headers(token),
        json={"records": [item_v1]},
    )
    assert r1.status_code == 200

    # 第二次：repetition_count=3, mastery=0.5（覆盖）
    item_v2 = _make_record_item(word_book_id=1, word_id=1, repetition_count=3, mastery=0.5)
    r2 = client.post(
        "/api/v1/records/sync",
        headers=_auth_headers(token),
        json={"records": [item_v2]},
    )
    assert r2.status_code == 200

    records = r2.json()["records"]
    matching = next(r for r in records if r["word_id"] == 1 and r["word_book_id"] == 1)
    assert matching["repetition_count"] == 3
    assert matching["mastery"] == 0.5


# ---- word_book_id 过滤 ----

def test_get_records_filtered_by_word_book(client: TestClient) -> None:
    """word_book_id 查询参数过滤。"""
    token = _register_and_login(client, "alice")

    # 上传 book 1 word 1 + book 1 word 2
    items = [
        _make_record_item(word_book_id=1, word_id=1),
        _make_record_item(word_book_id=1, word_id=2),
    ]
    client.post(
        "/api/v1/records/sync",
        headers=_auth_headers(token),
        json={"records": items},
    )

    # 查询 book 1
    response = client.get(
        "/api/v1/records?word_book_id=1",
        headers=_auth_headers(token),
    )
    assert response.status_code == 200
    records = response.json()["records"]
    assert len(records) == 2
    assert all(r["word_book_id"] == 1 for r in records)


# ---- 未登录 → 401 ----

def test_get_records_without_token_returns_401(client: TestClient) -> None:
    response = client.get("/api/v1/records")
    assert response.status_code == 401


def test_sync_records_without_token_returns_401(client: TestClient) -> None:
    response = client.post(
        "/api/v1/records/sync",
        json={"records": []},
    )
    assert response.status_code == 401


# ---- 空批量上传 ----

def test_sync_empty_records_returns_empty_list(client: TestClient) -> None:
    """上传空 list 不报错，返回空记录列表。"""
    token = _register_and_login(client, "alice")
    response = client.post(
        "/api/v1/records/sync",
        headers=_auth_headers(token),
        json={"records": []},
    )
    assert response.status_code == 200
    assert response.json()["records"] == []
