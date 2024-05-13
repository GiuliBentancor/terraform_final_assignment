
resource "azurerm_virtual_network" "App_VNET" {
  name                = "App_VNET"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "Frontend_subnet" {
  name                 = "Frontend_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.App_VNET.name
  address_prefixes     = var.frontend_subnet_address_space
}

resource "azurerm_subnet" "Backend_subnet" {
  name                 = "Backend_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.App_VNET.name
  address_prefixes     = var.backend_subnet_address_space
}

resource "azurerm_public_ip" "Frontend_IP_LB" {
  name                = "Frontend_IP_LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "Backend_IP_LB" {
  name                = "Backend_IP_LB"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "public_lb" {
  name                = "Frontend_PublicLoadbalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.Frontend_IP_LB.id
  }
}

resource "azurerm_lb" "internal_lb" {
  name                = "Backend_InternalLoadbalancer"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "InternalIPAddress"
    public_ip_address_id = azurerm_public_ip.Backend_IP_LB.id
  }
}

resource "azurerm_lb_probe" "frontend_lb_probe" {
  loadbalancer_id = azurerm_lb.public_lb.id
  name            = "frontend-probe"
  port            = var.frontend_port
}

resource "azurerm_lb_probe" "backend_lb_probe" {
  loadbalancer_id = azurerm_lb.internal_lb.id
  name            = "backend-probe"
  port            = var.backend_port
}

resource "azurerm_lb_backend_address_pool" "public_lb_pool" {
  name                = "public-lb-pool"
  loadbalancer_id     = azurerm_lb.public_lb.id
}

resource "azurerm_lb_backend_address_pool" "internal_lb_pool" {
  name                = "internal-lb-pool"
  loadbalancer_id     = azurerm_lb.internal_lb.id
}

resource "azurerm_lb_rule" "FE_lb_rule" {
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "PublicBalancer-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.public_lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.frontend_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.public_lb_pool.id]
}

resource "azurerm_lb_rule" "BE_lb_rule" {
  loadbalancer_id                = azurerm_lb.internal_lb.id
  name                           = "InternalBalancer-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.internal_lb.frontend_ip_configuration[0].name
  probe_id                       = azurerm_lb_probe.backend_lb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.internal_lb_pool.id]
}

resource "azurerm_network_security_group" "Frontend_NSG" {
  name                = "Frontend_NSG"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "Backend_NSG" {
  name                = "Backend_NSG"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "NSG_Subnet_association_FE" {
  subnet_id                 = azurerm_subnet.Frontend_subnet.id
  network_security_group_id = azurerm_network_security_group.Frontend_NSG.id
}

resource "azurerm_subnet_network_security_group_association" "NSG_Subnet_association_BE" {
  subnet_id                 = azurerm_subnet.Backend_subnet.id
  network_security_group_id = azurerm_network_security_group.Backend_NSG.id
}

module "frontend_vms" {
  source = "./modules/custom_vm"
  number_of_instances = var.number_of_frontend_instances
  size = var.frontend_vm_size
  resource_group_name = var.resource_group_name
  location = var.location
  subnet_name = azurerm_subnet.Frontend_subnet.name
  subnet_id = azurerm_subnet.Frontend_subnet.id
  pool_address_id = azurerm_lb_backend_address_pool.public_lb_pool.id
}

module "backend_vms" {
  source = "./modules/custom_vm"
  number_of_instances = var.number_of_backend_instances
  size = var.backend_vm_size
  resource_group_name = var.resource_group_name
  location = var.location
  subnet_name = azurerm_subnet.Backend_subnet.name
  subnet_id = azurerm_subnet.Backend_subnet.id
  pool_address_id = azurerm_lb_backend_address_pool.internal_lb_pool.id
}