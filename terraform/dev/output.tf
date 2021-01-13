output "id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config_raw
}

output "client_key" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_admin_config.0.host
}

output "kubectl" {
  value = "az main get-credentials -g ${azurerm_resource_group.rg.name} -n ${azurerm_kubernetes_cluster.main.name} --admin"
}

output "important" {
  value = "az network vnet subnet update -g ${azurerm_resource_group.rg.name} --vnet-name ${azurerm_virtual_network.vnet.name} --name ${azurerm_subnet.mainsubnet.name} --route-table ${azurerm_route_table.fwrt.name}"
}
