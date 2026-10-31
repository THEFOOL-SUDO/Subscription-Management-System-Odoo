import argparse
import asyncio
import sys
from app.core.database import AsyncSessionLocal
from app.core.security import hash_password, validate_password_complexity
from app.models.user import User, UserRole
from app.repositories.user_repo import UserRepository
from app.services.audit_service import AuditService


async def bootstrap_admin(email: str, full_name: str, password: str) -> None:
    # 1. Validate password
    valid, err_msg = validate_password_complexity(password)
    if not valid:
        print(f"[-] Error: Password does not meet security requirements: {err_msg}", file=sys.stderr)
        sys.exit(1)

    # 2. Check and persist in database
    async with AsyncSessionLocal() as session:
        user_repo = UserRepository(session)
        audit_service = AuditService(session)

        existing = await user_repo.get_by_email(email)
        if existing:
            if existing.role == UserRole.ADMIN:
                print(f"[*] Admin account with email '{email}' already exists. Updating password...")
                await user_repo.update(
                    existing,
                    full_name=full_name,
                    hashed_password=hash_password(password),
                    is_active=True,
                )
                admin_user = existing
            else:
                print(f"[*] Promoting existing account '{email}' to ADMIN...")
                await user_repo.update(
                    existing,
                    full_name=full_name,
                    hashed_password=hash_password(password),
                    role=UserRole.ADMIN,
                    is_active=True,
                )
                admin_user = existing
        else:
            print(f"[*] Creating new initial administrator '{email}'...")
            admin_user = await user_repo.create(
                email=email,
                full_name=full_name,
                hashed_password=hash_password(password),
                role=UserRole.ADMIN,
                is_active=True,
                is_verified=True,
            )

        # Audit log
        await audit_service.log(
            action="ADMIN_BOOTSTRAPPED",
            resource_type="user",
            user_id=admin_user.id,
            resource_id=str(admin_user.id),
            details={"email": admin_user.email, "role": "ADMIN", "source": "CLI"},
        )
        await session.commit()
        print(f"[+] Successfully bootstrapped administrator account: {admin_user.email} (ID: {admin_user.id})")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Bootstrap the initial Brightloop System Administrator account."
    )
    parser.add_argument(
        "--email",
        type=str,
        default="admin@brightloop.com",
        help="Administrator email address (default: admin@brightloop.com)",
    )
    parser.add_argument(
        "--name",
        type=str,
        default="System Administrator",
        help="Administrator full name (default: System Administrator)",
    )
    parser.add_argument(
        "--password",
        type=str,
        default="Brightloop#Admin2026",
        help="Initial password (must satisfy complexity: >8 chars, uppercase, lowercase, number, symbol)",
    )

    args = parser.parse_args()
    asyncio.run(bootstrap_admin(email=args.email, full_name=args.name, password=args.password))


if __name__ == "__main__":
    main()
