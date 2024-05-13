output "frontend_lb_public_ip" {
  value = azurerm_lb.public_lb.frontend_ip_configuration[0].public_ip_address_id
}

output "frontend_vms_private_ip_addresses" {
  value = module.frontend_vms.vms_private_ip_addresses
}

output "backend_vms_private_ip_addresses" {
  value = module.backend_vms.vms_private_ip_addresses
}