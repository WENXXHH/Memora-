"""认证服务 —— 业务逻辑层。

职责：注册/登录业务编排，含哈希、JWT、重复检查、dummy hash 防时序攻击。
不含 HTTP 异常（由 Router 层转 HTTP），不含数据库直接操作（由 UserService）。

按第五周开发指南 §二-2.2 + 文档 3 实现。
"""

from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password_or_dummy,
)
from app.models.user import User
from app.services.user_service import UserService


class AuthError(Exception):
    """认证业务错误基类。"""


class UsernameAlreadyExistsError(AuthError):
    """用户名已被注册。"""


class EmailAlreadyExistsError(AuthError):
    """邮箱已被注册。"""


class InvalidCredentialsError(AuthError):
    """用户名或密码错误。

    不区分"用户不存在"与"密码错误"，避免用户名枚举。
    """


class AuthService:
    """认证业务编排。"""

    def __init__(self, db: Session) -> None:
        self.db = db
        self.user_service = UserService(db)

    def register(
        self,
        *,
        username: str,
        email: str,
        password: str,
    ) -> User:
        """注册新用户。

        流程：
          1. 用户名重复 → 409
          2. 邮箱重复 → 409
          3. 哈希密码
          4. 创建用户
          5. 返回 User（不含 password_hash，由 Pydantic UserResponse 过滤）

        原则 6：user_id 不由客户端决定，但注册场景没有"当前用户"概念，
        所以无需 Token，user_id 由数据库自增。
        """
        # 重复检查
        if self.user_service.get_by_username(username):
            raise UsernameAlreadyExistsError(f"用户名已存在: {username}")
        if self.user_service.get_by_email(email):
            raise EmailAlreadyExistsError(f"邮箱已注册: {email}")

        # 哈希密码（原则 3：不保存明文）
        hashed = hash_password(password)

        # 创建用户
        return self.user_service.create(
            username=username,
            email=email,
            password_hash=hashed,
        )

    def authenticate(self, *, username: str, password: str) -> User:
        """登录校验。

        流程：
          1. 查用户
          2. 用户不存在 → 做 dummy hash 验证（防时序攻击）→ 抛 InvalidCredentials
          3. 密码不匹配 → 抛 InvalidCredentials
          4. 返回 User

        dummy hash 的意义：让"用户不存在"和"密码错误"两条路径耗时接近，
        避免攻击者通过响应时间差异判断用户名是否注册。
        """
        user = self.user_service.get_by_username(username)

        # 即使 user 为 None 也做一次 dummy 验证
        is_valid = verify_password_or_dummy(
            password,
            user.password_hash if user else None,
        )
        if not is_valid or user is None:
            raise InvalidCredentialsError("用户名或密码错误")

        return user

    def create_token_for(self, user: User) -> str:
        """为指定用户签发 JWT。"""
        return create_access_token(user_id=user.id)
