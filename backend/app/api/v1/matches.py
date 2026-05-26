from datetime import UTC, datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.core.response import ok
from app.models.match import Match
from app.schemas.match import MatchOut, MatchScoreUpdate
from app.services.live_score_hub import live_score_hub

router = APIRouter()


@router.get("")
def list_matches(date: str | None = None, db: Session = Depends(get_db)):
    query = db.query(Match).options(joinedload(Match.home_team), joinedload(Match.away_team))
    if date:
        start = datetime.fromisoformat(date).replace(tzinfo=UTC)
        end = start + timedelta(days=1)
        query = query.filter(Match.start_time >= start, Match.start_time < end)
    matches = query.order_by(Match.start_time.asc()).limit(100).all()
    return ok([MatchOut.model_validate(item).model_dump(mode="json") for item in matches])


@router.get("/{match_id}")
def get_match(match_id: int, db: Session = Depends(get_db)):
    match = (
        db.query(Match)
        .options(joinedload(Match.home_team), joinedload(Match.away_team))
        .filter(Match.id == match_id)
        .first()
    )
    if match is None:
        raise HTTPException(status_code=404, detail="Match not found")
    return ok(MatchOut.model_validate(match).model_dump(mode="json"))


@router.patch("/{match_id}/score")
async def update_score(match_id: int, payload: MatchScoreUpdate, db: Session = Depends(get_db)):
    match = db.get(Match, match_id)
    if match is None:
        raise HTTPException(status_code=404, detail="Match not found")

    updates = payload.model_dump(exclude_none=True)
    for field, value in updates.items():
        setattr(match, field, value)
    db.commit()
    db.refresh(match)

    broadcast_payload = {
        "status": match.status,
        "home_score": match.home_score,
        "away_score": match.away_score,
        "period": match.period,
        "clock": match.clock,
    }
    await live_score_hub.broadcast_score(match_id, broadcast_payload)
    return ok(broadcast_payload)
