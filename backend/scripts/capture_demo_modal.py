import asyncio
import os
from playwright.async_api import async_playwright

OUTPUT_DIR = "/home/z/.gemini/antigravity/brain/a334f46f-9220-447b-80d1-663fcf33ea05/screenshots"


async def main():
    async with async_playwright() as p:
        browser = await p.firefox.launch(headless=True)
        context = await browser.new_context(viewport={"width": 1440, "height": 900})
        page = await context.new_page()

        # Login
        await page.goto("http://localhost:5173/login")
        await page.wait_for_selector('input[type="email"]')
        await page.fill('input[type="email"]', "admin@brightloop.com")
        await page.fill('input[type="password"]', "Brightloop#Admin2026")
        await page.click('button[type="submit"]')
        await page.wait_for_selector("text=Executive Financial & Operations Overview", timeout=15000)
        await asyncio.sleep(1)

        # 1. Subscriptions Details & Extended Lifecycle Controls
        print("[*] Navigating to Subscriptions...")
        await page.click("aside >> text=Subscriptions")
        await page.wait_for_selector("text=Subscription Registry", timeout=10000)
        await asyncio.sleep(1)
        sub_link = page.locator('a[href^="/subscriptions/"]').first
        if await sub_link.count():
            await sub_link.click()
            await page.wait_for_selector("text=Plan:", timeout=10000)
            await asyncio.sleep(1.5)
            await page.screenshot(path=os.path.join(OUTPUT_DIR, "15_subscription_lifecycle_controls.png"))
            print("  [✓] Captured 15_subscription_lifecycle_controls.png")

        # 2. Invoices & Demo Payment Modal
        print("[*] Navigating to Invoices...")
        await page.click("aside >> text=Invoices & Billing")
        await page.wait_for_selector("text=Invoices & Billing Ledger", timeout=10000)
        await asyncio.sleep(1)

        # Look for UNPAID or PARTIALLY PAID row
        unpaid_row = page.locator('tr:has-text("UNPAID") >> a[href^="/invoices/"]').first
        if not await unpaid_row.count():
            unpaid_row = page.locator('tr:has-text("PARTIALLY") >> a[href^="/invoices/"]').first
        if not await unpaid_row.count():
            unpaid_row = page.locator('a[href^="/invoices/"]').first

        if await unpaid_row.count():
            await unpaid_row.click()
            await page.wait_for_selector("text=Brightloop Software", timeout=10000)
            await asyncio.sleep(1.5)

            demo_btn = page.locator('button:has-text("Pay via Demo Gateway")')
            if await demo_btn.count() and await demo_btn.is_visible():
                print("[*] Opening Demo Payment Modal...")
                await demo_btn.click()
                await page.wait_for_selector("text=DEMO MODE — SIMULATED PAYMENT", timeout=6000)
                await asyncio.sleep(1.5)
                await page.screenshot(path=os.path.join(OUTPUT_DIR, "17_demo_payment_checkout_modal.png"))
                print("  [✓] Captured 17_demo_payment_checkout_modal.png")

        await browser.close()
        print("[+] Finished capturing remaining screenshots!")


if __name__ == "__main__":
    asyncio.run(main())
