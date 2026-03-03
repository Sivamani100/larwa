from fastapi import APIRouter
from pydantic import BaseModel
from services.ai_service import stream_response
from services.tts_service import text_to_speech_bytes
from fastapi.responses import Response
from typing import List

router = APIRouter()

class Message(BaseModel):
    role: str
    content: str

class AiRequest(BaseModel):
    messages: List[Message]

from fastapi.responses import StreamingResponse
import json

@router.post("/ai-response")
async def get_ai_response(req: AiRequest):
    async def event_generator():
        async for chunk in stream_response([m.dict() for m in req.messages]):
            if chunk:
                # Send raw text chunks
                yield chunk

    return StreamingResponse(event_generator(), media_type="text/plain")

class TtsRequest(BaseModel):
    text: str

@router.post("/tts")
async def get_tts_pcm(req: TtsRequest):
    pcm_bytes = await text_to_speech_bytes(req.text)
    return Response(content=pcm_bytes, media_type="application/octet-stream")
