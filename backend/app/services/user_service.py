"""用户服务 —— 数据库操作层。

按第五周开发指南 §三-3.4：只引入 services/ 层，省略 repositories/，
由 Service 直接用 Session 查询。

职责：纯数据库操作，不含哈希/JWT/HTTPException。
"""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.user import User


class UserService:
    """用户数据库操作。"""

    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_id(self, user_id: int) -> User | None:
        """按主键查询用户。"""
        return self.db.get(User, user_id)

    def get_by_username(self, username: str) -> User | None:
        """按用户名查询用户。"""
        stmt = select(User).where(User.username == username)
        return self.db.execute(stmt).scalar_one_or_none()

    def get_by_email(self, email: str) -> User | None:
        """按邮箱查询用户。"""
        stmt = select(User).where(User.email == email)
        return self.db.execute(stmt).scalar_one_or_none()

    def create(
        self,
        *,
        username: str,
        email: str,
        password_hash: str,
    ) -> User:
        """创建新用户。

        password_hash 由调用方（AuthService）做哈希后传入，本方法不做哈希。
        """
        user = User(
            username=username,
            email=email,
            password_hash=password_hash,
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
