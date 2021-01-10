# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "${var.location}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}vnet"
  address_space       = ["${var.vnetAddress}"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  subnet {
    name           = "${var.prefix}akssubnet"
    address_prefix = "${var.aksSubnetAddress}"
  }

  subnet {
    name           = "${var.prefix}svcsubnet"
    address_prefix = "${var.svcSubnetAddress}"
  }

  subnet {
    name           = "${var.prefix}appgwsubnet"
    address_prefix = "${var.appgwSubnetAddress}"
  }

  subnet {
    name           = "${var.prefix}fwsubnet"
    address_prefix = "${var.fwSubnetAddress}"
  }
}
