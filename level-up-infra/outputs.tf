output "frontend_lb_public_ip" {
  value = module.frontend_lb.lb_public_ip
}

output "frontend_vms_private_ip_addresses" {
  value = module.frontend_vms.vms_private_ip_addresses
}

output "backend_vms_private_ip_addresses" {
  value = module.backend_vms.vms_private_ip_addresses
}