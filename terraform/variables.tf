variable "proxmox_api_token" {
  description = "Proxmox API Token"
  type        = string
  sensitive   = true
}

variable "proxmox_node_name" {
  description = "Name des Proxmox-Nodes"
  type        = string
  default     = "jan26-group1-pet-clinic"
}

variable "vm_bridge" {
  description = "Bridge für die Netzwerk-Interfaces"
  type        = string
  default     = "vmbr1"
}