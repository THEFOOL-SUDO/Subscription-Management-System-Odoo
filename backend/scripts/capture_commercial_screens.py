import asyncio
import os
from playwright.async_api import async_playwright

SCREENSHOTS_DIR = "/home/z/.gemini/antigravity/brain/a334f46f-9220-447b-80d1-663fcf33ea05/screenshots"
BASE_URL = "http://localhost:5173"


async def main():
    os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
    async with async_playwright() as p:
        print("[*] Launching Firefox headless...")
        browser = await p.firefox.launch(headless=True)
        context = await browser.new_context(viewport={"width": 1440, "height": 900})
        page = await context.new_page()

        page.on("console", lambda msg: print(f"[Browser Console] {msg.type}: {msg.text}"))
        page.on("pageerror", lambda err: print(f"[Browser PageError] {err}"))

        print("[*] Logging in as Administrator...")
        await page.goto(f"{BASE_URL}/login")
        await page.wait_for_selector('input[type="email"]', timeout=10000)
        await page.fill('input[type="email"]', "admin@brightloop.com")
        await page.fill('input[type="password"]', "Brightloop#Admin2026")
        await page.click('button[type="submit"]')

        # Wait for dashboard
        await page.wait_for_selector("text=Executive Financial & Operations Overview", timeout=15000)
        await asyncio.sleep(1.5)
        print("[✓] Login successful.")

        # 1. Quotations via Sidebar
        print("[*] Navigating to Quotations via sidebar...")
        quotation_nav = page.locator("aside >> text=Quotations").first
        if await quotation_nav.is_visible():
            await quotation_nav.click()
        else:
            await page.goto(f"{BASE_URL}/quotations")

        await page.wait_for_selector("text=Quotation Templates", timeout=10000)
        await asyncio.sleep(1.5)
        await page.screenshot(path=f"{SCREENSHOTS_DIR}/11_quotation_templates.png")
        print("  [✓] Captured 11_quotation_templates.png")

        # 2. Quotation Convert Modal
        convert_btn = page.locator("button:has-text('Convert to Subscription')").first
        if await convert_btn.is_visible():
            print("[*] Capturing 12_quotation_convert_modal.png...")
            await convert_btn.click()
            await page.wait_for_selector("h3:has-text('Convert Quotation to Subscription')", timeout=5000)
            await asyncio.sleep(0.8)
            await page.screenshot(path=f"{SCREENSHOTS_DIR}/12_quotation_convert_modal.png")
            print("  [✓] Captured 12_quotation_convert_modal.png")
            # Close modal
            close_btn = page.locator("button:has-text('Cancel')").first
            await close_btn.click()
            await asyncio.sleep(0.5)

        # 3. Discounts via Sidebar
        print("[*] Capturing Discounts & Promos...")
        disc_nav = page.locator("aside >> text=Discounts & Promos").first
        if await disc_nav.is_visible():
            await disc_nav.click()
        else:
            await page.goto(f"{BASE_URL}/discounts")
        await page.wait_for_selector("text=Discount & Promo Rules", timeout=10000)
        await asyncio.sleep(1.2)
        await page.screenshot(path=f"{SCREENSHOTS_DIR}/13_discounts_promos.png")
        print("  [✓] Captured 13_discounts_promos.png")

        # 4. Tax Schedules via Sidebar
        print("[*] Capturing Tax Schedules...")
        tax_nav = page.locator("aside >> text=Tax Schedules").first
        if await tax_nav.is_visible():
            await tax_nav.click()
        else:
            await page.goto(f"{BASE_URL}/taxes")
        await page.wait_for_selector("text=Tax Configurations", timeout=10000)
        await asyncio.sleep(1.2)
        await page.screenshot(path=f"{SCREENSHOTS_DIR}/14_tax_schedules.png")
        print("  [✓] Captured 14_tax_schedules.png")

        # 5. Subscriptions Registry
        print("[*] Capturing Subscriptions...")
        await page.click("aside >> text=Subscriptions")
        await page.wait_for_selector("table", timeout=10000)
        await asyncio.sleep(1.0)
        details_link = page.locator("a:has-text('Details')").first
        if await details_link.is_visible():
            await details_link.click()
            await page.wait_for_selector("text=ID:", timeout=10000)
            await asyncio.sleep(1.2)
            await page.screenshot(path=f"{SCREENSHOTS_DIR}/15_subscription_lifecycle_controls.png")
            print("  [✓] Captured 15_subscription_lifecycle_controls.png")

        # 6. Invoices & Billing
        print("[*] Capturing Invoices & Demo Payment Action...")
        await page.click("aside >> text=Invoices & Billing")
        await page.wait_for_selector("table", timeout=10000)
        await asyncio.sleep(1.0)
        inv_details = page.locator("a:has-text('Details')").first
        if await inv_details.is_visible():
            await inv_details.click()
            await page.wait_for_selector("text=Brightloop Software", timeout=10000)
            await asyncio.sleep(1.2)
            await page.screenshot(path=f"{SCREENSHOTS_DIR}/16_invoice_demo_payment_action.png")
            print("  [✓] Captured 16_invoice_demo_payment_action.png")

            # 7. Demo Payment Checkout Modal
            demo_pay_btn = page.locator("button:has-text('Pay via Demo Gateway')").first
            if await demo_pay_btn.is_visible():
                print("[*] Capturing 17_demo_payment_checkout_modal.png...")
                await demo_pay_btn.click()
                await page.wait_for_selector("text=DEMO MODE — SIMULATED PAYMENT", timeout=6000)
                await asyncio.sleep(1.0)
                await page.screenshot(path=f"{SCREENSHOTS_DIR}/17_demo_payment_checkout_modal.png")
                print("  [✓] Captured 17_demo_payment_checkout_modal.png")

        await browser.close()
        print("[✓] All commercial elevation screenshots captured successfully!")


if __name__ == "__main__":
    asyncio.run(main())
