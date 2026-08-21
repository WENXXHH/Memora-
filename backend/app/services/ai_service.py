"""AI 助记服务 —— Provider 抽象 + Fake 实现。

按第五周开发指南 §二-2.6 + 文档 20：
- 后端分层：Router → AiService → AiProvider 接口 → HttpAiProvider → 外部 API
- API Key 只存在后端环境变量（原则 20：真实 AI 只是普通流式文本接口）
- 第五周先实现 FakeAiProvider（确定性输出），第六周再换 HttpAiProvider

SSE 帧格式（FastAPI 0.121 用 StreamingResponse 手搓，不升级框架）：
    data: 文本片段\n\n
    ...
    data: [DONE]\n\n
"""

from collections.abc import Generator

from app.schemas.ai import MnemonicStreamRequest


class AiProvider:
    """AI Provider 抽象接口。"""

    def stream_mnemonic(self, request: MnemonicStreamRequest) -> Generator[str, None, None]:
        """逐块返回助记文本片段。

        每块是纯文本（不含 `data: ` 前缀），由 AiService 包装成 SSE 帧。
        """
        raise NotImplementedError


class FakeAiProvider(AiProvider):
    """确定性 Fake Provider —— 第五周开发期使用。

    输出格式固定，按 feedback_type 略微调整结尾，便于测试可重复。
    模拟真实 AI 的"联想 + 拆解 + 例句"三段式结构。
    """

    def stream_mnemonic(self, request: MnemonicStreamRequest) -> Generator[str, None, None]:
        word = request.word
        meaning = request.meaning
        example = request.example or "（暂无例句）"
        feedback = request.feedback_type

        # 三段式助记文本，按块 yield
        blocks = [
            f"联想：{word}\n",
            f"  含义是「{meaning}」。\n",
            "  可以拆分成更小的部分来记忆：\n",
            f"  - {word} 的首字母与「{meaning[:1] if meaning else '？'}」关联；\n",
            "  - 反复出现于六级阅读理解场景。\n",
            "\n",
            f"例句：{example}\n",
            "\n",
            f"反馈类型：{feedback}。建议下次复习间隔参考 SM-2 算法。\n",
        ]

        for block in blocks:
            yield block


class AiService:
    """AI 助记业务编排。

    当前注入 FakeAiProvider；第六周换成 HttpAiProvider 时本类零改动。
    """

    def __init__(self, provider: AiProvider | None = None) -> None:
        self._provider = provider or FakeAiProvider()

    def stream_sse(self, request: MnemonicStreamRequest) -> Generator[str, None, None]:
        """逐块返回 SSE 帧（`data: ...\n\n`）。

        最后追加 `data: [DONE]\n\n` 标记流结束。
        """
        for chunk in self._provider.stream_mnemonic(request):
            # SSE 帧：每块文本按行分割成独立的 data: 行
            # 按 SSE 规范，单帧内的换行用多个 data: 行表示
            for line in chunk.split("\n"):
                yield f"data: {line}\n"
            yield "\n"  # 空行分隔帧
        yield "data: [DONE]\n\n"
