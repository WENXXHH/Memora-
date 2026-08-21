"""AI 流式接口测试。

覆盖关键场景：
- 401 防御：未登录返回 401
- SSE 流：返回 text/event-stream，含多个 data: 帧 + [DONE]
- Bug 12 防御：中文输出不乱码（每帧是完整 UTF-8 文本，不出现半个汉字）
- FakeAiProvider 确定性：同输入同输出
"""

from __future__ import annotations

import os

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


def _register_and_login(client: TestClient, username: str = "alice") -> str:
    client.post(
        "/api/v1/auth/register",
        json={"username": username, "email": f"{username}@example.com", "password": "secret123"},
    )
    return client.post(
        "/api/v1/auth/login",
        json={"username": username, "password": "secret123"},
    ).json()["access_token"]


def _auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# ---- 401 防御 ----

def test_ai_stream_without_token_returns_401(client: TestClient) -> None:
    response = client.post(
        "/api/v1/ai/mnemonic/stream",
        json={"word": "abandon", "meaning": "放弃"},
    )
    assert response.status_code == 401


# ---- SSE 流格式 ----

def test_ai_stream_returns_sse_format(client: TestClient) -> None:
    """返回 Content-Type: text/event-stream，且含 [DONE] 结束标记。"""
    token = _register_and_login(client)
    with client.stream(
        "POST",
        "/api/v1/ai/mnemonic/stream",
        headers=_auth_headers(token),
        json={"word": "abandon", "meaning": "放弃", "example": "He abandoned it.", "feedback_type": "unknown"},
    ) as response:
        assert response.status_code == 200
        assert "text/event-stream" in response.headers.get("content-type", "")

        body = b""
        for chunk in response.iter_bytes():
            body += chunk
        text = body.decode("utf-8")

        # 应包含多个 data: 行
        assert text.count("data: ") >= 3
        # 应以 [DONE] 结束
        assert "data: [DONE]" in text
        # 应含输入的 word / meaning
        assert "abandon" in text
        assert "放弃" in text


# ---- Bug 12 防御：中文不乱码 ----

def test_ai_stream_chinese_not_garbled(client: TestClient) -> None:
    """中文输出完整 UTF-8 文本，每个 data: 行后是一个完整字符序列。"""
    token = _register_and_login(client)
    with client.stream(
        "POST",
        "/api/v1/ai/mnemonic/stream",
        headers=_auth_headers(token),
        json={"word": "abandon", "meaning": "放弃；抛弃"},
    ) as response:
        body = b"".join(response.iter_bytes())
        text = body.decode("utf-8")

        # 整体能完整 UTF-8 解码（不会 UnicodeDecodeError）
        assert isinstance(text, str)
        # 中文字符完整出现
        assert "放弃" in text
        assert "；" in text or "抛弃" in text


# ---- FakeAiProvider 确定性 ----

def test_ai_stream_deterministic(client: TestClient) -> None:
    """同输入两次请求，输出文本一致（FakeAiProvider 确定性）。"""
    token = _register_and_login(client)
    request_body = {"word": "test", "meaning": "测试", "feedback_type": "fuzzy"}

    texts = []
    for _ in range(2):
        with client.stream(
            "POST",
            "/api/v1/ai/mnemonic/stream",
            headers=_auth_headers(token),
            json=request_body,
        ) as response:
            body = b"".join(response.iter_bytes()).decode("utf-8")
            texts.append(body)

    assert texts[0] == texts[1]


# ---- 请求体校验 ----

def test_ai_stream_empty_word_returns_422(client: TestClient) -> None:
    """word 为空字符串 → 422（Pydantic min_length=1）。"""
    token = _register_and_login(client)
    response = client.post(
        "/api/v1/ai/mnemonic/stream",
        headers=_auth_headers(token),
        json={"word": "", "meaning": "测试"},
    )
    assert response.status_code == 422
