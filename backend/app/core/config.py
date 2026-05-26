from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_env: str = "local"
    database_url: str = "postgresql+psycopg://nba:nba@localhost:5432/nba_super"
    redis_url: str = "redis://localhost:6379/0"
    jwt_secret_key: str = Field(default="change-me-in-production")
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24
    openai_api_key: str | None = None
    openai_model: str = "gpt-4.1-mini"
    cors_origins: list[str] = ["*"]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
