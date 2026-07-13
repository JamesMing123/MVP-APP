from __future__ import annotations

import sys
from datetime import UTC, datetime
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

import httpx  # noqa: E402
from sqlalchemy import select  # noqa: E402

from app.core.database import SessionLocal  # noqa: E402
from app.models.community import Post  # noqa: E402
from app.models.user import User  # noqa: E402

REDDIT_URL = "https://old.reddit.com/r/nba/top.json?t=week&limit=50&raw_json=1"
PULLPUSH_URL = "https://api.pullpush.io/reddit/search/submission/?subreddit=nba&size=50&sort=desc&sort_type=created_utc"
HEADERS = {
    "User-Agent": "Mozilla/5.0 NBA-Super-App-MVP/0.1",
    "Accept": "application/json",
}


def get_import_user(db) -> User:
    user = db.execute(select(User).where(User.username == "reddit_importer")).scalar_one_or_none()
    if user:
        return user
    user = User(
        email="reddit-importer@local.nba-super",
        username="reddit_importer",
        nickname="Reddit r/nba",
        password_hash="disabled-system-import-user",
        role="system",
        status="active",
    )
    db.add(user)
    db.flush()
    return user


def import_posts() -> int:
    children = _fetch_posts()
    imported = 0
    with SessionLocal() as db:
        user = get_import_user(db)
        for data in children:
            permalink = data["permalink"]
            if permalink.startswith("/"):
                permalink = f"https://www.reddit.com{permalink}"
            exists = db.execute(select(Post).where(Post.content.contains(permalink))).scalar_one_or_none()
            if exists:
                continue
            title = data["title"][:180]
            body = (data.get("selftext") or "").strip()
            content = "\n\n".join(
                part
                for part in [
                    body if body else "Reddit r/nba discussion thread.",
                    f"Source: {permalink}",
                    f"Author: u/{data.get('author')}",
                    f"Reddit score: {data.get('score')}",
                ]
                if part
            )
            created_at = datetime.fromtimestamp(float(data["created_utc"]), tz=UTC)
            post = Post(
                user_id=user.id,
                title=title,
                content=content,
                post_type="reddit",
                like_count=int(data.get("ups") or data.get("score") or 0),
                comment_count=int(data.get("num_comments") or 0),
                status="published",
                created_at=created_at,
                updated_at=created_at,
            )
            db.add(post)
            imported += 1
        db.commit()
    return imported


def _fetch_posts() -> list[dict]:
    try:
        payload = httpx.get(REDDIT_URL, headers=HEADERS, timeout=30, follow_redirects=True).raise_for_status().json()
        return [child["data"] for child in payload["data"]["children"]]
    except httpx.HTTPStatusError:
        payload = httpx.get(PULLPUSH_URL, headers=HEADERS, timeout=60).raise_for_status().json()
        return payload["data"]


if __name__ == "__main__":
    print(f"reddit posts imported: {import_posts()}")
