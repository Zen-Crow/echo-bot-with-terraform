variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  default     = null
}

variable "folder_id" {
  type        = string
  description = "Yandex Folder ID"
  default     = null
}

variable "zone" {
  type        = string
  description = "Yandex Zone"
  default     = "ru-central1-a"
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud iam token"
  default     = null
}

variable "telegram_token" {
  type        = string
  description = "Telegram bot token"
}
