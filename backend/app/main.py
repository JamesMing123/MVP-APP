from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import ai, auth, community, matches
from app.core.config import settings
from app.ws.live_scores import router as live_score_ws_router


def create_app() -> FastAPI:
    app = FastAPI(title="NBA Super API", version="0.1.0")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
    app.include_router(matches.router, prefix="/api/v1/matches", tags=["matches"])
    app.include_router(community.router, prefix="/api/v1/community", tags=["community"])
    app.include_router(ai.router, prefix="/api/v1/ai", tags=["ai"])
    app.include_router(live_score_ws_router)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True  # 开发模式，修改代码自动重启
    )
