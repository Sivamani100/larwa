# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes.process_call import router as process_router
from routes.callback import router as callback_router
from routes.fcm_token import router as fcm_router
from routes.health import router as health_router
from routes.ai_control import router as ai_router
from dotenv import load_dotenv
import os

load_dotenv()

app = FastAPI(title="Larwa AI Call Assistant Backend", version="1.0.0")

# Allow all origins for personal use — restrict in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(process_router)
app.include_router(callback_router)
app.include_router(fcm_router)
app.include_router(health_router)
app.include_router(ai_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=int(os.getenv("PORT", 8080)), reload=True)
