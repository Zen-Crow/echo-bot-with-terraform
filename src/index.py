import os
import requests
import json

TOKEN = os.getenv('TELEGRAM_TOKEN')

# send message function
def send_message(chat_id, text):
    url = "https://api.telegram.org/bot%s/sendMessage" % (TOKEN)
    data = {'chat_id': chat_id, 'text': text}
    res = requests.post(url, data=data)
    return res


# функция, которая обрабатывает входящие сообщения от Telegram
def handler(event, context):
    try:
        body = json.loads(event['body'])
        chat_id = body['message']['from']['id']
        text_from_user = body['message']['text']

        print(body)
        print(text_from_user)

        send_message(chat_id, text_from_user)
        res = {'statusCode': 200, 'body': 'Message sent'}

    except Exception as e:
        res = {'statusCode': 404, 'body': 'Same error'}

    return res