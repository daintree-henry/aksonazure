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
# 서브넷 생성
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
    name                    = "AzureFirewallSubnet"
    resource_group_name     = azurerm_resource_group.rg.name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes          = [var.fwSubnetAddress]
}

#public ip 생성
resource "azurerm_public_ip" "fwpublicip" {
  name                = "${var.prefix}fwpublicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
#public ip 생성
resource "azurerm_public_ip" "agpublicip" {
  name                = "${var.prefix}agpublicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

#firewall 생성
resource "azurerm_firewall" "fw" {
  name                = "${var.prefix}fw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_tier = "Standard"

  dns_servers = ["168.63.129.16"]

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.fwsubnet.id
    public_ip_address_id = azurerm_public_ip.fwpublicip.id
  }

}

#route table 생성
resource "azurerm_route_table" "fwrt" {
  name                          = "${var.prefix}fwrt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name

  route {
    name           = "${var.prefix}fwroute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

}

#firewall과 subnet 연결
#TODO: 에러 발생, 해결 방안 확인중
#az network vnet subnet update -g testtest-rg --vnet-name testtestvnet --name testtestakssubnet --route-table testtestfwrt
#현재 수동으로 연결 진행 중..

resource "azurerm_subnet_route_table_association" "srta" {
  subnet_id      = azurerm_subnet.fwsubnet.id
  route_table_id = azurerm_route_table.fwrt.id
}
