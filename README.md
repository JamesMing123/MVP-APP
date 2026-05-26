# NBA Super App MVP

A solo-developer friendly NBA fan community MVP: Flutter app, FastAPI monolith, PostgreSQL, and Redis.

## Implemented

- Flutter source scaffold with dark-first UI
- FastAPI monolith architecture
- PostgreSQL schema SQL with demo seed data
- JWT register, login, and current-user endpoint
- Match list, match detail, and score update API
- WebSocket live score room per match
- Community posts, comments, and likes
- AI post-game report API with OpenAI support and local fallback text

## Start Backend With Docker

```powershell
cd D:\NBA-APP\infra
docker compose up --build
```

API:

```text
http://localhost:8000
```

Swagger:

```text
http://localhost:8000/docs
```

## Local Backend Development

```powershell
cd D:\NBA-APP\backend
Copy-Item .env.example .env
uv sync
uv run uvicorn app.main:app --reload
```

## Flutter

Flutter CLI is not installed on this machine, so the source scaffold has been created manually. After installing Flutter, run:

```powershell
cd D:\NBA-APP\apps\mobile
flutter create . --platforms=ios,android
flutter pub get
flutter run
```

## Quick API Checks

Register:

```text
POST /api/v1/auth/register
```

Update score and broadcast WebSocket:

```text
PATCH /api/v1/matches/1/score
```

AI report:

```text
POST /api/v1/ai/matches/1/report
```
