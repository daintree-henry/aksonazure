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
  host     = azurerm_kubernetes_cluster.main.kube_config.host

  client_certificate     = azurerm_kubernetes_cluster.main.kube_config.client_certificate
  client_key             = azurerm_kubernetes_cluster.main.kube_config.client_key
  cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config.cluster_ca_certificate
  version = ">=1.13.3"
}

provider "tls" {
  version = ">=3.0.0"
}

provider "helm" {
  kubernetes {
    host     = azurerm_kubernetes_cluster.main.kube_config.host
    username = azurerm_kubernetes_cluster.main.kube_config.username
    password = azurerm_kubernetes_cluster.main.kube_config.password

    client_certificate     = azurerm_kubernetes_cluster.main.kube_config.client_certificate
    client_key             = azurerm_kubernetes_cluster.main.kube_config.client_key
    cluster_ca_certificate = azurerm_kubernetes_cluster.main.kube_config.cluster_ca_certificate
  }
}
