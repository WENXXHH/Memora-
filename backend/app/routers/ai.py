"""AI 助记路由 — 第五周 StreamingResponse SSE 实现（替换 501 占位）。

按第五周开发指南 §二-2.6 + 文档 20：
- 用 FastAPI 0.121 的 StreamingResponse 手搓 SSE（不升级框架）
- 帧格式：`data: 文本片段\n\n` ... `data: [DONE]\n\n`
- 后端 AiService + Provider 抽象，API Key 只在后端环境变量（原则 20）
- 第五周用 FakeAiProvider，第六周换 HttpAiProvider 时本路由零改动

Bug 12 防御：SSE 帧按空行分帧，UTF-8 字符在 Python str 层面已解码完成，
不会出现"半个汉字"问题（StreamingResponse 内部按 bytes 输出，但每个 yield 是完整 str）。
"""

from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.db.session import get_session
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.ai import MnemonicStreamRequest
from app.services.ai_service import AiService

router = APIRouter(prefix="/ai", tags=["AI"])

# AiService 是无状态的，模块级单例即可（FakeAiProvider 无需 DI）
_ai_service = AiService()


@router.post("/mnemonic/stream")
def generate_mnemonic_stream(
    body: MnemonicStreamRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session),  # noqa: ARG001 — 预留第六周调用日志/扣额度
) -> StreamingResponse:
    """AI 助记流式生成 — Server-Sent Events。

    响应 Content-Type: text/event-stream
    帧格式：
        data: 文本行
        <空行>
        data: 下一行
        <空行>
        data: [DONE]
        <空行>

    第五周使用 FakeAiProvider 输出确定性文本；第六周替换为真实 LLM 时
    只需替换 AiService 内部 Provider，本路由不变。
    """
    generator = _ai_service.stream_sse(body)
    return StreamingResponse(
        generator,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  # 关闭 nginx 缓冲，保证流式
        },
    )
