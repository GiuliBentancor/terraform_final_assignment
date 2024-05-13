
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

module "frontend_lb" {
 source = "./modules/custom_lb"
 port = var.frontend_port
 resource_group_name = var.resource_group_name
 location = var.location
 name_lb = "Public_LoadBalancer"
}

module "backend_lb" {
 source = "./modules/custom_lb"
 port = var.backend_port
 resource_group_name = var.resource_group_name
 location = var.location
 name_lb = "Internal_LoadBalancer"
}

module "frontend_vms" {
  source = "./modules/custom_vm"
  number_of_instances = var.number_of_frontend_instances
  size = var.frontend_vm_size
  resource_group_name = var.resource_group_name
  location = var.location
  subnet_name = azurerm_subnet.Frontend_subnet.name
  subnet_id = azurerm_subnet.Frontend_subnet.id
  pool_address_id = module.frontend_lb.pool_id
}

module "backend_vms" {
  source = "./modules/custom_vm"
  number_of_instances = var.number_of_backend_instances
  size = var.backend_vm_size
  resource_group_name = var.resource_group_name
  location = var.location
  subnet_name = azurerm_subnet.Backend_subnet.name
  subnet_id = azurerm_subnet.Backend_subnet.id
  pool_address_id = module.backend_lb.pool_id
}