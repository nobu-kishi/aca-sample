resource "azurerm_network_interface" "vm_nic" {
  for_each = {
    for vm in concat(var.vm_config.linux, var.vm_config.windows) :
    vm.name => vm
  }

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Linux VMの設定
resource "azurerm_linux_virtual_machine" "vm_linux" {
  for_each = { for vm in var.vm_config.linux : vm.name => vm }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.vm_size
  computer_name       = each.value.name
  admin_username      = each.value.admin_username
  provision_vm_agent  = true
  custom_data         = base64encode(templatefile("${path.module}/init.sh", {}))
  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = tls_private_key.ssh_bastion[0].public_key_openssh
  }
}

resource "tls_private_key" "ssh_bastion" {
  count     = length(var.vm_config.linux) > 0 ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  count = length(var.vm_config.linux) > 0 ? 1 : 0

  filename        = "${path.module}/../../../bas_ssh_key.pem"
  content         = tls_private_key.ssh_bastion[0].private_key_pem
  file_permission = "0600"
}


# Windows VMの設定
resource "azurerm_windows_virtual_machine" "vm_windows" {
  for_each = { for vm in var.vm_config.windows : vm.name => vm }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.vm_size
  computer_name       = each.value.name
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [
    azurerm_network_interface.vm_nic[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

