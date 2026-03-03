# services/supabase_service.py
from supabase import create_client, Client
import os

_url = os.getenv("SUPABASE_URL", "")
_key = os.getenv("SUPABASE_SERVICE_KEY", "")

supabase: Client = create_client(_url, _key) if _url and _key else None


def _get_client() -> Client:
    global supabase
    if supabase is None:
        url = os.getenv("SUPABASE_URL", "")
        key = os.getenv("SUPABASE_SERVICE_KEY", "")
        if url and key:
            supabase = create_client(url, key)
        else:
            raise RuntimeError("Supabase URL or Service Key not configured.")
    return supabase


async def save_call_log(data: dict) -> str:
    """Save a call log to Supabase. Returns the new record's ID."""
    client = _get_client()
    response = client.table("call_logs").insert(data).execute()
    return response.data[0]["id"] if response.data else None


async def update_call_status(call_log_id: str, status: str):
    """Update the status field of a call log."""
    client = _get_client()
    client.table("call_logs").update({"status": status}).eq("id", call_log_id).execute()


async def get_fcm_token() -> str | None:
    """Get the stored FCM token for sending push notifications."""
    client = _get_client()
    response = client.table("fcm_tokens").select("fcm_token").limit(1).execute()
    return response.data[0]["fcm_token"] if response.data else None


async def save_fcm_token(token: str, device_id: str = None):
    """Save or update FCM token. Called from Flutter app on startup."""
    client = _get_client()
    client.table("fcm_tokens").upsert(
        {"fcm_token": token, "device_id": device_id},
        on_conflict="fcm_token",
    ).execute()


async def get_contact_by_phone(phone: str) -> dict | None:
    """Look up a contact by normalised phone number."""
    client = _get_client()
    response = client.table("contacts").select("*").eq("phone", phone).limit(1).execute()
    return response.data[0] if response.data else None
