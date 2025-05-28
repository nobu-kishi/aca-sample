variable "location" {
  description = "リソースの場所（リージョン）"
  type        = string
}

variable "resource_group_name" {
  description = "対象リソースグループの名前"
  type        = string
}

variable "subnet_id" {
  description = "NICが接続されるサブネットID"
  type        = string
}

variable "vm_config" {
  description = "仮想マシンの設定"
  type = object({
    linux = list(object({
      name           = string
      vm_size        = optional(string, "Standard_B1s")
      admin_username = optional(string, "azureuser")
    }))
    windows = list(object({
      name           = string
      vm_size        = optional(string, "Standard_DS1_v2")
      admin_username = optional(string, "azureuser")
      admin_password = optional(string, "P@ssw0rd1234")
    }))
  })
}
