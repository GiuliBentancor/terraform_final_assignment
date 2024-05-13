output "vms_private_ip_addresses" {
  value = azurerm_linux_virtual_machine.azure_vm[*].private_ip_addresses
}