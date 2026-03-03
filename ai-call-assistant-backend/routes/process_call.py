from fastapi import APIRouter
from pydantic import BaseModel
from services.ai_service import generate_call_summary
from services.supabase_service import save_call_log
from typing import List

router = APIRouter()

class TranscriptEntry(BaseModel):
    speaker: str   # 'caller' or 'assistant'
    text: str

class ProcessCallRequest(BaseModel):
    caller_number: str
    caller_name: str | None = None
    is_known_contact: bool = False
    call_duration_sec: int = 0
    transcript: List[TranscriptEntry]

@router.post("/process-call")
async def process_call(req: ProcessCallRequest):
    # 1. Generate structured summary from Claude
    summary_data = await generate_call_summary(
        transcript=[t.dict() for t in req.transcript],
        caller_name=req.caller_name or "Unknown",
        caller_number=req.caller_number
    )

    # 2. Save to Supabase
    call_log_id = await save_call_log({
        "caller_number": req.caller_number,
        "caller_name": summary_data.get("caller_name", req.caller_name),
        "is_known_contact": req.is_known_contact,
        "call_duration_sec": req.call_duration_sec,
        "call_type": summary_data.get("call_type", "routine"),
        "ai_summary": summary_data.get("summary", ""),
        "full_transcript": [t.dict() for t in req.transcript],
        "urgency_level": summary_data.get("urgency", "low"),
        "action_needed": summary_data.get("action_needed", ""),
        "recommended_response": summary_data.get("recommended_response", ""),
        "should_call_back": summary_data.get("should_call_back", False),
        "status": "new",
    })

    return {"status": "ok", "call_log_id": call_log_id, "summary": summary_data}
