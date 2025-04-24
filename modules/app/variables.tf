variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "env" {
  description = "環境名"
  type        = string
}

variable "subnet_id" {
  description = "ACA環境用のサブネットID"
  type        = string
}

variable "acr_name" {
  description = "ACR名"
  type        = string
}

variable "aca_env_name" {
  description = "ACA環境名"
  type        = string
}

variable "container_apps" {
  description = "デプロイするコンテナアプリの設定"
  type = map(object({
    image  = string
    cpu    = number
    memory = string
    port   = number
  }))
}