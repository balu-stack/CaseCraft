import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv
from pathlib import Path

# ✅ ensure correct .env path
env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(dotenv_path=env_path)

SMTP_EMAIL = os.getenv("SMTP_EMAIL")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")


def send_email(to_email: str, subject: str, body: str):

    msg = MIMEMultipart()
    msg["From"] = SMTP_EMAIL
    msg["To"] = to_email
    msg["Subject"] = subject

    msg.attach(MIMEText(body, "plain"))

    try:
        server = smtplib.SMTP("smtp.gmail.com", 587)
        server.starttls()

        server.login(SMTP_EMAIL, SMTP_PASSWORD)

        server.sendmail(SMTP_EMAIL, to_email, msg.as_string())

        server.quit()

        print("✅ OTP email sent")

    except Exception as e:
        print("❌ Email send failed:", e)