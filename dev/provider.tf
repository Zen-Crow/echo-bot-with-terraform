terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.129.0"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}


provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  token     = var.yc_token
  zone      = var.zone
}

locals {
  telegram_token = var.yc_token
}
