"""数据库引擎与会话工厂。

- engine：SQLAlchemy 引擎，使用同步 SQLite
- get_session：FastAPI 依赖注入标准写法（生成器），保证每次请求独立 Session + rollback 路径
"""

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    echo=False,
    connect_args={"check_same_thread": False},  # SQLite 多线程兼容
)

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)


def get_session() -> Generator[Session, None, None]:
    """FastAPI 依赖注入：每次请求独立 Session，请求结束自动关闭。

    使用方式：`db: Session = Depends(get_session)`
    Service 层负责 commit / rollback，本函数只负责开/关 Session。
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
