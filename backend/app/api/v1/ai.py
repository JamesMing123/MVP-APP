from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.core.response import ok
from app.models.match import Match
from app.schemas.ai import AiReportOut
from app.services.ai_reports import generate_ai_report

router = APIRouter()


@router.post("/matches/{match_id}/report")
def create_match_report(match_id: int, db: Session = Depends(get_db)):
    match = (
        db.query(Match)
        .options(joinedload(Match.home_team), joinedload(Match.away_team))
        .filter(Match.id == match_id)
        .first()
    )
    if match is None:
        raise HTTPException(status_code=404, detail="Match not found")
    report = generate_ai_report(db, match)
    return ok(AiReportOut.model_validate(report).model_dump(mode="json"))
