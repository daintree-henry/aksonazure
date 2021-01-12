output "id" {
  value = azurerm_kubernetes_cluster.demo.id
}

output "kube_admin_config" {
  value = azurerm_kubernetes_cluster.demo.kube_admin_config_raw
}

output "client_key" {
  value = azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.demo.kube_admin_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.demo.kube_admin_config.0.host
}

output "kubectl" {
  value = "az aks get-credentials -g ${azurerm_resource_group.rg.name} -n ${azurerm_kubernetes_cluster.demo.name} --admin"
}

output "IMPORTANT!!" {
  value = "az network vnet subnet update -g ${azurerm_resource_group.rg.name} --vnet-name ${azurerm_virtual_network.vnet.name} --name ${azurerm_subnet.akssubnet.name} --route-table ${azurerm_route_table.fwrt.name}"
}
