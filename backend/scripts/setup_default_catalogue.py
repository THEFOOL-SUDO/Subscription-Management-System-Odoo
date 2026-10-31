#!/usr/bin/env python3
"""
Brightloop — Standalone CLI Script to Idempotently Setup Default Catalogue.
Creates 3 software products, 3 addon products, and 6 software subscription plans in PostgreSQL.
Preserves existing records and never overwrites customized prices or descriptions.
"""

import asyncio
import json
import logging
import sys
from pathlib import Path

# Add backend directory to sys.path
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from app.core.database import AsyncSessionLocal
from app.repositories.user_repo import UserRepository
from app.services.catalogue_service import CatalogueService

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("brightloop.catalogue_setup")


async def main():
    logger.info("Initializing Brightloop Default Catalogue Setup...")
    async with AsyncSessionLocal() as session:
        user_repo = UserRepository(session)
        admin = await user_repo.get_by_email("admin@brightloop.com")
        if not admin:
            logger.warning("Default bootstrap admin not found; proceeding with unassigned creator.")

        svc = CatalogueService(session)
        result = await svc.ensure_default_catalogue(admin_user=admin)

        print("\n" + "=" * 60)
        print("BRIGHTLOOP DEFAULT CATALOGUE SETUP SUMMARY")
        print("=" * 60)
        print(f"Products Created ({len(result['products_created'])}):")
        for p in result["products_created"]:
            print(f"  + [{p['sku']}] {p['name']} (ID: {p['id']})")

        print(f"\nExisting Products Preserved ({len(result['existing_products'])}):")
        for p in result["existing_products"]:
            print(f"  • [{p['sku']}] {p['name']} (ID: {p['id']})")

        print(f"\nSubscription Plans Created ({len(result['plans_created'])}):")
        for pl in result["plans_created"]:
            print(f"  + [{pl['code']}] {pl['name']} (ID: {pl['id']})")

        print(f"\nExisting Subscription Plans Preserved ({len(result['existing_plans'])}):")
        for pl in result["existing_plans"]:
            print(f"  • [{pl['code']}] {pl['name']} (ID: {pl['id']})")

        print("=" * 60 + "\n")
        logger.info("Default catalogue setup completed successfully.")


if __name__ == "__main__":
    asyncio.run(main())
