provider "azurerm" {
  version = ">=2.40.0"
  features {}
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
  version      = ">=4.1.0"
}

provider "kubernetes" {
  load_config_file       = "false"
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  username               = azurerm_kubernetes_cluster.main.kube_config.0.username
  password               = azurerm_kubernetes_cluster.main.kube_config.0.password
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)}"
  version = ">=1.13.3"
}

provider "tls" {
  version = ">=3.0.0"
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
    username               = azurerm_kubernetes_cluster.main.kube_config.0.username
    password               = azurerm_kubernetes_cluster.main.kube_config.0.password
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)}"
  }
}
