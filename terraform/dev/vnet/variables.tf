variable "location" {
  description = "Resource group for all resources."
}

variable "prefix" {
  description = "Name of the resource group"
}

variable "vnetAddress" {
    description = "Network address for vnet"
}

variable "aksSubnetAddress"{
    description = "Network subnet address for azure kubernetes service"
}

variable "svcSubnetAddress"{
    description = "Network subnet address for service"
}

variable "appgwSubnetAddress"{
    description = "Network subnet address for application gateway"
}

variable "fwSubnetAddress"{
    description = "Network subnet address for firewall"
}