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
# resource "azurerm_subnet_route_table_association" "srta" {
#   subnet_id      = azurerm_subnet.fwsubnet.id
#   route_table_id = azurerm_route_table.fwrt.id
# }

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

resource "azurerm_application_gateway" "network" {
  name                = "sg-appgateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "WAF_V2"
    tier     = "WAF_V2"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = azurerm_subnet.appgwsubnet.id
  }

  frontend_port {
    name = "${azurerm_virtual_network.vnet.name}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${azurerm_virtual_network.vnet.name}-feip"
    public_ip_address_id = azurerm_public_ip.agpublicip.id
  }

  backend_address_pool {
    name         = "${azurerm_virtual_network.vnet.name}-beap"
    ip_addresses = ["${var.svcLoadbalancerAddress}"]
  }

  backend_http_settings {
    name                  = "${azurerm_virtual_network.vnet.name}-be-htst"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 10
    probe_name            = "IngressControllerHealthy"
  }

  probe {
    host = "${var.svcLoadbalancerAddress}"
    name = "IngressControllerHealthy"
    interval = 30
    protocol = "Http"
    path = "/"
    timeout = 30
    unhealthy_threshold = 3
    match {
    status_code = [
      "200",
      "404"
    ] 
   }
  }
  http_listener {
    name                           = "${azurerm_virtual_network.vnet.name}-httplstn"
    frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
    frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${azurerm_virtual_network.vnet.name}-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = "${azurerm_virtual_network.vnet.name}-httplstn"
    backend_address_pool_name  = "${azurerm_virtual_network.vnet.name}-beap"
    backend_http_settings_name = "${azurerm_virtual_network.vnet.name}-be-htst"
  }
}

resource "azurerm_storage_account" "storage" {
  name                     = "${var.prefix}logs"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "logs"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.prefix}acr"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "demo" {
  name                = "${var.prefix}-aks-logs"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "demo" {
  solution_name         = "ContainerInsights"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  workspace_resource_id = azurerm_log_analytics_workspace.demo.id
  workspace_name        = azurerm_log_analytics_workspace.demo.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "demo" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.prefix}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.kubernetes_version

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = file(var.public_ssh_key_path)
    }
  }

  default_node_pool {
    name            = "default"
    node_count      = var.agent_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    type            = "VirtualMachineScaleSets"

    # Required for advanced networking
    vnet_subnet_id = azurerm_subnet.akssubnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed = true
    }
  }
  addon_profile {
    kube_dashboard {
      enabled = false
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.demo.id
    }
    azure_policy {
      enabled = true
    }
  }
  network_profile {
    load_balancer_sku  = "standard"
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }

  lifecycle {
        ignore_changes = [
            # default_node_pool[0].node_count,
            default_node_pool[0].vnet_subnet_id,
            windows_profile
        ]
    }
}

resource "azurerm_role_assignment" "role1" {
  depends_on = [azurerm_kubernetes_cluster.demo]
  scope                = azurerm_virtual_network.vnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.demo.identity[0].principal_id
}

resource "azurerm_role_assignment" "role2" {
  depends_on = [azurerm_kubernetes_cluster.demo]
  scope                = azurerm_kubernetes_cluster.demo.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_kubernetes_cluster.demo.identity[0].principal_id
}

