output "aca_subnet_id" {
  description = "作成されたサブネットID"
  value       = azurerm_subnet.aca_subnet.id
}
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}