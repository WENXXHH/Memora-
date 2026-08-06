"""数据库引擎与会话工厂。

- engine：SQLAlchemy 引擎，第四周使用同步 SQLite
- get_session：生成一个新的 Session 实例
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.core.config import DATABASE_URL

engine = create_engine(
    DATABASE_URL,
    echo=False,          # 生产环境关闭 SQL 日志
    connect_args={"check_same_thread": False},  # SQLite 多线程兼容
)


def get_session() -> Session:
    """获取同步数据库会话。"""
    return Session(engine)
