# Create a resource group
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet" {
    name                = "${var.prefix}vnet"
    address_space       = [var.vnetAddress]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "akssubnet" {
    name                    = "${var.prefix}akssubnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes          = [var.aksSubnetAddress]
}
resource "azurerm_subnet" "svcsubnet" {
    name                    = "${var.prefix}svcsubnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes          = [var.svcSubnetAddress]
}
resource "azurerm_subnet" "appgwsubnet" {
    name                    = "${var.prefix}appgwsubnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes          = [var.appgwSubnetAddress]
}
resource "azurerm_subnet" "fwsubnet" {
    name                    = "${var.prefix}fwsubnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes          = [var.fwSubnetAddress]
}

resource "azurerm_public_ip" "fwpublicip" {
  name                = "${var.prefix}fwpublicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                = "${var.prefix}fw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fwsubnet.id
    public_ip_address_id = azurerm_public_ip.fwpublicip.id
  }
}