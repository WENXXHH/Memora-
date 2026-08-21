"""AI 助记请求 / 响应 Schema。

按文档 20 + 第五周开发指南 §二-2.6 定义：
- 请求：word / meaning / example / feedback_type
- 响应：Server-Sent Events 流式文本（不是普通 JSON）
"""

from pydantic import BaseModel, Field


class MnemonicStreamRequest(BaseModel):
    """AI 助记流式生成请求。"""

    word: str = Field(..., min_length=1, max_length=200, description="单词")
    meaning: str = Field(..., min_length=1, description="释义")
    example: str | None = Field(None, description="例句")
    feedback_type: str = Field(
        "unknown",
        description="学习反馈类型：known / fuzzy / unknown",
    )
