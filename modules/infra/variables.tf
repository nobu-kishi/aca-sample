variable "env" {
  description = "環境名"
  type        = string
}

variable "resource_group_name" {
  description = "ネットワーク用のリソースグループ名"
  type        = string
}

variable "location" {
  description = "Azureリージョン"
  type        = string
}

variable "vnet_address_space" {
  description = "仮想ネットワークのアドレス空間"
  type        = list(string)
}

variable "subnet_cidr_map" {
  description = "各サブネットのIPレンジ一覧"
  type        = map(string)
}

variable "vm_config" {
  description = "仮想マシンの設定"
  type = object({
    linux = list(object({
      name           = string
      vm_size        = optional(string)
      admin_username = optional(string)
    }))
    windows = list(object({
      name           = string
      vm_size        = optional(string)
      admin_username = optional(string)
      admin_password = optional(string)
    }))
  })
}

variable "postgresql_admin_user" {
  type    = string
  default = "postgres"
}

variable "postgresql_admin_password" {
  type      = string
  sensitive = true
  default   = "passw0rd"
}

variable "storage_account_name" {
  description = "ストレージアカウント名"
  type        = string
}