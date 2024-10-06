import requests
import os


TELEGRAM_TOKEN = os.getenv("TELEGRAM_TOKEN")
API_GATEWAY = os.getenv("API_GATEWAY_ID")

TELEGRAM_BOT_URL = f"https://{API_GATEWAY}.apigw.yandexcloud.net/forwebhook"


def main(event, context):
    url = "https://api.telegram.org/bot{token}/{method}".format(
        token=TELEGRAM_TOKEN,
        method="setWebhook"
        # method="getWebhookinfo"
        # method = "deleteWebhook"
    )

    data = {"url": TELEGRAM_BOT_URL}

    response = requests.post(url, data=data)
    print(response.json())

    return {
        "statusCode": response.status_code, 
        "body": response.json()
    }

