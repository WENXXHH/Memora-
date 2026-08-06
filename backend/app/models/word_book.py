"""词库 ORM 模型。

支持 系统内置词库 和 用户自建词库 两种类型。
内置词库 owner_user_id 为 NULL，由系统统一管理。
"""

from datetime import datetime

from sqlalchemy import Boolean, ForeignKey, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class WordBook(Base):
    __tablename__ = "word_books"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[str | None] = mapped_column(String(500))
    # NULL 表示系统内置词库，非 NULL 表示该用户的自建词库
    owner_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"))
    is_builtin: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now(), nullable=False
    )
