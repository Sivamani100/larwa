# prompts/summary_prompt.py


def build_summary_prompt(
    transcript_text: str, caller_name: str, caller_number: str
) -> str:
    return f"""Analyse this phone call transcript and return a JSON object with the following fields.
Return ONLY valid JSON — no markdown, no explanation, no preamble.

TRANSCRIPT:
{transcript_text}

CALLER INFO:
- Name from contacts: {caller_name if caller_name else "Unknown"}
- Phone number: {caller_number}

Return this exact JSON structure:
{{
  "caller_name": "Full name of the caller (use contacts name if available, otherwise from transcript)",
  "caller_relationship": "colleague|friend|family|client|vendor|unknown",
  "purpose": "One sentence describing why they called",
  "summary": "2-3 sentence natural language summary of the entire call. Include all key details.",
  "key_details": ["specific fact 1", "specific fact 2"],
  "urgency": "low|medium|high|urgent",
  "call_type": "spam|event|routine|important|urgent",
  "action_needed": "What does the owner need to do? Be specific.",
  "recommended_response": "Suggested reply if owner wants AI to call back on their behalf. Leave empty string if no action needed.",
  "deadline": "Any mentioned deadline in natural language, or empty string",
  "should_call_back": true
}}"""
