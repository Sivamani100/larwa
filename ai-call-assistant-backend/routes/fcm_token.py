from fastapi import APIRouter
from pydantic import BaseModel
from services.supabase_service import save_fcm_token

router = APIRouter()

class TokenRequest(BaseModel):
    token: str

@router.post("/fcm-token")
async def register_token(req: TokenRequest):
    await save_fcm_token(req.token)
    return {"status": "ok"}
