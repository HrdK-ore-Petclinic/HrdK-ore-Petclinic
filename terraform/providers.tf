terraform {
  required_version = ">= 1.5.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.73.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.25"
    }
  }
}

provider "vault" {
  address = "http://localhost:8200"
}

provider "proxmox" {
  endpoint  = "https://62.210.88.213:8006"
  api_token = data.vault_kv_secret_v2.proxmox.data["proxmox_api_token"]
  insecure  = true
}