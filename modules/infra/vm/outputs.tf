output "linux_vm_ids" {
  description = "Linux仮想マシンのID一覧"
  value       = [for vm in azurerm_linux_virtual_machine.vm_linux : vm.id]
}

output "windows_vm_ids" {
  description = "Windows仮想マシンのID一覧"
  value       = [for vm in azurerm_windows_virtual_machine.vm_windows : vm.id]
}