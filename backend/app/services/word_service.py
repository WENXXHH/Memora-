"""词库与单词服务 —— 数据库操作 + 业务规则。

按第五周开发指南 §二-2.6：
- 词库列表规则：is_builtin == True OR owner_user_id == current_user.id
- 单词列表检查顺序：词库存在 → 当前用户可访问 → 查询该词库单词 → 返回

原则 6：当前用户由 Token 决定，所有可见性判断都用 current_user.id。
原则 7：Service 处理业务（含可见性校验）+ 数据库操作。
Bug 6 防御：所有查询都按 current_user.id 过滤。
"""

from fastapi import HTTPException, status
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.models.word import Word
from app.models.word_book import WordBook


class WordService:
    """词库与单词数据库操作。"""

    def __init__(self, db: Session) -> None:
        self.db = db

    # ---- 词库 ----

    def list_word_books(self, current_user_id: int) -> list[WordBook]:
        """列出当前用户可见的词库：内置 + 自己创建的。

        规则：is_builtin == True OR owner_user_id == current_user.id
        """
        stmt = select(WordBook).where(
            or_(
                WordBook.is_builtin.is_(True),
                WordBook.owner_user_id == current_user_id,
            )
        ).order_by(WordBook.id)
        return list(self.db.execute(stmt).scalars().all())

    def get_word_book(self, book_id: int, current_user_id: int) -> WordBook:
        """获取词库并校验当前用户可访问。

        - 不存在 → 404
        - 内置词库 → 任意登录用户可访问
        - 用户词库 → 仅 owner_user_id == current_user.id 可访问
        """
        book = self.db.get(WordBook, book_id)
        if book is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"词库不存在: id={book_id}",
            )
        # 权限校验
        if not book.is_builtin and book.owner_user_id != current_user_id:
            # 不暴露"存在但无权"，统一返回 404 避免信息泄露
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"词库不存在: id={book_id}",
            )
        return book

    # ---- 单词 ----

    def list_words(
        self,
        book_id: int,
        current_user_id: int,
    ) -> list[Word]:
        """列出指定词库的全部单词。

        先校验词库存在 + 用户可访问，再查询单词。
        """
        # 复用 get_word_book 做存在 + 权限校验
        self.get_word_book(book_id, current_user_id)

        stmt = select(Word).where(Word.word_book_id == book_id).order_by(Word.id)
        return list(self.db.execute(stmt).scalars().all())
