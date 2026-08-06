"""单词 ORM 模型。

一对多关系：一个词库拥有多个单词。
meaning 和 example 当前以纯文本存储，暂不拆分为结构化 JSON。
"""

from datetime import datetime

from sqlalchemy import ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Word(Base):
    __tablename__ = "words"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    word_book_id: Mapped[int] = mapped_column(
        ForeignKey("word_books.id"), nullable=False
    )
    text: Mapped[str] = mapped_column(String(200), nullable=False)
    phonetic: Mapped[str | None] = mapped_column(String(200))
    meaning: Mapped[str] = mapped_column(Text, nullable=False)
    example: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now(), nullable=False
    )
