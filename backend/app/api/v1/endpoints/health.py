import time
from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from app.config import settings
from app.core.database import get_db
from app.core.rate_limiter import get_redis_client

router = APIRouter(tags=["Health"])


@router.get("/health")
async def health_check(db: AsyncSession = Depends(get_db)):
    """System health check endpoint verifying database and cache availability."""
    db_ok = False
    redis_ok = False
    details = {}

    # Check database
    try:
        t0 = time.time()
        result = await db.execute(text("SELECT 1"))
        if result.scalar() == 1:
            db_ok = True
            details["database_latency_ms"] = round((time.time() - t0) * 1000, 2)
    except Exception as exc:
        details["database_error"] = str(exc)

    # Check Redis
    try:
        t0 = time.time()
        client = await get_redis_client()
        if client and await client.ping():
            redis_ok = True
            details["redis_latency_ms"] = round((time.time() - t0) * 1000, 2)
    except Exception as exc:
        details["redis_error"] = str(exc)

    overall_ok = db_ok and redis_ok
    status_code = status.HTTP_200_OK if overall_ok else status.HTTP_503_SERVICE_UNAVAILABLE

    return JSONResponse(
        status_code=status_code,
        content={
            "status": "healthy" if overall_ok else "unhealthy",
            "environment": settings.ENVIRONMENT,
            "version": "1.0.0",
            "services": {
                "database": "connected" if db_ok else "disconnected",
                "redis": "connected" if redis_ok else "disconnected",
            },
            "metrics": details,
        },
    )
