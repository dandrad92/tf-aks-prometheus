output "aks_name" {
  description = "Nombre del clúster AKS creado"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group" {
  description = "Nombre del grupo de recursos"
  value       = azurerm_resource_group.rg.name
}

output "kube_config" {
  description = "Configuración de kubectl para acceder al clúster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "grafana_admin_password_command" {
  description = "Comando para obtener la contraseña de administrador de Grafana"
  value       = "kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath=\"{.data.admin-password}\" | base64 --decode"
}

output "grafana_access_instructions" {
  description = "Instrucciones para acceder a Grafana"
  value       = var.grafana_ingress_enabled ? "Accede a Grafana en: https://${var.grafana_ingress_host}" : "Usa port-forward para acceder a Grafana: kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
}