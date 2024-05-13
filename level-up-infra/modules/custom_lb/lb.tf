resource "azurerm_public_ip" "public_ip" {
  name                = "public_ip-${var.name_lb}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "load_balancer" {
  name                = var.name_lb
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress-${var.name_lb}"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_probe" "probe_lb" {
  loadbalancer_id = azurerm_lb.load_balancer.id
  name            = "lb-probe-${var.name_lb}"
  port            = var.port
}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  name                = "lb-pool-${var.name_lb}"
  loadbalancer_id     = azurerm_lb.load_balancer.id
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.load_balancer.id
  name                           = "lb-rule-${var.name_lb}"
  protocol                       = "Tcp"
  frontend_port                  = var.port
  backend_port                   = var.port
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.load_balancer.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.probe_lb.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_pool.id]
}