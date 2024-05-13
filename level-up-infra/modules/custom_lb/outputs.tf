output "lb_public_ip" {
  value = azurerm_lb.load_balancer.frontend_ip_configuration[0].public_ip_address_id
}

output "pool_id" {
  value = azurerm_lb_backend_address_pool.lb_pool.id
}