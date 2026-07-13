from __future__ import annotations

import sys
from datetime import datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import httpx  # noqa: E402
from sqlalchemy.dialects.postgresql import insert  # noqa: E402

from app.core.database import SessionLocal  # noqa: E402
from app.core.schema_upgrades import ensure_schema_upgrades  # noqa: E402
from app.models.match import Match, Player, Team  # noqa: E402

NBA_STATS_HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Referer": "https://www.nba.com/",
    "Origin": "https://www.nba.com",
    "Accept": "application/json, text/plain, */*",
}
ACTIVE_PLAYERS_URL = "https://stats.nba.com/stats/commonallplayers?LeagueID=00&Season=2025-26&IsOnlyCurrentSeason=1"
ALL_PLAYERS_URL = "https://stats.nba.com/stats/commonallplayers?LeagueID=00&Season=2025-26&IsOnlyCurrentSeason=0"
SCOREBOARD_URL = "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json"

RETIRED_SUPERSTARS = {
    "Michael Jordan", "Kobe Bryant", "Shaquille O'Neal", "Tim Duncan", "Magic Johnson",
    "Larry Bird", "Kareem Abdul-Jabbar", "Bill Russell", "Wilt Chamberlain",
    "Hakeem Olajuwon", "Dirk Nowitzki", "Kevin Garnett", "Dwyane Wade",
    "Allen Iverson", "Charles Barkley", "Karl Malone", "John Stockton",
}


def _rows(payload: dict) -> list[dict]:
    result = payload["resultSets"][0]
    headers = result["headers"]
    return [dict(zip(headers, row, strict=False)) for row in result["rowSet"]]


def _team_id(row: dict) -> int | None:
    value = row.get("TEAM_ID") or row.get("TO_TEAM_ID")
    return int(value) if value not in (None, "", 0) else None


def sync_players() -> int:
    with httpx.Client(headers=NBA_STATS_HEADERS, timeout=30) as client:
        active_rows = _rows(client.get(ACTIVE_PLAYERS_URL).raise_for_status().json())
        all_rows = _rows(client.get(ALL_PLAYERS_URL).raise_for_status().json())

    active_ids = {int(row["PERSON_ID"]) for row in active_rows}
    superstar_rows = [row for row in all_rows if row["DISPLAY_FIRST_LAST"] in RETIRED_SUPERSTARS]
    rows = active_rows + [row for row in superstar_rows if int(row["PERSON_ID"]) not in active_ids]

    with SessionLocal() as db:
        for row in rows:
            team_id = _team_id(row)
            if team_id:
                db.execute(insert(Team).values(id=team_id, nba_official_id=team_id, name=row.get("TEAM_NAME") or row.get("TEAM_CITY") or "Unknown", abbreviation=row.get("TEAM_ABBREVIATION") or "UNK", city=row.get("TEAM_CITY"), conference=None).on_conflict_do_update(index_elements=[Team.id], set_={"name": row.get("TEAM_NAME") or row.get("TEAM_CITY") or "Unknown", "abbreviation": row.get("TEAM_ABBREVIATION") or "UNK", "city": row.get("TEAM_CITY")}))
            player_id = int(row["PERSON_ID"])
            db.execute(insert(Player).values(id=player_id, nba_official_id=player_id, team_id=team_id, name=row["DISPLAY_FIRST_LAST"], avatar_url=f"https://cdn.nba.com/headshots/nba/latest/1040x760/{player_id}.png", is_active=1 if player_id in active_ids else 0, data_source="stats.nba.com").on_conflict_do_update(index_elements=[Player.id], set_={"team_id": team_id, "name": row["DISPLAY_FIRST_LAST"], "avatar_url": f"https://cdn.nba.com/headshots/nba/latest/1040x760/{player_id}.png", "is_active": 1 if player_id in active_ids else 0, "data_source": "stats.nba.com"}))
        db.commit()
    return len(rows)


def sync_today_scoreboard() -> int:
    payload = httpx.get(SCOREBOARD_URL, headers=NBA_STATS_HEADERS, timeout=30).raise_for_status().json()
    games = payload.get("scoreboard", {}).get("games", [])
    with SessionLocal() as db:
        for game in games:
            home = game["homeTeam"]
            away = game["awayTeam"]
            for team in (home, away):
                team_id = int(team["teamId"])
                db.execute(insert(Team).values(id=team_id, nba_official_id=team_id, name=team["teamName"], abbreviation=team["teamTricode"], city=team["teamCity"], logo_url=f"https://cdn.nba.com/logos/nba/{team_id}/primary/L/logo.svg").on_conflict_do_update(index_elements=[Team.id], set_={"name": team["teamName"], "abbreviation": team["teamTricode"], "city": team["teamCity"], "logo_url": f"https://cdn.nba.com/logos/nba/{team_id}/primary/L/logo.svg"}))
            status = str(game.get("gameStatusText") or game.get("gameStatus") or "scheduled")
            db.execute(insert(Match).values(id=int(game["gameId"]), home_team_id=int(home["teamId"]), away_team_id=int(away["teamId"]), start_time=datetime.fromisoformat(game["gameTimeUTC"].replace("Z", "+00:00")), status=status, home_score=int(home.get("score") or 0), away_score=int(away.get("score") or 0), period=str(game.get("period") or ""), clock=game.get("gameClock"), external_id=str(game["gameId"]), data_source="cdn.nba.com").on_conflict_do_update(index_elements=[Match.id], set_={"status": status, "home_score": int(home.get("score") or 0), "away_score": int(away.get("score") or 0), "period": str(game.get("period") or ""), "clock": game.get("gameClock"), "data_source": "cdn.nba.com"}))
        db.commit()
    return len(games)


if __name__ == "__main__":
    ensure_schema_upgrades()
    print(f"players imported: {sync_players()}")
    print(f"today games imported: {sync_today_scoreboard()}")
