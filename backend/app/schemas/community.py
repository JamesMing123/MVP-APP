from datetime import datetime

from pydantic import BaseModel, Field


class PostCreate(BaseModel):
    title: str = Field(min_length=1, max_length=180)
    content: str = Field(min_length=1, max_length=5000)
    match_id: int | None = None
    team_id: int | None = None
    image_urls: list[str] | None = None


class PostOut(BaseModel):
    id: int
    user_id: int
    match_id: int | None
    team_id: int | None
    title: str
    content: str
    image_urls: list[str] | None
    like_count: int
    comment_count: int
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


class CommentCreate(BaseModel):
    content: str = Field(min_length=1, max_length=2000)
    parent_id: int | None = None


class CommentOut(BaseModel):
    id: int
    post_id: int
    user_id: int
    parent_id: int | None
    content: str
    like_count: int
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}
