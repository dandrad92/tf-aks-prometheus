variable "subscription_id" {
  description = "ID de suscripción de Azure"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "AKS-ResourceGroup"
}

variable "location" {
  description = "Región de Azure donde se despliegan los recursos"
  type        = string
  default     = "East US"
}

variable "cluster_name" {
  description = "Nombre del clúster AKS"
  type        = string
  default     = "AKS-Cluster"
}

variable "dns_prefix" {
  description = "Prefijo DNS para el clúster AKS"
  type        = string
  default     = "akscluster"
}

variable "node_count" {
  description = "Número de nodos en el clúster AKS"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Tamaño de las máquinas virtuales para los nodos"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "admin_group_object_ids" {
  description = "IDs de los grupos de Azure AD que tendrán permisos de administrador en el clúster"
  type        = list(string)
  default     = []
}

variable "grafana_admin_password" {
  description = "Contraseña de administrador para Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_ingress_enabled" {
  description = "Habilitar el ingress para Grafana"
  type        = bool
  default     = false
}

variable "grafana_ingress_host" {
  description = "Hostname para el ingress de Grafana"
  type        = string
  default     = "grafana.example.com"
}

variable "tags" {
  description = "Etiquetas para los recursos"
  type        = map(string)
  default     = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}