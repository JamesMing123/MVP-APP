CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(64) NOT NULL UNIQUE,
  nickname VARCHAR(64) NOT NULL,
  avatar_url VARCHAR(500),
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(32) NOT NULL DEFAULT 'user',
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS teams (
  id BIGSERIAL PRIMARY KEY,
  nba_official_id BIGINT UNIQUE,
  name VARCHAR(120) NOT NULL UNIQUE,
  abbreviation VARCHAR(10) NOT NULL UNIQUE,
  city VARCHAR(120),
  logo_url VARCHAR(500),
  conference VARCHAR(32)
);

CREATE TABLE IF NOT EXISTS players (
  id BIGSERIAL PRIMARY KEY,
  nba_official_id BIGINT UNIQUE,
  team_id BIGINT REFERENCES teams(id),
  name VARCHAR(120) NOT NULL,
  avatar_url VARCHAR(500),
  position VARCHAR(32),
  jersey_number VARCHAR(10),
  is_active INTEGER NOT NULL DEFAULT 1,
  data_source VARCHAR(80)
);

CREATE INDEX IF NOT EXISTS ix_players_name ON players(name);
CREATE INDEX IF NOT EXISTS ix_players_nba_official_id ON players(nba_official_id);

CREATE TABLE IF NOT EXISTS matches (
  id BIGSERIAL PRIMARY KEY,
  home_team_id BIGINT NOT NULL REFERENCES teams(id),
  away_team_id BIGINT NOT NULL REFERENCES teams(id),
  start_time TIMESTAMPTZ NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'scheduled',
  home_score INTEGER NOT NULL DEFAULT 0,
  away_score INTEGER NOT NULL DEFAULT 0,
  period VARCHAR(32),
  clock VARCHAR(32),
  external_id VARCHAR(120) UNIQUE,
  data_source VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_matches_start_time ON matches(start_time);
CREATE INDEX IF NOT EXISTS ix_matches_status ON matches(status);

CREATE TABLE IF NOT EXISTS match_stats (
  id BIGSERIAL PRIMARY KEY,
  match_id BIGINT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  team_id BIGINT NOT NULL REFERENCES teams(id),
  points INTEGER NOT NULL DEFAULT 0,
  rebounds INTEGER NOT NULL DEFAULT 0,
  assists INTEGER NOT NULL DEFAULT 0,
  steals INTEGER NOT NULL DEFAULT 0,
  blocks INTEGER NOT NULL DEFAULT 0,
  turnovers INTEGER NOT NULL DEFAULT 0,
  fg_pct NUMERIC(5,2),
  three_pct NUMERIC(5,2)
);

CREATE INDEX IF NOT EXISTS ix_match_stats_match_id ON match_stats(match_id);
CREATE INDEX IF NOT EXISTS ix_match_stats_team_id ON match_stats(team_id);

CREATE TABLE IF NOT EXISTS posts (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  match_id BIGINT REFERENCES matches(id),
  team_id BIGINT REFERENCES teams(id),
  title VARCHAR(180) NOT NULL,
  content TEXT NOT NULL,
  image_urls JSONB,
  post_type VARCHAR(32) NOT NULL DEFAULT 'discussion',
  like_count INTEGER NOT NULL DEFAULT 0,
  comment_count INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(32) NOT NULL DEFAULT 'published',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_posts_user_id ON posts(user_id);
CREATE INDEX IF NOT EXISTS ix_posts_match_id ON posts(match_id);
CREATE INDEX IF NOT EXISTS ix_posts_team_id ON posts(team_id);
CREATE INDEX IF NOT EXISTS ix_posts_created_at ON posts(created_at);

CREATE TABLE IF NOT EXISTS comments (
  id BIGSERIAL PRIMARY KEY,
  post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id),
  parent_id BIGINT REFERENCES comments(id),
  content TEXT NOT NULL,
  like_count INTEGER NOT NULL DEFAULT 0,
  status VARCHAR(32) NOT NULL DEFAULT 'published',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_comments_post_id ON comments(post_id);
CREATE INDEX IF NOT EXISTS ix_comments_user_id ON comments(user_id);

CREATE TABLE IF NOT EXISTS likes (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  target_type VARCHAR(32) NOT NULL,
  target_id BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_likes_user_target UNIQUE (user_id, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS ix_likes_user_id ON likes(user_id);

CREATE TABLE IF NOT EXISTS ai_reports (
  id BIGSERIAL PRIMARY KEY,
  match_id BIGINT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  title VARCHAR(180) NOT NULL,
  summary TEXT,
  content TEXT NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'published',
  model VARCHAR(80),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_ai_reports_match_id ON ai_reports(match_id);

-- Real NBA seed data is imported by backend/scripts/sync_nba_official_data.py.
-- This schema intentionally avoids fake demo games or fabricated players.
