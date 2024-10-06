### Datasource
data "yandex_client_config" "client" {}

### Service account
resource "yandex_iam_service_account" "sa-for-serverless" {
  name        = "sa-for-function"
  description = "service account for Serverless Function"
}

### Set permissions API-gateway
resource "yandex_resourcemanager_folder_iam_member" "api_admin" {
  folder_id = data.yandex_client_config.client.folder_id
  role      = "api-gateway.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-for-serverless.id}"
}

### Set permissions for Telegram-bot
resource "yandex_function_iam_binding" "function_iam_bot" {
  function_id = yandex_function.function.id
  role        = "functions.functionInvoker"
  members = [
    "system:allUsers",
  ]
}

### Set permissions for Webhook
resource "yandex_function_iam_binding" "function_iam_webhook" {
  function_id = yandex_function.function_webhook.id
  role        = "functions.functionInvoker"
  members = [
    "system:allUsers",
  ]
}

### API-Gateway
resource "yandex_api_gateway" "api_gt" {
  name        = "bot-api-gateway"
  folder_id   = data.yandex_client_config.client.folder_id
  description = "API Gateway для обработки вебхуков Telegram"

  spec = <<-EOT
    openapi: 3.0.0
    info:
      title: bot-apigw
      version: 1.0.0
    paths:
      /forwebhook:
        post:
          x-yc-apigateway-integration:
            type: cloud-functions
            function_id: ${yandex_function.function.id}
            service_account_id: ${yandex_iam_service_account.sa-for-serverless.id}
          operationId: bot-function
  EOT
}

### Telegram-bot main function
resource "yandex_function" "function_bot" {
  folder_id         = data.yandex_client_config.client.folder_id
  name              = "serverless-function"
  user_hash         = "ver1"
  tags              = ["my-tag"]
  description       = "Call function Telegram bot"
  runtime           = "python312"
  entrypoint        = "index.handler"
  memory            = 256
  execution_timeout = 10

  service_account_id = yandex_iam_service_account.sa-for-serverless.id

  content {
    zip_filename = "../bot/index.zip"
  }

  environment = {
    TELEGRAM_TOKEN = var.telegram_token
  }
}

### set Webhook
resource "yandex_function" "function_webhook" {
  folder_id         = data.yandex_client_config.client.folder_id
  name              = "serverless-function-webhook"
  user_hash         = "ver10"
  tags              = ["my-tag10"]
  description       = "set Webhook Telegram bot"
  runtime           = "python312"
  entrypoint        = "webhook.main"
  memory            = 256
  execution_timeout = 10

  service_account_id = yandex_iam_service_account.sa-for-serverless.id

  content {
    zip_filename = "../bot/webhook.zip"
  }

  environment = {
    TELEGRAM_TOKEN = var.telegram_token
    API_GATEWAY_ID = yandex_api_gateway.api_gt.id
  }
}

### Trigger for Webhook
resource "yandex_function_trigger" "webhook_trigger" {
  folder_id   = data.yandex_client_config.client.folder_id
  name        = "webhook-trigger"
  description = "trigger for set webhook"

  timer {
    cron_expression = "* * * * ? *"
    payload         = "webhook was is set"
  }

  function {
    id                 = yandex_function.function_webhook.id
    service_account_id = yandex_iam_service_account.sa-for-serverless.id
  }

  depends_on = [
    yandex_iam_service_account.sa-for-serverless,
    yandex_function_iam_binding.function_iam_webhook,
    yandex_function_iam_binding.function_iam_bot
  ]
}

### Wait for the trigger job to complete
resource "time_sleep" "this" {
  create_duration = "120s"
  depends_on      = [yandex_function_trigger.webhook_trigger]
}

### null_resource for delete trigger
resource "null_resource" "delete_trigger" {
  triggers = {
    webhook_trigger_id = yandex_function_trigger.webhook_trigger.id
  }

  provisioner "local-exec" {
    command = "yc serverless trigger delete --id ${yandex_function_trigger.webhook_trigger.id}"
  }
  depends_on = [time_sleep.this]
}
