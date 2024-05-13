variable "size" {
     type    = string
}

variable "location" {
     type = string
}

variable "resource_group_name" {
     type = string
}

variable "subnet_id" {
     type = string 
}

variable "number_of_instances" {
     type = number
}

## Others
variable "adminusername_vm" {
     type    = string
     default = "adminuser"
}

variable "computername_vm" { 
     type = string 
     default = "finaltask"
}

variable "pool_address_id" {
     type =string 
}

variable "subnet_name" {
     type = string
}