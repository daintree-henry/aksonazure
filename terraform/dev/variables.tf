variable "location" {
  description = "Resource group for all resources."
}

variable "prefix" {
  description = "Name of the resource group"
}

variable "vnetAddress" {
    description = "Network address for vnet"
}

variable "aksSubnetAddress"{
    description = "Network subnet address for azure kubernetes service"
}

variable "svcSubnetAddress"{
    description = "Network subnet address for service"
}

variable "appgwSubnetAddress"{
    description = "Network subnet address for application gateway"
}

variable "fwSubnetAddress"{
    description = "Network subnet address for firewall"
}

variable "svcLoadbalancerAddress" {
  description = "The version of Kubernetes you want deployed to your cluster. Please reference the command: az aks get-versions --location eastus -o table"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes you want deployed to your cluster. Please reference the command: az aks get-versions --location eastus -o table"
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username assigned to the admin user on the OS of the AKS nodes if SSH access is ever needed"
}

variable "public_ssh_key_path" {
  description = "The Path at which your Public SSH Key is located. Defaults to ~/.ssh/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "agent_count" {
  default     = "2"
  description = "The starting number of Nodes in the AKS cluster"
}

variable "vm_size" {
  default     = "Standard_DS3_v2"
  description = "The Node type and size based on Azure VM SKUs Reference: az vm list-sizes --location eastus -o table"
}
variable "os_disk_size_gb" {
  default     = 30
  description = "The Agent Operating System disk size in GB. Changing this forces a new resource to be created."
}

variable "network_plugin" {
  default     = "azure"
  description = "Can either be azure or kubenet. azure will use Azure subnet IPs for Pod IPs. Kubenet you need to use the pod-cidr variable below"
}

variable "network_policy" {
  default     = "calico"
  description = "Uses calico by default for network policy"
}

variable "service_cidr" {
  default     = "192.168.0.0/16"
  description = "The IP address CIDR block to be assigned to the service created inside the Kubernetes cluster. If connecting to another peer or to you On-Premises network this CIDR block MUST NOT overlap with existing BGP learned routes"
}

variable "dns_service_ip" {
  default     = "192.168.0.10"
  description = "The IP address that will be assigned to the CoreDNS or KubeDNS service inside of Kubernetes for Service Discovery. Must start at the .10 or higher of the svc-cidr range"
}

variable "docker_bridge_cidr" {
  default     = "172.22.0.1/29"
  description = "The IP address CIDR block to be assigned to the Docker container bridge on each node. If connecting to another peer or to you On-Premises network this CIDR block SHOULD NOT overlap with existing BGP learned routes"
}

variable "github_repository" {
  description = "Name of the Github repository for Flux"
}

variable "github_token" {
  description = "Github Token"
}

variable "github_organization" {
  description = "Name of the Github id"
}

variable "linux_user" {
  description = "host linux user name for getting kubeconfig"
}
