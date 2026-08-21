"""学习记录路由 — 第五周真实实现（替换 Mock）。

按第五周开发指南 §二-2.4 + 文档 5：
- GET /records：按 current_user.id 过滤，可选 word_book_id / updated_after
- POST /records/sync：不存在 INSERT / 已存在覆盖，不实现冲突合并
- 客户端不上传 user_id，由 Token 决定（请求体 Schema 已不含 user_id）

原则 6：当前用户由 Token 决定。
原则 8：每次请求独立 Session + rollback。
Bug 6 防御：用户 A 读不到用户 B 的记录。
Bug 7 防御：3D 唯一约束 + 事务 rollback，重复上传不重复行。
"""

from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db.session import get_session
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.review_record import (
    ReviewRecordSyncItem,
    ReviewRecordSyncRequest,
    ReviewRecordSyncResponse,
)
from app.services.review_record_service import ReviewRecordService

router = APIRouter(prefix="/records", tags=["Records"])


def _to_sync_item(record) -> ReviewRecordSyncItem:
    """ORM → Pydantic 同步项。

    不含 user_id：响应中不暴露 user_id，由 Token 决定当前用户。
    """
    return ReviewRecordSyncItem(
        word_book_id=record.word_book_id,
        word_id=record.word_id,
        repetition_count=record.repetition_count,
        easiness_factor=record.easiness_factor,
        interval=record.interval,
        next_review_at=record.next_review_at,
        last_review_at=record.last_review_at,
        learned=record.learned,
        mastery=record.mastery,
        client_updated_at=record.client_updated_at,
    )


@router.get("", response_model=ReviewRecordSyncResponse)
def get_records(
    word_book_id: Annotated[int | None, Query(description="按词库过滤")] = None,
    updated_after: Annotated[datetime | None, Query(description="增量同步游标（第六周实现真正合并）")] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session),
) -> ReviewRecordSyncResponse:
    """拉取当前用户的全部学习记录。

    第五周：按 current_user.id 过滤，可选 word_book_id / updated_after。
    第六周：updated_after 实现真正的时间戳合并。
    """
    service = ReviewRecordService(db)
    records = service.list_records(
        current_user_id=current_user.id,
        word_book_id=word_book_id,
        updated_after=updated_after,
    )
    return ReviewRecordSyncResponse(
        records=[_to_sync_item(r) for r in records],
        server_time=datetime.now(timezone.utc),
    )


@router.post("/sync", response_model=ReviewRecordSyncResponse)
def sync_records(
    body: ReviewRecordSyncRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session),
) -> ReviewRecordSyncResponse:
    """批量同步学习记录。

    第五周规则：
    - 不存在 → INSERT（user_id 由 Token 决定，不由请求体决定）
    - 已存在 → 用本次上传值覆盖（不实现 client_updated_at 冲突合并）
    - 整批一个事务，失败 rollback
    - 重复上传不会创建重复行（依赖 3D 唯一约束）

    第六周：实现 client_updated_at / server_updated_at 取最大值合并。
    """
    service = ReviewRecordService(db)
    service.upsert_records(body.records, current_user_id=current_user.id)

    # 返回当前用户全部记录 + server_time，让客户端拉一次拿全状态
    all_records = service.list_records(current_user_id=current_user.id)
    return ReviewRecordSyncResponse(
        records=[_to_sync_item(r) for r in all_records],
        server_time=datetime.now(timezone.utc),
    )
