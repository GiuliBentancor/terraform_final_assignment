module "level-up-infra-dev" {
  source                        = "../level-up-infra"
  use_existing_rg               = true
  resource_group_name           = "test-rg"
  location                      = "East US"
  vnet_address_space            = ["10.0.0.0/16"]
  number_of_frontend_instances  = 2
  frontend_vm_size              = "Standard_A1_v2"
  frontend_port                 = 80
  frontend_subnet_address_space = ["10.0.0.0/24"]
  number_of_backend_instances   = 2
  backend_vm_size               = "Standard_A1_v2"
  backend_port                  = 80
  backend_subnet_address_space  = ["10.0.1.0/24"]
}


provider "azurerm" {
  skip_provider_registration = true
  features {}
}