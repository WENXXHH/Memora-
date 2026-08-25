"""词库与单词端点测试。

覆盖关键场景：
- Bug 6 防御：用户 A 看不到用户 B 的自建词库（本测试先建内置词库，用户都能看）
- 内置词库所有登录用户都能访问
- 不存在词库 404
- Seed 后 GET /word-books 至少返回 1 个 CET-6 词库
- GET /word-books/{id}/words 返回 200 个 CET-6 单词
"""

from __future__ import annotations

import os
import tempfile

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
from app.models.word import Word  # noqa: E402
from app.models.word_book import WordBook  # noqa: E402


@pytest.fixture(scope="function")
def client() -> TestClient:
    """每个测试函数独立内存 SQLite + Seed。"""
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

    # 注入测试 Session 给 seed
    import app.db.seed as seed_mod
    original_session_local = seed_mod.SessionLocal
    seed_mod.SessionLocal = TestingSessionLocal
    run_seed_if_needed()
    seed_mod.SessionLocal = original_session_local

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
    response = client.post(
        "/api/v1/auth/login",
        json={"username": username, "password": password},
    )
    return response.json()["access_token"]


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# ---- Seed 后内置词库可见 ----

def test_list_word_books_returns_builtin_cet6(client: TestClient) -> None:
    """Seed 后任意登录用户能 GET 到 CET-6 内置词库。"""
    token = _register_and_login(client, "alice")
    response = client.get("/api/v1/word-books", headers=_auth_headers(token))
    assert response.status_code == 200
    books = response.json()
    assert len(books) >= 1
    cet6 = next((b for b in books if b["name"] == "CET-6"), None)
    assert cet6 is not None
    assert cet6["is_builtin"] is True
    assert cet6["owner_user_id"] is None


def test_list_words_returns_200_cet6_words(client: TestClient) -> None:
    """CET-6 词库下应返回 200 个单词。"""
    token = _register_and_login(client, "alice")
    books = client.get("/api/v1/word-books", headers=_auth_headers(token)).json()
    cet6_id = next(b["id"] for b in books if b["name"] == "CET-6")

    response = client.get(f"/api/v1/word-books/{cet6_id}/words", headers=_auth_headers(token))
    assert response.status_code == 200
    words = response.json()
    assert len(words) == 200
    assert words[0]["text"] == "abandon"
    assert words[-1]["text"] == "carbon"
    # 验证 meaning 字段已 flatten
    assert "放弃" in words[0]["meaning"]


# ---- 第二内置词库 CET-4（doc 39）----


def test_list_word_books_returns_builtin_cet4(client: TestClient) -> None:
    """Seed 后 GET /word-books 同时返回 CET-6 与 CET-4，CET-4 为内置词库。"""
    token = _register_and_login(client, "alice")
    response = client.get("/api/v1/word-books", headers=_auth_headers(token))
    assert response.status_code == 200
    books = response.json()

    names = {b["name"] for b in books}
    assert "CET-6" in names
    assert "CET-4" in names

    cet4 = next(b for b in books if b["name"] == "CET-4")
    assert cet4["is_builtin"] is True
    assert cet4["owner_user_id"] is None


def test_list_words_returns_200_cet4_words(client: TestClient) -> None:
    """CET-4 词库下应返回 200 个单词，文本与 Flutter cet-4.json 同源。"""
    token = _register_and_login(client, "alice")
    books = client.get("/api/v1/word-books", headers=_auth_headers(token)).json()
    cet4_id = next(b["id"] for b in books if b["name"] == "CET-4")

    response = client.get(f"/api/v1/word-books/{cet4_id}/words", headers=_auth_headers(token))
    assert response.status_code == 200
    words = response.json()
    assert len(words) == 200
    assert words[0]["text"] == "abandon"
    # 验证 meaning 字段已 flatten
    assert "放弃" in words[0]["meaning"]


def test_seed_builtin_word_books_is_idempotent() -> None:
    """seed 重复运行不重复插入（Bug 6 防御）：第二次返回 (0,0)。"""
    from sqlalchemy import create_engine, func, select
    from sqlalchemy.orm import sessionmaker
    from sqlalchemy.pool import StaticPool

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
    try:
        first = seed_mod.seed_builtin_word_books()
        second = seed_mod.seed_builtin_word_books()
    finally:
        seed_mod.SessionLocal = original

    # 第一次插入 2 词库 + 400 词；第二次幂等返回 0
    assert first == (2, 400)
    assert second == (0, 0)

    with TestingSessionLocal() as db:
        book_count = db.execute(select(func.count()).select_from(WordBook)).scalar_one()
        word_count = db.execute(select(func.count()).select_from(Word)).scalar_one()
    assert book_count == 2
    assert word_count == 400


# ---- 权限：未登录访问 → 401 ----

def test_list_word_books_without_token_returns_401(client: TestClient) -> None:
    response = client.get("/api/v1/word-books")
    assert response.status_code == 401


def test_list_words_without_token_returns_401(client: TestClient) -> None:
    response = client.get("/api/v1/word-books/1/words")
    assert response.status_code == 401


# ---- 不存在词库 → 404 ----

def test_list_words_nonexistent_book_returns_404(client: TestClient) -> None:
    token = _register_and_login(client, "alice")
    response = client.get("/api/v1/word-books/9999/words", headers=_auth_headers(token))
    assert response.status_code == 404


# ---- Bug 6 防御：内置词库所有登录用户都能访问 ----

def test_builtin_book_accessible_to_all_users(client: TestClient) -> None:
    """两个用户都能访问 CET-6 内置词库。"""
    alice_token = _register_and_login(client, "alice")
    bob_token = _register_and_login(client, "bob")

    # alice 和 bob 都能看到 CET-6
    for token in (alice_token, bob_token):
        books = client.get("/api/v1/word-books", headers=_auth_headers(token)).json()
        assert any(b["name"] == "CET-6" for b in books)
