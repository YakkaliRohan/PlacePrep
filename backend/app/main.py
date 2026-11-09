from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.database import engine, Base
from app.models import entities # ensure models are registered
from app.routers import auth, questions, tests, leaderboard, admin

# Create tables if not existing
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="PlacePrep.in — High-performance Python backend for campus placement interview preparation",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json"
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router, prefix=settings.API_V1_STR)
app.include_router(questions.router, prefix=settings.API_V1_STR)
app.include_router(tests.router, prefix=settings.API_V1_STR)
app.include_router(leaderboard.router, prefix=settings.API_V1_STR)
app.include_router(admin.router, prefix=settings.API_V1_STR)
app.include_router(admin.feedback_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "app": "PlacePrep API",
        "version": settings.VERSION,
        "status": "online",
        "documentation": "/api/docs"
    }

@app.get("/api/health")
def health_check():
    return {"status": "healthy"}
