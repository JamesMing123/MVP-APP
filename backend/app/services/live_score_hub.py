import asyncio
import json
from collections import defaultdict

from fastapi import WebSocket


class LiveScoreHub:
    def __init__(self) -> None:
        self._rooms: dict[int, set[WebSocket]] = defaultdict(set)
        self._lock = asyncio.Lock()

    async def connect(self, match_id: int, websocket: WebSocket) -> None:
        await websocket.accept()
        async with self._lock:
            self._rooms[match_id].add(websocket)

    async def disconnect(self, match_id: int, websocket: WebSocket) -> None:
        async with self._lock:
            self._rooms[match_id].discard(websocket)
            if not self._rooms[match_id]:
                self._rooms.pop(match_id, None)

    async def broadcast_score(self, match_id: int, payload: dict) -> None:
        message = json.dumps({"type": "match_score_update", "match_id": match_id, "payload": payload}, ensure_ascii=False)
        sockets = list(self._rooms.get(match_id, set()))
        for socket in sockets:
            try:
                await socket.send_text(message)
            except RuntimeError:
                await self.disconnect(match_id, socket)


live_score_hub = LiveScoreHub()
