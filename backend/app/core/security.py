"""密码哈希与 JWT 工具。

原则 3：新项目优先使用 Argon2，不保存明文密码。
原则 4：JWT 是签名，不是加密，不能存敏感信息。
原则 5：Secret 只来自环境变量，不进入 Git。

独立模块，不依赖 FastAPI / HTTPException，便于单元测试覆盖。
"""

from datetime import datetime, timedelta, timezone
from typing import Any

import jwt
from pydantic import BaseModel
from pwdlib import PasswordHash

from app.core.config import get_jwt_secret, settings

# pwdlib 推荐哈希器：默认 Argon2id
_password_hasher = PasswordHash.recommended()

# 占位哈希：用于用户不存在时的 dummy 验证，避免时序攻击暴露"用户是否存在"
# 启动时计算一次固定哈希，登录失败路径用同一个哈希做无意义验证
_DUMMY_HASH = _password_hasher.hash("dummy-password-for-timing-attack-defense")


def hash_password(password: str) -> str:
    """对明文密码做 Argon2 哈希。

    同一密码每次哈希结果不同（Argon2 内置随机盐），验证时用 verify_password。
    """
    return _password_hasher.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """校验明文密码与已存哈希是否匹配。"""
    try:
        return _password_hasher.verify(plain_password, hashed_password)
    except Exception:
        # 哈希格式损坏等异常一律视为验证失败，不暴露内部错误
        return False


def verify_password_or_dummy(plain_password: str, hashed_password: str | None) -> bool:
    """校验密码，hashed_password 为 None 时做 dummy 哈希验证防时序攻击。

    用于登录流程：用户不存在时也执行一次假验证，避免"用户存在/不存在"
    两种请求时间差异被用于用户名枚举攻击。
    """
    target_hash = hashed_password if hashed_password else _DUMMY_HASH
    return verify_password(plain_password, target_hash)


def create_access_token(
    user_id: int,
    expires_days: int | None = None,
) -> str:
    """签发 JWT。

    载荷只含 sub(user_id) + iat + exp，绝不放 password_hash 或敏感信息。
    """
    days = expires_days if expires_days is not None else settings.JWT_EXPIRE_DAYS
    now = datetime.now(timezone.utc)
    payload: dict[str, Any] = {
        "sub": str(user_id),
        "iat": now,
        "exp": now + timedelta(days=days),
    }
    return jwt.encode(payload, get_jwt_secret(), algorithm=settings.JWT_ALGORITHM)


def decode_access_token(token: str) -> dict[str, Any]:
    """解析并校验 JWT。

    抛出 jwt.PyJWTError 子类异常（ExpiredSignatureError / InvalidTokenError 等），
    调用方（dependencies/auth.py）负责转成 HTTP 401。
    """
    return jwt.decode(
        token,
        get_jwt_secret(),
        algorithms=[settings.JWT_ALGORITHM],
    )


class TokenData(BaseModel):
    """JWT 解析后的载荷，仅含 sub。

    sub 在 JWT 中是字符串，这里转成 int 方便后续查 User。
    """

    user_id: int

    @classmethod
    def from_payload(cls, payload: dict[str, Any]) -> "TokenData":
        sub = payload.get("sub")
        if sub is None:
            raise ValueError("JWT 缺少 sub 字段")
        try:
            user_id = int(sub)
        except (TypeError, ValueError) as e:
            raise ValueError(f"JWT sub 不是合法用户 ID: {sub}") from e
        return cls(user_id=user_id)
