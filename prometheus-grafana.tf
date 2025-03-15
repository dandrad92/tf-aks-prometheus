resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    
    labels = {
      name = "monitoring"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  depends_on = [kubernetes_namespace.monitoring]

  # Configuración segura de Grafana
  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }
  
  # Persistencia para los datos
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }
  
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "10Gi"
  }

  # Contexto de seguridad de pods - ejecución como usuario no-root
  set {
    name  = "prometheus.prometheusSpec.podSecurityContext.runAsNonRoot"
    value = "true"
  }
  
  set {
    name  = "prometheus.prometheusSpec.podSecurityContext.runAsUser"
    value = "1000"
  }

  # Persistencia para Grafana
  set {
    name  = "grafana.persistence.enabled"
    value = "true"
  }
  
  # Ejecutar como usuario no-root
  set {
    name  = "grafana.securityContext.runAsNonRoot"
    value = "true"
  }
  
  set {
    name  = "grafana.securityContext.runAsUser"
    value = "472"
  }

  # Configuración condicional de Ingress
  set {
    name  = "grafana.ingress.enabled"
    value = var.grafana_ingress_enabled
  }
  
  set {
    name  = "grafana.ingress.hosts[0]"
    value = var.grafana_ingress_host
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}