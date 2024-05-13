output "frontend_lb_public_ip" {
  value = module.level-up-infra-dev.frontend_lb_public_ip
}

output "frontend_vms_private_ip_addresses" {
  value = module.level-up-infra-dev.frontend_vms_private_ip_addresses
}

output "backend_vms_private_ip_addresses" {
  value = module.level-up-infra-dev.backend_vms_private_ip_addresses
}


