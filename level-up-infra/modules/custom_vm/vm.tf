resource "azurerm_network_interface" "azurerm_ni" {
  count = var.number_of_instances
  name                = "ni-${count.index}-${var.subnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ip-${count.index}-${var.subnet_name}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "azure_vm" {
  count = var.number_of_instances
  name                = "vm-${count.index}-${var.subnet_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = var.adminusername_vm
  computer_name       = var.computername_vm
  network_interface_ids = [
    azurerm_network_interface.azurerm_ni[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.adminusername_vm
    public_key = file("~/.ssh/azurecli.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "lb_ni_association" {
  count = var.number_of_instances
  network_interface_id= azurerm_network_interface.azurerm_ni[count.index].id
  ip_configuration_name = azurerm_network_interface.azurerm_ni[count.index].ip_configuration[0].name
  backend_address_pool_id = var.pool_address_id
}
