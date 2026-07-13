from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, Numeric, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Team(Base):
    __tablename__ = "teams"

    id: Mapped[int] = mapped_column(primary_key=True)
    nba_official_id: Mapped[int | None] = mapped_column(Integer, unique=True, index=True)
    name: Mapped[str] = mapped_column(String(120), unique=True)
    abbreviation: Mapped[str] = mapped_column(String(10), unique=True)
    city: Mapped[str | None] = mapped_column(String(120))
    logo_url: Mapped[str | None] = mapped_column(String(500))
    conference: Mapped[str | None] = mapped_column(String(32))


class Player(Base):
    __tablename__ = "players"

    id: Mapped[int] = mapped_column(primary_key=True)
    nba_official_id: Mapped[int | None] = mapped_column(Integer, unique=True, index=True)
    team_id: Mapped[int | None] = mapped_column(ForeignKey("teams.id"))
    name: Mapped[str] = mapped_column(String(120), index=True)
    avatar_url: Mapped[str | None] = mapped_column(String(500))
    position: Mapped[str | None] = mapped_column(String(32))
    jersey_number: Mapped[str | None] = mapped_column(String(10))
    is_active: Mapped[int] = mapped_column(Integer, default=1)
    data_source: Mapped[str | None] = mapped_column(String(80))


class Match(Base):
    __tablename__ = "matches"

    id: Mapped[int] = mapped_column(primary_key=True)
    home_team_id: Mapped[int] = mapped_column(ForeignKey("teams.id"))
    away_team_id: Mapped[int] = mapped_column(ForeignKey("teams.id"))
    start_time: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    status: Mapped[str] = mapped_column(String(32), default="scheduled", index=True)
    home_score: Mapped[int] = mapped_column(Integer, default=0)
    away_score: Mapped[int] = mapped_column(Integer, default=0)
    period: Mapped[str | None] = mapped_column(String(32))
    clock: Mapped[str | None] = mapped_column(String(32))
    external_id: Mapped[str | None] = mapped_column(String(120), unique=True)
    data_source: Mapped[str | None] = mapped_column(String(80))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    home_team: Mapped[Team] = relationship(foreign_keys=[home_team_id])
    away_team: Mapped[Team] = relationship(foreign_keys=[away_team_id])


class MatchStat(Base):
    __tablename__ = "match_stats"

    id: Mapped[int] = mapped_column(primary_key=True)
    match_id: Mapped[int] = mapped_column(ForeignKey("matches.id"), index=True)
    team_id: Mapped[int] = mapped_column(ForeignKey("teams.id"), index=True)
    points: Mapped[int] = mapped_column(Integer, default=0)
    rebounds: Mapped[int] = mapped_column(Integer, default=0)
    assists: Mapped[int] = mapped_column(Integer, default=0)
    steals: Mapped[int] = mapped_column(Integer, default=0)
    blocks: Mapped[int] = mapped_column(Integer, default=0)
    turnovers: Mapped[int] = mapped_column(Integer, default=0)
    fg_pct: Mapped[float | None] = mapped_column(Numeric(5, 2))
    three_pct: Mapped[float | None] = mapped_column(Numeric(5, 2))
