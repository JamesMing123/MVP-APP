from datetime import datetime

from pydantic import BaseModel


class AiReportOut(BaseModel):
    id: int
    match_id: int
    title: str
    summary: str | None
    content: str
    status: str
    model: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
