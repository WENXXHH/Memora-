"""单词/词库路由 — 第五周真实实现（替换 Mock）。

按第五周开发指南 §二-2.6：
- 词库列表：内置 + 当前用户自建（is_builtin OR owner_user_id == current_user.id）
- 单词列表：先校验词库可见性，再返回该词库全部单词

原则 6：当前用户由 Token 决定，所有可见性判断用 current_user.id。
Bug 6 防御：用户 A 看不到用户 B 的自建词库。
"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_session
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.word import WordBookResponse, WordResponse
from app.services.word_service import WordService

router = APIRouter(prefix="/word-books", tags=["Words"])


def _to_book_response(book) -> WordBookResponse:
    return WordBookResponse(
        id=book.id,
        name=book.name,
        description=book.description,
        is_builtin=book.is_builtin,
        owner_user_id=book.owner_user_id,
    )


def _to_word_response(word) -> WordResponse:
    return WordResponse(
        id=word.id,
        word_book_id=word.word_book_id,
        text=word.text,
        phonetic=word.phonetic,
        meaning=word.meaning,
        example=word.example,
    )


@router.get("", response_model=list[WordBookResponse])
def list_word_books(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session),
) -> list[WordBookResponse]:
    """获取当前用户可见的词库列表。

    返回：内置词库 + 当前用户自建词库。
    其他用户的自建词库不可见。
    """
    service = WordService(db)
    books = service.list_word_books(current_user.id)
    return [_to_book_response(b) for b in books]


@router.get("/{book_id}/words", response_model=list[WordResponse])
def list_words(
    book_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session),
) -> list[WordResponse]:
    """获取指定词库的全部单词。

    - 词库不存在 → 404
    - 内置词库 → 任意登录用户可访问
    - 用户自建词库 → 仅 owner 可访问，他人访问统一返回 404（不暴露存在性）
    """
    service = WordService(db)
    words = service.list_words(book_id, current_user.id)
    return [_to_word_response(w) for w in words]
