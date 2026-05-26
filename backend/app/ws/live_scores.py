from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.services.live_score_hub import live_score_hub

router = APIRouter()


@router.websocket("/ws/v1/matches/{match_id}")
async def match_live_score(websocket: WebSocket, match_id: int):
    await live_score_hub.connect(match_id, websocket)
    try:
        await websocket.send_json({"type": "connected", "match_id": match_id})
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        await live_score_hub.disconnect(match_id, websocket)
