import httpx
import os

ELEVENLABS_KEY = os.getenv("ELEVENLABS_API_KEY")
ELEVENLABS_VOICE = os.getenv("ELEVENLABS_VOICE_ID", "21m00Tcm4TlvDq8ikWAM")

async def text_to_speech_bytes(text: str) -> bytes:
    """
    Converts text to raw 16kHz mono PCM audio bytes via ElevenLabs.
    The output format matches the AudioTrack configuration in the Android app.
    """
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE}/stream"
    headers = {
        "xi-api-key": ELEVENLABS_KEY,
        "Content-Type": "application/json"
    }
    payload = {
        "text": text,
        "model_id": "eleven_flash_v2_5",
        "output_format": "pcm_16000",
        "voice_settings": {
            "stability": 0.5,
            "similarity_boost": 0.75
        }
    }
    async with httpx.AsyncClient(timeout=15.0) as client:
        response = await client.post(url, json=payload, headers=headers)
        response.raise_for_status()
        return response.content  # raw PCM audio bytes
