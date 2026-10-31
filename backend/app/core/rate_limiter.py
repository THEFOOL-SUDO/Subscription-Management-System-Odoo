import time
from collections import defaultdict, deque
from typing import Tuple
import redis.asyncio as aioredis
from app.config import settings

_redis_client: aioredis.Redis | None = None
_memory_store: dict[str, deque[float]] = defaultdict(deque)


async def get_redis_client() -> aioredis.Redis | None:
    global _redis_client
    if _redis_client is not None:
        try:
            await _redis_client.ping()
        except Exception:
            try:
                await _redis_client.aclose()
            except Exception:
                pass
            _redis_client = None

    if _redis_client is None:
        try:
            _redis_client = aioredis.from_url(
                settings.REDIS_URL,
                decode_responses=True,
                socket_timeout=2.0,
                socket_connect_timeout=2.0,
            )
            await _redis_client.ping()
        except Exception:
            _redis_client = None
    return _redis_client


async def check_rate_limit(
    key: str,
    max_requests: int = 5,
    window_seconds: int = 60,
) -> Tuple[bool, int, int]:
    """
    Check if a rate limit has been exceeded.
    Returns: (is_allowed: bool, remaining: int, retry_after: int)
    """
    now = time.time()
    r = await get_redis_client()

    if r is not None:
        try:
            redis_key = f"rate_limit:{key}"
            pipe = r.pipeline()
            # Remove timestamps older than window
            pipe.zremrangebyscore(redis_key, 0, now - window_seconds)
            # Count elements in window
            pipe.zcard(redis_key)
            # Add current timestamp
            pipe.zadd(redis_key, {str(now): now})
            # Set key expiration
            pipe.expire(redis_key, window_seconds)
            results = await pipe.execute()

            current_count = results[1]
            if current_count >= max_requests:
                # Exceeded
                return False, 0, window_seconds
            remaining = max(0, max_requests - current_count - 1)
            return True, remaining, 0
        except Exception:
            # Fall back to in-memory sliding window
            pass

    # In-memory sliding window fallback
    queue = _memory_store[key]
    while queue and queue[0] <= now - window_seconds:
        queue.popleft()

    if len(queue) >= max_requests:
        retry_after = int(window_seconds - (now - queue[0])) if queue else window_seconds
        return False, 0, max(1, retry_after)

    queue.append(now)
    remaining = max(0, max_requests - len(queue))
    return True, remaining, 0
