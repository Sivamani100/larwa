# routes/health.py
from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check():
    """Simple health check endpoint for uptime monitoring."""
    return {"status": "ok", "version": "1.0.0", "service": "larwa-ai-call-assistant"}
