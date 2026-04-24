variable "proxmox_node_name" {
  description = "name of the Proxmox node"
  type        = string
  default     = "jan26-group1-pet-clinic"
}

variable "vm_bridge" {
  description = "bridge for network-interfaces"
  type        = string
  default     = "vmbr1"
}