import logging
from email.message import EmailMessage
import aiosmtplib
from app.config import settings

logger = logging.getLogger(__name__)


class EmailService:
    @staticmethod
    async def send_email(
        recipient_email: str,
        subject: str,
        html_content: str,
        text_content: str = "",
    ) -> bool:
        """Send an email asynchronously via configured SMTP/Mailpit server."""
        try:
            message = EmailMessage()
            message["From"] = f"{settings.EMAILS_FROM_NAME} <{settings.EMAILS_FROM_EMAIL}>"
            message["To"] = recipient_email
            message["Subject"] = subject

            if text_content:
                message.set_content(text_content)
                message.add_alternative(html_content, subtype="html")
            else:
                message.set_content(html_content, subtype="html")

            await aiosmtplib.send(
                message,
                hostname=settings.SMTP_HOST,
                port=settings.SMTP_PORT,
                username=settings.SMTP_USER or None,
                password=settings.SMTP_PASSWORD or None,
                use_tls=False,
                start_tls=False,
                timeout=5.0,
            )
            logger.info("Successfully dispatched email to %s (Subject: %s)", recipient_email, subject)
            return True
        except Exception as exc:
            logger.warning("Failed to dispatch email to %s via SMTP (%s:%s): %s",
                           recipient_email, settings.SMTP_HOST, settings.SMTP_PORT, exc)
            return False

    @classmethod
    async def send_password_reset_email(cls, recipient_email: str, reset_token: str, full_name: str) -> bool:
        reset_url = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
        subject = "Reset your Brightloop password"
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; color: #1e293b; padding: 24px; }}
            .container {{ max-width: 540px; margin: 0 auto; background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 32px; }}
            .button {{ display: inline-block; padding: 12px 24px; background-color: #0f172a; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: 500; margin-top: 16px; margin-bottom: 16px; }}
            .footer {{ font-size: 12px; color: #64748b; margin-top: 24px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <h2 style="margin-top:0; color: #0f172a;">Password Reset Request</h2>
            <p>Hello {full_name},</p>
            <p>We received a request to reset the password for your Brightloop account. Click the button below to choose a new password:</p>
            <p style="text-align: center;">
              <a href="{reset_url}" class="button">Reset Password</a>
            </p>
            <p>This link is valid for <strong>{settings.PASSWORD_RESET_TOKEN_EXPIRE_MINUTES} minutes</strong> and can only be used once.</p>
            <p>If you didn't request a password reset, you can safely ignore this email; your account remains secure.</p>
            <div class="footer">
              <p>Brightloop Software — Subscription Management Platform</p>
              <p>If the button doesn't work, copy and paste this URL into your browser:<br><span style="word-break: break-all; color: #2563eb;">{reset_url}</span></p>
            </div>
          </div>
        </body>
        </html>
        """
        text_content = f"Hello {full_name},\n\nReset your Brightloop password using this link:\n{reset_url}\n\nThis link expires in {settings.PASSWORD_RESET_TOKEN_EXPIRE_MINUTES} minutes."
        return await cls.send_email(recipient_email, subject, html_content, text_content)

    @classmethod
    async def send_customer_activation_email(cls, recipient_email: str, reset_token: str, full_name: str) -> bool:
        activation_url = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
        subject = "Welcome to Brightloop — Set Up Your Account"
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; color: #1e293b; padding: 24px; }}
            .container {{ max-width: 540px; margin: 0 auto; background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 32px; }}
            .button {{ display: inline-block; padding: 12px 24px; background-color: #2563eb; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: 500; margin-top: 16px; margin-bottom: 16px; }}
            .footer {{ font-size: 12px; color: #64748b; margin-top: 24px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <h2 style="margin-top:0; color: #0f172a;">Welcome to Brightloop!</h2>
            <p>Hello {full_name},</p>
            <p>Your customer profile has been created in the Brightloop Subscription Management Platform. You can access your invoices, manage active subscriptions, and view quotations through your self-service portal.</p>
            <p>To get started and set your secure password, please click the button below:</p>
            <p style="text-align: center;">
              <a href="{activation_url}" class="button">Set Password &amp; Activate Account</a>
            </p>
            <p>This activation link is valid for <strong>24 hours</strong> and can only be used once.</p>
            <p>If you have any questions or did not expect this invitation, please contact your account manager.</p>
            <div class="footer">
              <p>Brightloop Software — Subscription Management Platform</p>
              <p>If the button doesn't work, copy and paste this URL into your browser:<br><span style="word-break: break-all; color: #2563eb;">{activation_url}</span></p>
            </div>
          </div>
        </body>
        </html>
        """
        text_content = f"Hello {full_name},\n\nWelcome to Brightloop! Your customer profile has been created.\nSet your secure password using this link:\n{activation_url}\n\nThis link is valid for 24 hours."
        return await cls.send_email(recipient_email, subject, html_content, text_content)

    @classmethod
    async def send_welcome_email(cls, recipient_email: str, full_name: str) -> bool:
        subject = "Welcome to Brightloop Software"
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; color: #1e293b; padding: 24px; }}
            .container {{ max-width: 540px; margin: 0 auto; background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 32px; }}
            .footer {{ font-size: 12px; color: #64748b; margin-top: 24px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <h2 style="margin-top:0; color: #0f172a;">Welcome to Brightloop!</h2>
            <p>Hello {full_name},</p>
            <p>Your customer account has been created. You now have access to your personal self-service portal to view quotations, manage subscriptions, and inspect invoices.</p>
            <p>Visit <a href="{settings.FRONTEND_URL}" style="color: #2563eb;">{settings.FRONTEND_URL}</a> to log in to your account.</p>
            <div class="footer">
              <p>Brightloop Software — Subscription Management Platform</p>
            </div>
          </div>
        </body>
        </html>
        """
        text_content = f"Hello {full_name},\n\nWelcome to Brightloop! Log in to your account at: {settings.FRONTEND_URL}"
        return await cls.send_email(recipient_email, subject, html_content, text_content)

    @classmethod
    async def send_invoice_email(
        cls,
        recipient_email: str,
        customer_name: str,
        invoice_number: str,
        total_amount: str,
        balance_due: str,
        currency: str,
        due_date: str,
    ) -> bool:
        subject = f"Invoice {invoice_number} from Brightloop Platform"
        pay_url = f"{settings.FRONTEND_URL}/portal/invoices"
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fafc; color: #0f172a; padding: 24px; }}
            .container {{ max-width: 560px; margin: 0 auto; background: #ffffff; border-radius: 8px; border: 1px solid #e2e8f0; padding: 32px; }}
            .header {{ border-bottom: 2px solid #4f46e5; padding-bottom: 16px; margin-bottom: 24px; }}
            .title {{ font-size: 20px; font-weight: 700; color: #0f172a; margin: 0; }}
            .meta-box {{ background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 16px; margin: 20px 0; }}
            .row {{ display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 14px; }}
            .total-row {{ font-weight: 700; font-size: 16px; border-top: 1px solid #cbd5e1; padding-top: 8px; margin-top: 8px; }}
            .btn {{ display: inline-block; padding: 12px 24px; background-color: #4f46e5; color: #ffffff !important; text-decoration: none; border-radius: 6px; font-weight: 600; margin: 16px 0; }}
            .footer {{ font-size: 12px; color: #64748b; margin-top: 28px; border-top: 1px solid #f1f5f9; padding-top: 16px; }}
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 class="title">BRIGHTLOOP PLATFORM</h1>
              <p style="color: #64748b; margin: 4px 0 0 0; font-size: 14px;">Executive Billing Intelligence</p>
            </div>
            <p>Dear {customer_name},</p>
            <p>A new invoice <strong>{invoice_number}</strong> has been generated for your active subscription service.</p>
            <div class="meta-box">
              <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                <tr><td style="padding: 4px 0; color: #64748b;">Invoice Number:</td><td style="text-align: right; font-weight: 600;">{invoice_number}</td></tr>
                <tr><td style="padding: 4px 0; color: #64748b;">Due Date:</td><td style="text-align: right;">{due_date}</td></tr>
                <tr><td style="padding: 4px 0; color: #64748b;">Total Amount:</td><td style="text-align: right;">{currency} {total_amount}</td></tr>
                <tr style="border-top: 1px solid #e2e8f0;"><td style="padding: 8px 0 0 0; font-weight: 700; color: #0f172a;">Balance Due:</td><td style="text-align: right; padding: 8px 0 0 0; font-weight: 700; color: #4f46e5;">{currency} {balance_due}</td></tr>
              </table>
            </div>
            <p style="text-align: center;">
              <a href="{pay_url}" class="btn">View & Pay Invoice in Portal</a>
            </p>
            <p style="font-size: 13px; color: #64748b;">You can settle this invoice securely through our portal using simulated demo cards, UPI, or corporate netbanking.</p>
            <div class="footer">
              <p>Brightloop Technologies Pvt Ltd — Enterprise Subscription OS</p>
              <p>Demo Billing Simulation Environment</p>
            </div>
          </div>
        </body>
        </html>
        """
        text_content = f"Invoice {invoice_number} from Brightloop Platform\n\nDear {customer_name},\n\nYour invoice {invoice_number} for {currency} {total_amount} (Balance Due: {currency} {balance_due}) is ready.\n\nView and pay online at: {pay_url}"
        return await cls.send_email(recipient_email, subject, html_content, text_content)
