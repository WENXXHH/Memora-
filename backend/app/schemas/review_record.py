"""学习记录同步相关 Pydantic Schema。

覆盖 SM-2 算法全部参数，为第六周多设备同步预留。
"""

from datetime import datetime

from pydantic import BaseModel


class ReviewRecordSyncItem(BaseModel):
    """单条学习记录同步项。

    字段对应 Flutter WordReview 模型 (camelCase)，
    Pydantic 默认使用 alias 自动将 snake_case 映射到 camelCase。
    """

    word_book_id: int
    word_id: int
    repetition_count: int
    easiness_factor: float
    interval: int
    next_review_at: datetime
    last_review_at: datetime | None = None
    learned: bool
    mastery: float
    client_updated_at: datetime


class ReviewRecordSyncRequest(BaseModel):
    """批量同步请求体。"""

    records: list[ReviewRecordSyncItem]


class ReviewRecordSyncResponse(BaseModel):
    """批量同步响应体。"""

    records: list[ReviewRecordSyncItem]
    server_time: datetime
