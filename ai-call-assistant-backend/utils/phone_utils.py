# utils/phone_utils.py
import re


def normalize_phone_number(phone: str) -> str:
    """
    Normalize a phone number to E.164 format.
    Examples:
        '09876543210'     -> '+919876543210'
        '+91 98765 43210' -> '+919876543210'
        '+14155551234'    -> '+14155551234'
        '4155551234'      -> '+14155551234'   (assumes US if 10 digits)
    """
    if not phone:
        return phone

    # Strip all non-digit characters except leading +
    has_plus = phone.startswith("+")
    digits = re.sub(r"[^\d]", "", phone)

    if not digits:
        return phone

    # If the original had a +, keep the international format
    if has_plus:
        return f"+{digits}"

    # Indian numbers: 10 digits starting with 6-9
    if len(digits) == 10 and digits[0] in "6789":
        return f"+91{digits}"

    # Indian numbers with country code: 91 + 10 digits
    if len(digits) == 12 and digits.startswith("91") and digits[2] in "6789":
        return f"+{digits}"

    # US numbers: 10 digits
    if len(digits) == 10:
        return f"+1{digits}"

    # US numbers with country code: 1 + 10 digits  
    if len(digits) == 11 and digits.startswith("1"):
        return f"+{digits}"

    # Already has enough digits — trust it
    return f"+{digits}"


def format_phone_display(phone: str) -> str:
    """
    Format a phone number for human-readable display.
    '+919876543210' -> '+91 98765 43210'
    '+14155551234'  -> '+1 (415) 555-1234'
    """
    if not phone:
        return "Unknown"

    digits = re.sub(r"[^\d]", "", phone)

    # Indian format
    if len(digits) == 12 and digits.startswith("91"):
        return f"+91 {digits[2:7]} {digits[7:]}"

    # US format
    if len(digits) == 11 and digits.startswith("1"):
        return f"+1 ({digits[1:4]}) {digits[4:7]}-{digits[7:]}"

    return phone  # Return as-is if unrecognized format
