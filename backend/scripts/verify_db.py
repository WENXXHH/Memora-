"""数据库连接验证脚本。

运行方式（在 backend/ 目录下）：
    python -m scripts.verify_db

验证内容：
    1. 引擎连接成功
    2. 四张表均已建好
    3. 每张表可插入/查询/回滚
"""

import sys
from pathlib import Path

# 将 backend/ 目录加入 Python path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.db.base import Base
from app.db.session import engine, get_session
from app.models.user import User
from app.models.word_book import WordBook
from app.models.word import Word
from app.models.review_record import ReviewRecord
from datetime import datetime, timezone


def verify() -> None:
    print("=" * 50)
    print("Memora DB 连接验证")
    print("=" * 50)

    # 1. 建表
    print("\n[1/4] 建表...")
    Base.metadata.create_all(bind=engine)
    table_names = Base.metadata.tables.keys()
    print(f"  已建表: {', '.join(sorted(table_names))}")
    assert len(list(table_names)) >= 4, f"缺少表！当前{len(list(table_names))}张"

    # 2. 连接
    print("\n[2/4] 数据库连接...")
    from sqlalchemy import text
    session = get_session()
    try:
        session.execute(text("SELECT 1"))
        print("  连接成功 ✓")
    except Exception as e:
        print(f"  连接失败 ❌: {e}")
        return

    # 3. 插入测试数据
    print("\n[3/4] 插入测试数据...")
    try:
        now = datetime.now(timezone.utc)

        user = User(username="test_user", email="test@memora.dev", password_hash="test_hash")
        session.add(user)
        session.flush()
        print(f"  User 插入成功 (id={user.id})")

        book = WordBook(name="Test Book", is_builtin=True)
        session.add(book)
        session.flush()
        print(f"  WordBook 插入成功 (id={book.id})")

        word = Word(word_book_id=book.id, text="test", meaning="测试")
        session.add(word)
        session.flush()
        print(f"  Word 插入成功 (id={word.id})")

        record = ReviewRecord(
            user_id=user.id,
            word_book_id=book.id,
            word_id=word.id,
            repetition_count=0,
            easiness_factor=2.5,
            interval=0,
            next_review_at=now,
            learned=False,
            mastery=0.0,
            client_updated_at=now,
        )
        session.add(record)
        session.flush()
        print(f"  ReviewRecord 插入成功 (id={record.id})")

        # 4. 查询与回滚
        print("\n[4/4] 查询并回滚（不污染数据库）...")
        user_count = session.query(User).count()
        book_count = session.query(WordBook).count()
        word_count = session.query(Word).count()
        record_count = session.query(ReviewRecord).count()
        print(f"  users          : {user_count}")
        print(f"  word_books     : {book_count}")
        print(f"  words          : {word_count}")
        print(f"  review_records : {record_count}")

        session.rollback()
        print("  回滚完成 ✓")

    except Exception as e:
        session.rollback()
        print(f"  错误 ❌: {e}")
        raise
    finally:
        session.close()

    print("\n" + "=" * 50)
    print("验证通过 ✓ — 建表/连接/CRUD/回滚 全部正常")
    print("=" * 50)


if __name__ == "__main__":
    verify()
