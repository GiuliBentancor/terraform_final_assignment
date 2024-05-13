 variable use_existing_rg {
    type = bool
  }

  variable resource_group_name {
    type= string
  }

  variable location {
    type = string
  }

  variable vnet_address_space {
    type = list(string)
  }

  variable "number_of_frontend_instances" {
    type = number 
  }

  variable frontend_vm_size {
    type = string
  }

  variable frontend_port {
    type = number
  }

  variable frontend_subnet_address_space {
    type = list(string)

  }

  variable number_of_backend_instances {
    type = number
  }

  variable backend_vm_size {
    type = string
  }

  variable backend_port {
    type = number
  } 

  variable backend_subnet_address_space {
    type = list(string)
  }