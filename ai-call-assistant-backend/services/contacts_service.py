# services/contacts_service.py
from utils.phone_utils import normalize_phone_number


async def get_contact_name(phone_number: str) -> str | None:
    """
    Look up a phone number in the Supabase contacts table.
    Returns the contact name if found, None otherwise.
    """
    try:
        normalized = normalize_phone_number(phone_number)
        from services.supabase_service import get_contact_by_phone

        contact = await get_contact_by_phone(normalized)
        if contact:
            return contact.get("name")

        # Also try the raw number in case normalisation differs
        if normalized != phone_number:
            contact = await get_contact_by_phone(phone_number)
            if contact:
                return contact.get("name")

        return None
    except Exception as e:
        print(f"[CONTACTS] Error looking up {phone_number}: {e}")
        return None
