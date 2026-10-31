import os
from typing import List, Union
from pydantic import AnyHttpUrl, EmailStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env"),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )

    # Core Application
    PROJECT_NAME: str = "Brightloop Subscription Management"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    API_V1_STR: str = "/api/v1"

    # Security & Tokens
    SECRET_KEY: str = "change-this-to-a-super-secret-random-key-in-production-brightloop-2026"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    PASSWORD_RESET_TOKEN_EXPIRE_MINUTES: int = 60

    # PostgreSQL Database
    DATABASE_URL: str = "postgresql+asyncpg://brightloop_user:brightloop_secret_password@localhost:5435/brightloop_db"
    SYNC_DATABASE_URL: str = "postgresql://brightloop_user:brightloop_secret_password@localhost:5435/brightloop_db"
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_PORT: int = 5435
    POSTGRES_DB: str = "brightloop_db"
    POSTGRES_USER: str = "brightloop_user"
    POSTGRES_PASSWORD: str = "brightloop_secret_password"

    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6385
    REDIS_URL: str = "redis://localhost:6385/0"

    # Mailpit / SMTP
    SMTP_HOST: str = "localhost"
    SMTP_PORT: int = 1028
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    EMAILS_FROM_EMAIL: EmailStr = "noreply@brightloop.com"
    EMAILS_FROM_NAME: str = "Brightloop Platform"

    # CORS & Frontend
    FRONTEND_URL: str = "http://localhost:5173"
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ]

    @property
    def is_production(self) -> bool:
        return self.ENVIRONMENT.lower() == "production"


settings = Settings()
