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

#firewall 생성
resource "azurerm_firewall" "fw" {
  name                = "${var.prefix}fw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_tier = "Standard"

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
  disable_bgp_route_propagation = false

  route {
    name           = "${var.prefix}fwroute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = "Production"
  }
}


#firewall과 subnet 연결
resource "azurerm_subnet_route_table_association" "srta" {
  subnet_id      = azurerm_subnet.fwsubnet.id
  route_table_id = azurerm_route_table.fwrt.id
}

resource "azurerm_firewall_network_rule_collection" "aksfwnr1" {
  name                = "aksfwnr"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "apiudp"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "1194",
    ]

    destination_addresses = [
      "AzureCloud.${var.location}",
    ]

    protocols = [
      "UDP",
    ]
  }
  rule {
    name = "apitcp"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "9000",
    ]

    destination_addresses = [
      "AzureCloud.${var.location}",
    ]

    protocols = [
      "TCP",
    ]
  }
  rule {
    name = "time"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "123",
    ]

    destination_fqdns = [
      "ntp.Ubuntu.com",
    ]

    protocols = [
      "UDP",
    ]
  }

}

resource "azurerm_firewall_network_rule_collection" "aksfwnr2" {
  name                = "aksfwnr2"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "dns"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "UDP",
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "aksfwnr3" {
  name                = "aksfwnr3"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 300
  action              = "Allow"

  rule {
    name = "gitssh"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "22",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}

resource "azurerm_firewall_network_rule_collection" "aksfwnr4" {
  name                = "aksfwnr4"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 400
  action              = "Allow"

  rule {
    name = "fileshare"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "445",
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}


resource "azurerm_firewall_application_rule_collection" "aksfwar" {
  name                = "aksfwar"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "fqdn"

    source_addresses = [
      "*",
    ]

    target_fqdns = [
      "AzureKubernetesService",
    ]

    protocol {
      port = "80"
      type = "Http"
    }
    
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "AKS" {
  name                = "AKS"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = azurerm_resource_group.rg.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "required"

    source_addresses = [
      "*",
    ]

    target_fqdns = [
      "AzureKubernetesService", "aksrepos.azurecr.io", "*blob.core.windows.net", "mcr.microsoft.com", "*cdn.mscr.io", "management.azure.com", "login.microsoftonline.com", "ntp.ubuntu.com", "packages.microsoft.com", "acs-mirror.azureedge.net", "*.hcp.eastus.azmk8s.io", "*.tun.eastus.azmk8s.io", "security.ubuntu.com", "*archive.ubuntu.com", "changelogs.ubuntu.com", "nvidia.github.io", "us.download.nvidia.com", "apt.dockerproject.org", "dc.services.visualstudio.com", "*.ods.opinsights.azure.com", "*.oms.opinsights.azure.com", "*.microsoftonline.com", "*.monitoring.azure.com", "*auth.docker.io", "*cloudflare.docker.io", "*cloudflare.docker.com", "*registry-1.docker.io", "apt.dockerproject.org", "gcr.io", "storage.googleapis.com", "*.quay.io", "quay.io", "*.cloudfront.net", "*.azurecr.io", "*.gk.azmk8s.io", "raw.githubusercontent.com", "gov-prod-policy-data.trafficmanager.net", "api.snapcraft.io", "*.github.com", "*.vault.azure.net", "*.azds.io", "index.docker.io", "k8s.gcr.io", "checkpoint-api.weave.works"
    ]

    protocol {
      port = "80"
      type = "Http"
    }
    
    protocol {
      port = "443"
      type = "Https"
    }
  }
}