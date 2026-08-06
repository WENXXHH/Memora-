"""AI 助记路由 — 第四周仅预留接口桩，第五周接入真实服务。"""

from fastapi import APIRouter
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/ai", tags=["AI"])


@router.post("/mnemonic/stream")
async def generate_mnemonic_stream() -> JSONResponse:
    """AI 助记流式生成 — Not implemented。

    第四周：返回 501，表示尚未实现。
    第五周：根据请求体中的单词/例句/反馈类型，调用 AI 服务 → 流式返回助记文本。

    请求体（第五周定义）：
    {
      "word": "abandon",
      "meaning": "放弃；抛弃",
      "example": "He abandoned the plan.",
      "feedback_type": "unknown"
    }

    响应（Server-Sent Events 流）：
    data: 联想：abandon
    data:  可以拆分记忆...
    data: [DONE]
    """
    return JSONResponse(
        status_code=501,
        content={
            "detail": "Not implemented — 第5周实现 AI 流式助记功能",
            "planned_version": "0.2.0",
        },
    )
