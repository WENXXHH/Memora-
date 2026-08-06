"""学习记录路由 — 第四周返回 Mock 数据。"""

from datetime import datetime, timezone

from fastapi import APIRouter

from app.schemas.review_record import (
    ReviewRecordSyncRequest,
    ReviewRecordSyncResponse,
)

router = APIRouter(prefix="/records", tags=["Records"])


@router.get("", response_model=ReviewRecordSyncResponse)
def get_records() -> ReviewRecordSyncResponse:
    """拉取学习记录 — Mock only。

    第四周：返回空列表与服务器时间。
    第六周：根据 user_id 查询该用户所有记录并返回。
    """
    return ReviewRecordSyncResponse(
        records=[],
        server_time=datetime.now(timezone.utc),
    )


@router.post("/sync", response_model=ReviewRecordSyncResponse)
def sync_records(body: ReviewRecordSyncRequest) -> ReviewRecordSyncResponse:
    """批量同步学习记录 — Mock only。

    第四周：不写入数据库，仅返回请求体中的记录 + 服务器时间。
    第六周：实现时间戳合并策略（server_updated_at 取最大），写 DB → 返回合并结果。
    """
    return ReviewRecordSyncResponse(
        records=body.records,
        server_time=datetime.now(timezone.utc),
    )
