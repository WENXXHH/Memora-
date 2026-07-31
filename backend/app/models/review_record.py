"""复习记录 ORM 模型。

一对一关系：同一用户在同一词库中对同一单词只有一条当前复习记录。
字段覆盖 SM-2 算法全部参数，另加同步时间戳。
"""

from datetime import datetime

from sqlalchemy import Boolean, Float, ForeignKey, Integer, UniqueConstraint, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class ReviewRecord(Base):
    __tablename__ = "review_records"

    __table_args__ = (
        UniqueConstraint(
            "user_id", "word_book_id", "word_id",
            name="uq_user_wordbook_word",
        ),
    )

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    word_book_id: Mapped[int] = mapped_column(
        ForeignKey("word_books.id"), nullable=False
    )
    word_id: Mapped[int] = mapped_column(ForeignKey("words.id"), nullable=False)

    # SM-2 算法核心参数
    repetition_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    easiness_factor: Mapped[float] = mapped_column(Float, default=2.5, nullable=False)
    interval: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    next_review_at: Mapped[datetime] = mapped_column(nullable=False)
    last_review_at: Mapped[datetime | None]

    learned: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    mastery: Mapped[float] = mapped_column(Float, default=0.0, nullable=False)

    # 同步时间戳
    client_updated_at: Mapped[datetime] = mapped_column(nullable=False)
    server_updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), nullable=False
    )
