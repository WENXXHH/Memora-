"""SQLAlchemy 声明式基类。

所有 ORM 模型均继承自 Base。
参见 SQLAlchemy 2.x DeclarativeBase 官方推荐写法。
"""

from sqlalchemy.orm import DeclarativeBase


class Base(DeclarativeBase):
    pass
