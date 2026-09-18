terraform {
  required_version = ">= 1.12.6, < 1.13.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.113.1"
    }
  }
}
