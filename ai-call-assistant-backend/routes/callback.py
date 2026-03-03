# routes/callback.py
from fastapi import APIRouter
from fastapi.responses import Response
from pydantic import BaseModel
from twilio.rest import Client
import os

router = APIRouter()

# In-memory store for pending callback data
pending_callbacks = {}


class CallbackRequest(BaseModel):
    to_number: str  # The phone number to call back
    your_message: str  # What you want the AI to say
    caller_name: str  # Their name for personalisation
    call_log_id: str  # Reference to original call


@router.post("/callback")
async def trigger_callback(req: CallbackRequest):
    """
    Flutter app calls this when user wants AI to call someone back.
    Twilio makes an outbound call. When answered, it connects to
    a special TwiML that speaks the user's message.
    """
    pending_callbacks[req.call_log_id] = {
        "message": req.your_message,
        "caller_name": req.caller_name,
        "to_number": req.to_number,
    }

    twilio_client = Client(
        os.getenv("TWILIO_ACCOUNT_SID"),
        os.getenv("TWILIO_AUTH_TOKEN"),
    )

    callback_url = f"{os.getenv('BACKEND_URL')}/callback-twiml/{req.call_log_id}"

    call = twilio_client.calls.create(
        to=req.to_number,
        from_=os.getenv("TWILIO_PHONE_NUMBER"),
        url=callback_url,
        status_callback=f"{os.getenv('BACKEND_URL')}/callback-ended/{req.call_log_id}",
        status_callback_event=["completed"],
    )

    return {"status": "calling", "call_sid": call.sid}


@router.get("/callback-twiml/{callback_id}")
async def get_callback_twiml(callback_id: str):
    """Returns TwiML for the callback call — plays the user's message."""
    data = pending_callbacks.get(callback_id, {})
    owner_name = os.getenv("OWNER_NAME", "Your Contact")
    caller_name = data.get("caller_name", "there")
    message = data.get("message", "I'm returning your call.")

    twiml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Say voice="en-US-Journey-O" language="en-US">
    Hi {caller_name}, this is {owner_name}'s assistant calling back on their behalf.
    {message}
    If you need anything else, please call back and I'll take a message. Have a great day.
  </Say>
</Response>"""

    return Response(content=twiml, media_type="application/xml")


@router.post("/callback-ended/{callback_id}")
async def callback_ended(callback_id: str):
    """Cleanup after an outbound callback completes."""
    pending_callbacks.pop(callback_id, None)

    # Update the call log status to 'replied'
    from services.supabase_service import update_call_status
    await update_call_status(callback_id, "replied")

    return {"status": "ok"}
