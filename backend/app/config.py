import os

class Settings:
    PROJECT_NAME: str = "PlacePrep API"
    VERSION: str = "2.0.0"
    API_V1_STR: str = "/api"
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./placeprep.db")
    
    # JWT Authentication
    SECRET_KEY: str = os.getenv("SECRET_KEY", "placeprep-secret-key-ace-every-interview-2026")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 days
    
    # CORS Origins
    CORS_ORIGINS: list = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "http://127.0.0.1:8080",
        "http://127.0.0.1:5000",
        "https://placeprep.in",
        "*"
    ]

settings = Settings()
