# services/fcm_service.py
import firebase_admin
from firebase_admin import credentials, messaging
import os

# Initialize Firebase Admin SDK once
_firebase_initialized = False


def _ensure_firebase():
    global _firebase_initialized
    if not _firebase_initialized and not firebase_admin._apps:
        cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "./firebase-credentials.json")
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            _firebase_initialized = True
        else:
            print(f"[FCM] Firebase credentials file not found at {cred_path}")


async def send_push_notification(title: str, body: str, data: dict = None):
    """
    Send a push notification to the Flutter app.
    data dict is passed as custom payload for deep linking.
    """
    _ensure_firebase()

    from services.supabase_service import get_fcm_token

    fcm_token = await get_fcm_token()

    if not fcm_token:
        print("[FCM] No FCM token found — cannot send notification")
        return

    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data or {}).items()},
        android=messaging.AndroidConfig(
            priority="high",
            notification=messaging.AndroidNotification(
                sound="default",
                priority="high",
                channel_id="ai_calls",  # Must match channel created in Flutter
                icon="@drawable/ic_notification",
                color="#4A90D9",
            ),
        ),
        token=fcm_token,
    )

    try:
        response = messaging.send(message)
        print(f"[FCM] Notification sent successfully: {response}")
    except Exception as e:
        print(f"[FCM] Error sending notification: {e}")


async def send_notification(title: str, body: str, data: dict = None):
    return await send_push_notification(title=title, body=body, data=data)
