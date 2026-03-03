import anthropic, json, os
from typing import AsyncGenerator

client = anthropic.AsyncAnthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))
MODEL = 'claude-3-haiku-20240307'
OWNER = os.getenv('OWNER_NAME', 'Your Boss')

# ── STREAMING: Used during live call for real-time responses ──────────
async def stream_response(messages: list) -> AsyncGenerator[str, None]:
    system = next((m['content'] for m in messages if m['role']=='system'), '')
    convo  = [m for m in messages if m['role'] != 'system']
    async with client.messages.stream(
        model=MODEL, max_tokens=280,
        system=system, messages=convo
    ) as s:
        async for token in s.text_stream:
            yield token

# ── SUMMARY: Used after call ends ─────────────────────────────────────
async def generate_call_summary(transcript, caller_name, caller_number) -> dict:
    from prompts.summary_prompt import build_summary_prompt
    transcript_text = "\n".join(
        f"{'CALLER' if t['speaker']=='caller' else 'AI'}: {t['text']}"
        for t in transcript
    )
    prompt = build_summary_prompt(transcript_text, caller_name, caller_number)
    res = await client.messages.create(
        model=MODEL, max_tokens=700,
        messages=[{'role':'user','content':prompt}]
    )
    text = res.content[0].text.strip()
    if text.startswith('```'): text = text.split("\n",1)[1].rsplit('```',1)[0]
    try: return json.loads(text)
    except:
        return {'summary':text[:200],'caller_name':caller_name or 'Unknown',
                'purpose':'Unknown','urgency':'low','call_type':'routine',
                'action_needed':'Review call','recommended_response':'',
                'should_call_back':False}
