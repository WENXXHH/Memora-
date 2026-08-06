"""单词/词库路由 — 第四周返回 Mock 数据。"""

from fastapi import APIRouter

from app.schemas.word import WordBookResponse, WordResponse

router = APIRouter(prefix="/word-books", tags=["Words"])


_MOCK_BOOKS = [
    WordBookResponse(id=1, name="CET-6", description="大学英语六级核心词汇", is_builtin=True),
    WordBookResponse(id=2, name="CET-4", description="大学英语四级核心词汇", is_builtin=True),
    WordBookResponse(id=3, name="My Words", description="我的自定义词库", is_builtin=False, owner_user_id=1),
]

_MOCK_WORDS = [
    WordResponse(id=1, word_book_id=1, text="abandon", phonetic="/əˈbændən/", meaning="v. 放弃；抛弃", example="He abandoned the plan."),
    WordResponse(id=2, word_book_id=1, text="ability", phonetic="/əˈbɪləti/", meaning="n. 能力；才能", example="She has the ability to learn fast."),
    WordResponse(id=3, word_book_id=1, text="access", phonetic="/ˈækses/", meaning="n. 通道；入口 v. 访问；获取", example="You need a password to access the system."),
    WordResponse(id=4, word_book_id=1, text="accurate", phonetic="/ˈækjərət/", meaning="adj. 准确的；精确的", example="The data is accurate and reliable."),
    WordResponse(id=5, word_book_id=1, text="achieve", phonetic="/əˈtʃiːv/", meaning="v. 实现；达到；完成", example="She worked hard to achieve her goal."),
]


@router.get("", response_model=list[WordBookResponse])
def list_word_books() -> list[WordBookResponse]:
    """获取词库列表 — Mock only。"""
    return _MOCK_BOOKS


@router.get("/{book_id}/words", response_model=list[WordResponse])
def list_words(book_id: int) -> list[WordResponse]:
    """获取指定词库的单词列表 — Mock only。"""
    return [w for w in _MOCK_WORDS if w.word_book_id == book_id]
