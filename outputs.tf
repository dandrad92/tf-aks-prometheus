output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}

output "grafana_admin_password" {
  value = "Para obtener la contraseña de Grafana, ejecuta: kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode"
}
