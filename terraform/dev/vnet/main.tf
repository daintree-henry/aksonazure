# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.prefix}vnet"
    address_space       = ["${var.vnetAddress}"]
    location            = var.location
    resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "akssubnet" {
    name                    = "${var.prefix}akssubnet"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
    address_prefixes          = ["${var.aksSubnetAddress}"]
}
resource "azurerm_subnet" "svcsubnet" {
    name                    = "${var.prefix}svcsubnet"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
    address_prefixes          = ["${var.svcSubnetAddress}"]
}
resource "azurerm_subnet" "appgwsubnet" {
    name                    = "${var.prefix}appgwsubnet"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
    address_prefixes          = ["${var.appgwSubnetAddress}"]
}
resource "azurerm_subnet" "fwsubnet" {
    name                    = "${var.prefix}fwsubnet"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.vnet.name}"
    address_prefixes          = ["${var.fwSubnetAddress}"]
}
