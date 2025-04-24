
variable "resource_group_name" {
  description = "ネットワーク用リソースグループ名（Application Gateway配置先）"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "env" {
  description = "環境名"
  type        = string
}

variable "subnet_id" {
  description = "Application Gateway用サブネットID"
  type        = string
}

variable "app_gateway_name" {
  description = "Application Gateway名"
  type        = string
}

variable "backend_services" {
  description = "バックエンドサービスの一覧とポート設定"
  type = map(object({
    port = number
    name = string
  }))
}

variable "aca_apps" {
  description = "ACAアプリのマップ (appモジュールから受け取る)"
  type        = any # 動的マップなのでany型で受け取るのが簡単
}