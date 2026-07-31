"""Memora 后端全局配置。

当前采用简单常量方式；后续可迁移至 pydantic-settings。
"""

# SQLite 数据库路径（相对于 backend/ 目录）
DATABASE_URL: str = "sqlite:///./memora.db"

# API 元信息
API_TITLE: str = "Memora API"
API_VERSION: str = "0.1.0"
API_DESCRIPTION: str = "Memora 单词背诵 App 后端服务 — 当前为骨架/Mock 阶段"
