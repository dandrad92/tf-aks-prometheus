provider "azurerm" {
  features {}
  subscription_id = "023047a9-db09-42db-a8c0-24137339c7db"
}

resource "azurerm_resource_group" "rg" {
  name     = "MiGrupoRecursos"
  location = "East US"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "MiClusterAKS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "miakscluster"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
