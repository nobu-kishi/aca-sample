variable "env" {
  description = "環境名"
  type        = string
}

variable "subscription_id" {
  description = "サブスクリプションID"
  type        = string
  default     = "b17158f1-9101-4ce3-9224-19e1561bbd4b"
}

variable "location" {
  description = "Azureのリージョン"
  type        = string
  default     = "Japan East"
}

variable "resource_group_name" {
  description = "リソースグループ名"
  type        = string
  default     = "aca-appgw-rg"
}

variable "subnet_cidr_map" {
  description = "各サブネットのIPレンジ一覧"
  type        = map(string)
}

variable "acr_name" {
  description = "ACR名"
  type        = string
  default     = "acaregistry"
}

variable "aca_env_name" {
  description = "ACAの環境名"
  type        = string
  default     = "aca-env"
}

variable "aca_profile_name" {
  description = "ACAのプロファイル名"
  type        = string
  default     = "aca-profile"
}

variable "app_gateway_name" {
  description = "Application Gateway名"
  type        = string
  default     = "aca-appgw"
}

variable "backend_services" {
  description = "バックエンドサービスの一覧とポート設定"
  type = map(object({
    # fqdn = string
    port = number
    name = string
  }))
}

variable "vnet_address_space" {
  description = "仮想ネットワークのアドレス空間"
  type        = list(string)
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