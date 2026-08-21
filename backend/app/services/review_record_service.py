"""学习记录服务 —— 数据库操作 + 业务规则。

按第五周开发指南 §二-2.4 + 文档 5：
- GET /records：按 current_user.id 过滤，可选 word_book_id / updated_after
- POST /records/sync：不存在 INSERT / 已存在覆盖（不实现冲突合并）
- 客户端不上传 user_id，由 Token 决定 current_user.id
- 第五周不实现多设备时间戳合并（留到第六周）

原则 6：当前用户由 Token 决定，user_id 一律从 current_user.id 取，忽略请求体里的 user_id。
原则 8：每次请求独立 Session + rollback 路径。
Bug 6 防御：所有查询都按 current_user.id 过滤。
Bug 7 防御：依赖 3D 唯一约束 + 事务 rollback，重复上传不创建重复行。
"""

from datetime import datetime, timezone

from sqlalchemy import and_, select
from sqlalchemy.orm import Session

from app.models.review_record import ReviewRecord
from app.schemas.review_record import ReviewRecordSyncItem


class ReviewRecordService:
    """学习记录数据库操作。"""

    def __init__(self, db: Session) -> None:
        self.db = db

    def list_records(
        self,
        current_user_id: int,
        word_book_id: int | None = None,
        updated_after: datetime | None = None,
    ) -> list[ReviewRecord]:
        """拉取当前用户的全部学习记录。

        - 必按 current_user.id 过滤（Bug 6 防御）
        - 可选 word_book_id 过滤
        - 可选 updated_after 过滤（增量同步预留，第六周实现真正合并）
        """
        conditions = [ReviewRecord.user_id == current_user_id]
        if word_book_id is not None:
            conditions.append(ReviewRecord.word_book_id == word_book_id)
        if updated_after is not None:
            conditions.append(ReviewRecord.server_updated_at > updated_after)

        stmt = select(ReviewRecord).where(and_(*conditions)).order_by(ReviewRecord.id)
        return list(self.db.execute(stmt).scalars().all())

    def upsert_records(
        self,
        items: list[ReviewRecordSyncItem],
        current_user_id: int,
    ) -> list[ReviewRecord]:
        """批量 upsert：不存在 INSERT / 已存在覆盖。

        - user_id 一律从 current_user.id 取（即便请求体里有 user_id 也忽略，Bug 6/原则 6）
        - 依赖数据库 (user_id, word_book_id, word_id) 3D 唯一约束防重复（Bug 7）
        - 整批一个事务，失败 rollback（原则 8）
        - 不做 client_updated_at / server_updated_at 冲突合并（第五周只覆盖）
        """
        now = datetime.now(timezone.utc)
        results: list[ReviewRecord] = []

        for item in items:
            # 按 3D 唯一约束查找现有记录
            stmt = select(ReviewRecord).where(
                ReviewRecord.user_id == current_user_id,
                ReviewRecord.word_book_id == item.word_book_id,
                ReviewRecord.word_id == item.word_id,
            )
            existing = self.db.execute(stmt).scalar_one_or_none()

            if existing is None:
                # INSERT：user_id 由 Token 决定，不由客户端提供
                record = ReviewRecord(
                    user_id=current_user_id,
                    word_book_id=item.word_book_id,
                    word_id=item.word_id,
                    repetition_count=item.repetition_count,
                    easiness_factor=item.easiness_factor,
                    interval=item.interval,
                    next_review_at=item.next_review_at,
                    last_review_at=item.last_review_at,
                    learned=item.learned,
                    mastery=item.mastery,
                    client_updated_at=item.client_updated_at,
                    server_updated_at=now,
                )
                self.db.add(record)
            else:
                # 覆盖：第五周不实现冲突合并，直接用本次上传值覆盖
                existing.repetition_count = item.repetition_count
                existing.easiness_factor = item.easiness_factor
                existing.interval = item.interval
                existing.next_review_at = item.next_review_at
                existing.last_review_at = item.last_review_at
                existing.learned = item.learned
                existing.mastery = item.mastery
                existing.client_updated_at = item.client_updated_at
                existing.server_updated_at = now
                record = existing
            results.append(record)

        self.db.commit()
        # commit 后 refresh 拿到 server_updated_at 等数据库生成字段
        for record in results:
            self.db.refresh(record)
        return results
