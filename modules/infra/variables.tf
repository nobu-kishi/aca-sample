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

variable "vm_size" {
  description = "仮想マシンのサイズ"
  type        = string
  default     = "Standard_B1s"
}

variable "postgresql_admin_user" {
  default = "postgres"
}

variable "postgresql_admin_password" {
  sensitive = true
  default   = "passw0rd"
}