"""单词 / 词库相关 Pydantic Schema。"""

from pydantic import BaseModel


class WordBookResponse(BaseModel):
    """词库信息响应。"""

    id: int
    name: str
    description: str | None = None
    is_builtin: bool
    owner_user_id: int | None = None


class WordResponse(BaseModel):
    """单词信息响应。"""

    id: int
    word_book_id: int
    text: str
    phonetic: str | None = None
    meaning: str
    example: str | None = None
