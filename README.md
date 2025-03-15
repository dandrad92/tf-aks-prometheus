# AKS con Prometheus y Grafana

[![Terraform](https://img.shields.io/badge/Terraform-0.14%2B-blueviolet)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-AKS-blue)](https://azure.microsoft.com/es-es/services/kubernetes-service/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%7C%20Grafana-orange)](https://prometheus.io/)

Este proyecto implementa un clúster de Azure Kubernetes Service (AKS) con monitoreo a través de Prometheus y Grafana, utilizando Terraform para la infraestructura como código.

## Arquitectura

El proyecto despliega la siguiente infraestructura:

- Grupo de recursos en Azure
- Clúster AKS con políticas de red habilitadas
- Workspace de Log Analytics para monitoreo
- Stack de Prometheus-Grafana para observabilidad
  - Prometheus para recolección de métricas
  - Grafana para visualización
  - AlertManager para gestión de alertas

## Características principales

- **Infraestructura como código**: Toda la infraestructura se define con Terraform para garantizar despliegues reproducibles
- **Seguridad mejorada**: 
  - RBAC habilitado para control de acceso granular
  - Políticas de red con Calico
  - Ejecución de contenedores como usuarios no-root
- **Monitoreo integral**: 
  - Prometheus para la recolección y almacenamiento de métricas
  - Grafana para visualización avanzada de dashboards
- **Persistencia de datos**: Almacenamiento persistente para Prometheus y Grafana
- **Estado remoto de Terraform**: Configuración para almacenamiento seguro del estado en Azure Storage

## Requisitos previos

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0+
- [Azure CLI](https://docs.microsoft.com/es-es/cli/azure/install-azure-cli) con una suscripción activa
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/)

## Configuración inicial

### 1. Clonar el repositorio

```bash
git clone https://github.com/dandrad92/tf-aks-prometheus.git
cd tf-aks-prometheus
```

### 2. Configurar Azure para el almacenamiento de estado remoto

```bash
# Iniciar sesión en Azure
az login

# Crear grupo de recursos para el estado
az group create --name TerraformState --location eastus

# Crear cuenta de almacenamiento (nombre debe ser único globalmente)
az storage account create --name tfstate<tunombre> --resource-group TerraformState --sku Standard_LRS

# Crear contenedor
STORAGE_KEY=$(az storage account keys list --account-name tfstate<tunombre> --resource-group TerraformState --query "[0].value" -o tsv)
az storage container create --name tfstate --account-name tfstate<tunombre> --account-key $STORAGE_KEY
```

### 3. Preparar archivos de configuración

```bash
# Crear archivos de variables a partir de los ejemplos
cp terraform.tfvars.example terraform.tfvars
cp backend.tfvars.example backend.tfvars

# Editar los archivos con tus valores
```

En `terraform.tfvars`, debes especificar:
- ID de suscripción de Azure
- Configuración del grupo de recursos y región
- Parámetros del clúster AKS
- Contraseña de Grafana

En `backend.tfvars`, configura:
- Nombre del grupo de recursos para el estado
- Nombre de la cuenta de almacenamiento
- Nombre del contenedor
- Clave del archivo de estado

## Despliegue

### 1. Inicializar Terraform con backend remoto

```bash
terraform init -backend-config=backend.tfvars
```

### 2. Verificar la configuración y los cambios planeados

```bash
terraform validate
terraform plan
```

### 3. Aplicar la configuración

```bash
terraform apply
```
![imagen](https://github.com/user-attachments/assets/b975bf1e-5ff7-46a3-abf0-620b393933b9)


Este proceso tardará aproximadamente 5-10 minutos en completarse.

### 4. Configurar kubectl para acceder al clúster

```bash
az aks get-credentials --resource-group AKS-ResourceGroup --name AKS-Cluster
```

## Acceso a Grafana

### 1. Verificar que los pods estén ejecutándose

```bash
kubectl get pods -n monitoring
```
![imagen](https://github.com/user-attachments/assets/068f3509-8ede-469b-a1f7-22535cf4e6a8)


### 2. Configurar acceso a Grafana mediante port-forwarding

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

### 3. Obtener credenciales de Grafana

#### En Linux/macOS:
```bash
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

#### En Windows (PowerShell):
```powershell
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String((kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}")))
```

### 4. Acceder a la interfaz web

Abre http://localhost:3000 en tu navegador y usa:
- Usuario: `admin`
- Contraseña: (la obtenida del comando anterior)

![imagen](https://github.com/user-attachments/assets/f3c5f368-47d0-470c-8883-3a3866410e2d)


## Dashboards importantes

Grafana incluye varios dashboards predefinidos como parte del helm chart de kube-prometheus-stack:

1. **Node Exporter / Nodes**: Métricas detalladas de recursos de los nodos (CPU, memoria, red, disco)
 ![imagen](https://github.com/user-attachments/assets/eec3dc67-bf08-45cd-8a25-7c5af7951783)

2. **Kubernetes / Compute Resources / Namespace (Pods)**: Uso de recursos por pods en cada namespace
 ![imagen](https://github.com/user-attachments/assets/3f4fda77-20ae-4df5-ac80-74cda74c2fc7)

3. **Kubernetes / Compute Resources / Cluster**: Visión general del uso de recursos del clúster
 ![imagen](https://github.com/user-attachments/assets/d4d6b950-a921-4198-b992-68d953e40351)

4. **Kubernetes / Compute Resources / Namespace (Workloads)**: Métricas por tipo de workload
![imagen](https://github.com/user-attachments/assets/516a2438-cd07-4482-b05c-ab56b3fb97c1)


Para encontrar estos dashboards, navega a Dashboards → Browse.

![imagen](https://github.com/user-attachments/assets/a7c6e051-c941-4fa4-9d34-4c1cdc99d499)


## Personalización

### Modificar la configuración de Prometheus y Grafana

Edita el archivo `prometheus-grafana.tf` para personalizar la configuración mediante los parámetros del Helm chart:

```hcl
# Ejemplo para configurar la retención de datos
set {
  name  = "prometheus.prometheusSpec.retention"
  value = "15d"
}

# Ejemplo para configurar recursos de Grafana
set {
  name  = "grafana.resources.limits.memory"
  value = "1Gi"
}
```

### Agregar dashboards personalizados a Grafana

1. Accede a Grafana en http://localhost:3000
2. Navega a Dashboard → Import
3. Ingresa el ID de un dashboard de la [biblioteca oficial de Grafana](https://grafana.com/grafana/dashboards/) o carga un archivo JSON

## Limpieza de recursos

Para eliminar todos los recursos creados:

```bash
terraform destroy
```

Para eliminar solo el clúster pero mantener el estado remoto:

```bash
terraform destroy -target=azurerm_kubernetes_cluster.aks
```

## Consideraciones de seguridad

- La contraseña de administrador de Grafana se maneja como una variable sensible
- Los valores reales de las variables se almacenan en archivos `.tfvars` que no se suben al repositorio
- El estado de Terraform se almacena en Azure Storage con acceso controlado
- El clúster AKS tiene habilitado RBAC para control de acceso
- Los componentes de monitoreo se ejecutan con usuarios no-root
- Se utilizan políticas de red para segmentar la comunicación entre pods

## Solución de problemas

### Error "no cached repo found" con Helm

Si encuentras este error durante el despliegue, ejecuta manualmente:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Luego vuelve a ejecutar `terraform apply`.

### Problemas de conexión a Grafana

Si no puedes acceder a Grafana después del port-forward, verifica:

```bash
kubectl get pods -n monitoring
kubectl describe svc prometheus-grafana -n monitoring
```

## Contribuciones

Las contribuciones son bienvenidas. Por favor, sigue estos pasos:
1. Fork el repositorio
2. Crea una rama para tu característica
3. Realiza tus cambios
4. Envía un pull request
