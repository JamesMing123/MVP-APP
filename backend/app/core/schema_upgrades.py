from sqlalchemy import text

from app.core.database import engine


def ensure_schema_upgrades() -> None:
    """Small MVP-era schema patcher for existing local databases."""
    statements = [
        "ALTER TABLE teams ADD COLUMN IF NOT EXISTS nba_official_id BIGINT UNIQUE",
        "ALTER TABLE players ADD COLUMN IF NOT EXISTS nba_official_id BIGINT UNIQUE",
        "ALTER TABLE players ADD COLUMN IF NOT EXISTS is_active INTEGER NOT NULL DEFAULT 1",
        "ALTER TABLE players ADD COLUMN IF NOT EXISTS data_source VARCHAR(80)",
        "ALTER TABLE matches ADD COLUMN IF NOT EXISTS data_source VARCHAR(80)",
        "CREATE INDEX IF NOT EXISTS ix_teams_nba_official_id ON teams(nba_official_id)",
        "CREATE INDEX IF NOT EXISTS ix_players_nba_official_id ON players(nba_official_id)",
        "DELETE FROM matches WHERE external_id = 'demo-lal-bos-001'",
        "UPDATE teams SET abbreviation = abbreviation || '_OLD' WHERE id < 1000 AND nba_official_id IS NULL AND abbreviation IN ('LAL', 'BOS')",
    ]
    with engine.begin() as conn:
        for statement in statements:
            conn.execute(text(statement))
