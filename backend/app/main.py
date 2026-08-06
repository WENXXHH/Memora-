"""Memora 后端主入口。

启动方式：
    cd backend
    uvicorn app.main:app --reload

调试：
    访问 http://localhost:8000/health  → {"status": "ok"}
    访问 http://localhost:8000/docs     → Swagger 交互文档
"""

from fastapi import FastAPI

from app.core.config import API_TITLE, API_VERSION, API_DESCRIPTION
from app.db.base import Base
from app.db.session import engine
from app.routers import auth, words, records, ai

# 建表（第四周：SQLite 文件创建时自动执行）
# 注意：表结构变更后需先删除 memora.db 再重启
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=API_TITLE,
    version=API_VERSION,
    description=API_DESCRIPTION,
)

# 注册路由，统一前缀 /api/v1
app.include_router(auth.router, prefix="/api/v1")
app.include_router(words.router, prefix="/api/v1")
app.include_router(records.router, prefix="/api/v1")
app.include_router(ai.router, prefix="/api/v1")


@app.get("/health")
def health() -> dict[str, str]:
    """健康检查端点。"""
    return {"status": "ok"}
