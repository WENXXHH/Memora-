"""认证端点端到端测试。

覆盖《第五周最常见的 Bug.md》关键场景：
- Bug 1：数据库不能出现明文密码
- Bug 2：JWT 能生成且受保护接口能识别
- Bug 6：用户隔离（虽然 records 隔离在第二天实现，这里先验证 /auth/me 返回当前用户）

使用 FastAPI TestClient + 临时 SQLite 数据库，不污染 memora.db。
"""

from __future__ import annotations

import os
import tempfile

import jwt
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

# 必须在 import app.main 之前设置 JWT_SECRET，否则 get_jwt_secret() 会抛错
os.environ["JWT_SECRET"] = "test-secret-for-pytest-only"

from app.core.config import settings  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.session import get_session  # noqa: E402
from app.main import app  # noqa: E402


@pytest.fixture(scope="function")
def client() -> TestClient:
    """每个测试函数独立内存 SQLite 数据库，互不污染。"""
    # StaticPool + in-memory：同一内存连接跨多个 Session 共享
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

    def override_get_session():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_session] = override_get_session
    yield TestClient(app)
    app.dependency_overrides.clear()


# ---- Bug 1 防御：响应不含密码 / 数据库存哈希 ----

def test_register_returns_no_password_fields(client: TestClient) -> None:
    """注册响应绝不含 password / password_hash。"""
    response = client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "secret123"},
    )
    assert response.status_code == 201
    body = response.json()
    assert "password" not in body
    assert "password_hash" not in body
    assert body["username"] == "alice"
    assert body["email"] == "alice@example.com"
    assert body["id"] == 1


def test_register_does_not_store_plaintext(client: TestClient) -> None:
    """数据库 password_hash 字段不能是明文密码。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": "bob", "email": "bob@example.com", "password": "secret123"},
    )
    # 直接查 DB 验证不是明文
    from app.db.session import get_session
    from app.models.user import User

    # 拿到测试用的 Session（通过 override）
    db_gen = app.dependency_overrides[get_session]()
    db = next(db_gen)
    try:
        user = db.query(User).filter_by(username="bob").one()
        assert user.password_hash != "secret123"
        # Argon2 哈希有特征（$argon2id$）
        assert "argon2" in user.password_hash.lower() or "$" in user.password_hash
    finally:
        db.close()


# ---- Bug 2 防御：JWT 生成 + 受保护接口能识别 ----

def _register_and_login(client: TestClient, username: str = "alice", password: str = "secret123") -> str:
    """工具：注册并登录，返回 access_token。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": username, "email": f"{username}@example.com", "password": password},
    )
    response = client.post(
        "/api/v1/auth/login",
        json={"username": username, "password": password},
    )
    assert response.status_code == 200
    return response.json()["access_token"]


def test_login_returns_jwt_with_user(client: TestClient) -> None:
    """登录返回 JWT + user 字段。"""
    token = _register_and_login(client)
    # JWT 三段 . 分隔
    assert token.count(".") == 2
    response = client.post(
        "/api/v1/auth/login",
        json={"username": "alice", "password": "secret123"},
    )
    body = response.json()
    assert body["token_type"] == "bearer"
    assert body["user"]["username"] == "alice"
    assert "password" not in body["user"]


def test_protected_me_with_valid_token(client: TestClient) -> None:
    """GET /auth/me 用合法 Token 能返回当前用户。"""
    token = _register_and_login(client)
    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    assert response.json()["username"] == "alice"


def test_protected_me_without_token_returns_401(client: TestClient) -> None:
    """GET /auth/me 不带 Token 返回 401。"""
    response = client.get("/api/v1/auth/me")
    assert response.status_code == 401


def test_protected_me_with_invalid_token_returns_401(client: TestClient) -> None:
    """GET /auth/me 用非法 Token 返回 401。"""
    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer not-a-valid-jwt"},
    )
    assert response.status_code == 401


def test_protected_me_with_tampered_token_returns_401(client: TestClient) -> None:
    """GET /auth/me 用签名被篡改的 Token 返回 401。"""
    token = _register_and_login(client)
    # 篡改 payload 但保留签名（应该验证失败）
    parts = token.split(".")
    # 修改 payload 部分
    import base64
    import json

    payload_bytes = parts[1].encode() + b"=="  # base64 padding
    payload = json.loads(base64.urlsafe_b64decode(payload_bytes))
    payload["sub"] = "999"  # 改成不存在的 user_id
    new_payload = base64.urlsafe_b64encode(json.dumps(payload).encode()).rstrip(b"=").decode()
    tampered = f"{parts[0]}.{new_payload}.{parts[2]}"
    response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {tampered}"},
    )
    assert response.status_code == 401


def test_login_with_wrong_password_returns_401(client: TestClient) -> None:
    """登录密码错误返回 401。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "secret123"},
    )
    response = client.post(
        "/api/v1/auth/login",
        json={"username": "alice", "password": "wrong-password"},
    )
    assert response.status_code == 401


def test_login_with_nonexistent_user_returns_401(client: TestClient) -> None:
    """登录不存在的用户返回 401（与密码错误返回相同状态码，防用户名枚举）。"""
    response = client.post(
        "/api/v1/auth/login",
        json={"username": "ghost", "password": "whatever"},
    )
    assert response.status_code == 401


# ---- Bug 6 防御：当前用户由 Token 决定 ----

def test_me_returns_only_token_owner(client: TestClient) -> None:
    """两个用户登录各自 Token，/auth/me 返回对应用户。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "secret123"},
    )
    client.post(
        "/api/v1/auth/register",
        json={"username": "bob", "email": "bob@example.com", "password": "secret456"},
    )
    alice_token = _register_and_login(client, "alice", "secret123")
    bob_token = _register_and_login(client, "bob", "secret456")

    r1 = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {alice_token}"})
    assert r1.json()["username"] == "alice"
    r2 = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {bob_token}"})
    assert r2.json()["username"] == "bob"


# ---- 重复注册返回 409 ----

def test_register_duplicate_username_returns_409(client: TestClient) -> None:
    """重复用户名返回 409。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "secret123"},
    )
    response = client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice2@example.com", "password": "secret123"},
    )
    assert response.status_code == 409


def test_register_duplicate_email_returns_409(client: TestClient) -> None:
    """重复邮箱返回 409。"""
    client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "secret123"},
    )
    response = client.post(
        "/api/v1/auth/register",
        json={"username": "alice2", "email": "alice@example.com", "password": "secret123"},
    )
    assert response.status_code == 409


# ---- 客户端校验只是改善体验，服务端必须重新验证 ----

def test_register_short_password_returns_422(client: TestClient) -> None:
    """密码长度 < 6 由 Pydantic 在 Schema 层拦截（422）。"""
    response = client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "alice@example.com", "password": "12345"},
    )
    assert response.status_code == 422


def test_register_invalid_email_returns_422(client: TestClient) -> None:
    """邮箱格式不合法由 EmailStr 拦截。"""
    response = client.post(
        "/api/v1/auth/register",
        json={"username": "alice", "email": "not-an-email", "password": "secret123"},
    )
    assert response.status_code == 422
