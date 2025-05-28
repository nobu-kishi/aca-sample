output "vnet_id" {
  description = "VNetのID"
  value       = azurerm_virtual_network.vnet.id
}

output "appgw_subnet_id" {
  description = "AppGWのサブネットID"
  value       = azurerm_subnet.appgw_subnet.id
}

output "aca_subnet_id" {
  description = "ACAのサブネットID"
  value       = azurerm_subnet.aca_subnet.id
}

output "linux_vm_ids" {
  description = "Linux仮想マシンのID一覧"
  value       = module.vms.linux_vm_ids
}

output "windows_vm_ids" {
  description = "Windows仮想マシンのID一覧"
  value       = module.vms.windows_vm_ids
}


output "pe_aca_env_subnet_id" {
  description = "プライベートエンドポイント用のサブネットID"
  value       = azurerm_subnet.pe_aca_env_subnet.id
}

output "storage_share_name" {
  description = "Azure Filesの名称"
  value       = azurerm_storage_share.shared.name
}