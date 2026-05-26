from datetime import datetime

from pydantic import BaseModel


class TeamOut(BaseModel):
    id: int
    name: str
    abbreviation: str
    city: str | None = None
    logo_url: str | None = None
    conference: str | None = None

    model_config = {"from_attributes": True}


class MatchOut(BaseModel):
    id: int
    home_team: TeamOut
    away_team: TeamOut
    start_time: datetime
    status: str
    home_score: int
    away_score: int
    period: str | None = None
    clock: str | None = None

    model_config = {"from_attributes": True}


class MatchScoreUpdate(BaseModel):
    status: str | None = None
    home_score: int | None = None
    away_score: int | None = None
    period: str | None = None
    clock: str | None = None
