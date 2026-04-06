terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://62.210.88.213:8006"
  api_token = var.proxmox_api_token
  insecure  = true
}