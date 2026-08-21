"""幂等 Seed：内置词库与单词。

按第五周开发指南 §二-2.4 + 文档 4 §1 实现：
- 按 name='CET-6' AND is_builtin=True 查找，不存在才插
- 不依赖"数据库是否为空"判断，未来用户表有数据但词库表为空时也能正确 seed
- 运行十次数据库里仍然只有一套数据

数据来源：backend/data/cet-6.json（从 Flutter assets 复制，后端独立读自己的资源）
"""

import json
from pathlib import Path

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.word_book import WordBook
from app.models.word import Word

DATA_FILE = Path(__file__).resolve().parent.parent.parent / "data" / "cet-6.json"


def _flatten_meaning(meaning_list: list) -> str:
    """把 meaning 数组拼成 `pos. def1; def2; def3 | pos. ...` 文本。

    输入示例：
        [{"pos": "v.", "definitions": ["放弃", "抛弃"]},
         {"pos": "n.", "definitions": ["放纵"]}]

    输出示例：
        "v. 放弃; 抛弃 | n. 放纵"
    """
    if not meaning_list:
        return ""
    parts = []
    for entry in meaning_list:
        pos = entry.get("pos", "")
        defs = entry.get("definitions", [])
        if defs:
            parts.append(f"{pos} {'; '.join(defs)}")
    return " | ".join(parts)


def _flatten_example(example_list: list) -> str:
    """把 example 数组拼成换行分隔文本。"""
    if not example_list:
        return None
    return "\n".join(example_list)


def seed_builtin_word_books() -> tuple[int, int]:
    """Seed 内置 CET-6 词库与其下 200 单词。

    返回 (word_books_inserted, words_inserted)。
    幂等：第二次运行返回 (0, 0)。
    """
    if not DATA_FILE.exists():
        raise FileNotFoundError(f"Seed 数据文件不存在: {DATA_FILE}")

    with open(DATA_FILE, encoding="utf-8") as f:
        words_data = json.load(f)

    db: Session = SessionLocal()
    try:
        # 按稳定业务键查找：name='CET-6' AND is_builtin=True
        stmt = select(WordBook).where(
            WordBook.name == "CET-6",
            WordBook.is_builtin.is_(True),
        )
        existing = db.execute(stmt).scalar_one_or_none()
        if existing is not None:
            # 已存在，幂等返回
            return 0, 0

        # 创建词库
        book = WordBook(
            name="CET-6",
            description="大学英语六级核心词汇（200 词）",
            owner_user_id=None,  # NULL = 系统内置
            is_builtin=True,
        )
        db.add(book)
        db.flush()  # 拿到 book.id

        # 批量插入单词
        word_objs = []
        for item in words_data:
            word_objs.append(Word(
                word_book_id=book.id,
                text=item["word"],
                phonetic=item.get("phonetic"),
                meaning=_flatten_meaning(item.get("meaning", [])),
                example=_flatten_example(item.get("example", [])),
            ))
        db.add_all(word_objs)
        db.commit()
        return 1, len(word_objs)
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def run_seed_if_needed() -> None:
    """启动时调用：幂等 seed 内置词库。

    main.py 在 create_all 之后调用。
    """
    books, words = seed_builtin_word_books()
    if books > 0:
        print(f"[seed] 插入 {books} 个内置词库 + {words} 个单词")
    else:
        # 静默跳过，避免每次启动刷屏
        pass
