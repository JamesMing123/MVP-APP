from openai import OpenAI
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.ai import AiReport
from app.models.match import Match


def build_fallback_report(match: Match) -> tuple[str, str, str]:
    title = f"{match.away_team.abbreviation} vs {match.home_team.abbreviation} 赛后战报"
    summary = f"{match.away_team.name} {match.away_score} - {match.home_score} {match.home_team.name}。"
    content = (
        f"本场比赛已经结束，{match.away_team.name} 与 {match.home_team.name} 打出 {match.away_score} - {match.home_score}。"
        " MVP 版本当前会优先沉淀比分、讨论和基础技术统计；接入 OpenAI API Key 后，这里会生成更完整的关键转折、球员表现和讨论话题。"
    )
    return title, summary, content


def generate_ai_report(db: Session, match: Match) -> AiReport:
    existing = db.query(AiReport).filter(AiReport.match_id == match.id).order_by(AiReport.id.desc()).first()
    if existing:
        return existing

    title, summary, content = build_fallback_report(match)
    model = "fallback"

    if settings.openai_api_key:
        client = OpenAI(api_key=settings.openai_api_key)
        prompt = (
            "你是专业 NBA 中文赛后战报作者。请基于以下结构化数据生成简洁战报，包含标题、摘要、关键转折、最佳球员和球迷讨论点。\n"
            f"比赛：{match.away_team.name} vs {match.home_team.name}\n"
            f"比分：{match.away_score} - {match.home_score}\n"
            f"状态：{match.status}\n"
        )
        response = client.responses.create(
            model=settings.openai_model,
            input=prompt,
        )
        content = response.output_text
        title = f"AI 战报：{match.away_team.abbreviation} vs {match.home_team.abbreviation}"
        summary = content[:180]
        model = settings.openai_model

    report = AiReport(match_id=match.id, title=title, summary=summary, content=content, model=model)
    db.add(report)
    db.commit()
    db.refresh(report)
    return report
