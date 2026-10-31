import asyncio
import os
import sys
from playwright.async_api import async_playwright

OUTPUT_DIR = "/home/z/.gemini/antigravity/brain/a334f46f-9220-447b-80d1-663fcf33ea05/screenshots"
os.makedirs(OUTPUT_DIR, exist_ok=True)


async def main():
    async with async_playwright() as p:
        print("[*] Launching Firefox headless...")
        browser = await p.firefox.launch(headless=True)
        context = await browser.new_context(viewport={"width": 1440, "height": 900})
        page = await context.new_page()

        # 1. Login Page
        print("[*] Navigating to Login...")
        await page.goto("http://localhost:5173/login")
        await page.wait_for_selector('input[type="email"]')
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "00_login_page.png"))
        print("  [✓] Captured 00_login_page.png")

        # Fill credentials and login
        await page.fill('input[type="email"]', "admin@brightloop.com")
        await page.fill('input[type="password"]', "Brightloop#Admin2026")
        await page.click('button[type="submit"]')

        # 2. Executive Dashboard
        print("[*] Waiting for Executive Dashboard...")
        await page.wait_for_selector("text=Executive Financial & Operations Overview", timeout=15000)
        await asyncio.sleep(2)  # allow Recharts animations to complete
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "01_executive_dashboard.png"))
        print("  [✓] Captured 01_executive_dashboard.png")

        # 3. Products Catalog via Sidebar Navigation
        print("[*] Navigating to Products Catalog...")
        await page.click("aside >> text=Products")
        await page.wait_for_selector("text=Product Catalog", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "02_products_catalog.png"))
        print("  [✓] Captured 02_products_catalog.png")

        # 4. Subscription Plans via Sidebar Navigation
        print("[*] Navigating to Subscription Plans...")
        await page.click("aside >> text=Subscription Plans")
        await page.wait_for_selector("text=Subscription Plans", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "03_subscription_plans.png"))
        print("  [✓] Captured 03_subscription_plans.png")

        # 5. Customers Directory via Sidebar Navigation
        print("[*] Navigating to Customer Directory...")
        await page.click("aside >> text=Customer Directory")
        await page.wait_for_selector("text=Customer Directory", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "04_customers_directory.png"))
        print("  [✓] Captured 04_customers_directory.png")

        # 6. Subscriptions Registry via Sidebar Navigation
        print("[*] Navigating to Subscriptions Registry...")
        await page.click("aside >> text=Subscriptions")
        await page.wait_for_selector("text=Subscription Registry", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "05_subscriptions_registry.png"))
        print("  [✓] Captured 05_subscriptions_registry.png")

        # 7. Invoices Ledger via Sidebar Navigation
        print("[*] Navigating to Invoices Ledger...")
        await page.click("aside >> text=Invoices & Billing")
        await page.wait_for_selector("text=Invoices & Billing Ledger", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "06_invoices_ledger.png"))
        print("  [✓] Captured 06_invoices_ledger.png")

        # 8. Invoice Details View
        print("[*] Navigating to Invoice Details...")
        await page.click('a[href^="/invoices/"] >> nth=0')
        await page.wait_for_selector("text=Invoice Statement", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "07_invoice_details.png"))
        print("  [✓] Captured 07_invoice_details.png")

        # 9. Record Payment Modal on an Unpaid Invoice
        print("[*] Checking for Record Payment modal...")
        payment_btn = page.locator('button:has-text("Record Payment")')
        if not await payment_btn.count():
            # Go back to invoices ledger and find an unpaid invoice
            await page.click("aside >> text=Invoices & Billing")
            await page.wait_for_selector("text=Invoices & Billing Ledger")
            # Click row with UNPAID
            unpaid_link = page.locator('tr:has-text("UNPAID") >> a[href^="/invoices/"]').first
            if await unpaid_link.count():
                await unpaid_link.click()
                await page.wait_for_selector("text=Invoice Statement")
                payment_btn = page.locator('button:has-text("Record Payment")')

        if await payment_btn.count() and await payment_btn.is_visible():
            await payment_btn.click()
            await page.wait_for_selector('h2:has-text("Record Payment")', timeout=5000)
            await asyncio.sleep(1)
            await page.screenshot(path=os.path.join(OUTPUT_DIR, "08_record_payment_modal.png"))
            print("  [✓] Captured 08_record_payment_modal.png")
            # Close modal
            await page.click('button:has-text("Cancel")')

        # 10. Subscription Catalogue View (Admin)
        print("[*] Navigating to Subscription Catalogue...")
        await page.click("aside >> text=Catalogue")
        await page.wait_for_selector("text=Subscription & Product Catalogue", timeout=10000)
        await asyncio.sleep(2)
        await page.screenshot(path=os.path.join(OUTPUT_DIR, "09_subscription_catalogue_admin.png"))
        print("  [✓] Captured 09_subscription_catalogue_admin.png")

        # 11. Subscription Creation from Catalogue with prefilled plan
        print("[*] Opening Create Subscription from Catalogue card...")
        create_sub_btn = page.locator('button:has-text("Create Subscription")').first
        if await create_sub_btn.count():
            await create_sub_btn.click()
            await page.wait_for_selector('h2:has-text("Create Subscription")', timeout=5000)
            await asyncio.sleep(1.5)
            await page.screenshot(path=os.path.join(OUTPUT_DIR, "10_catalogue_prefilled_subscription_modal.png"))
            print("  [✓] Captured 10_catalogue_prefilled_subscription_modal.png")
            await page.click('button:has-text("Cancel")')

        print("[+] All UI evidence screenshots successfully captured!")
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
