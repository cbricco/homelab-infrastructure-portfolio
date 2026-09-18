variable "proxmox_endpoint" {
  description = "HTTPS API endpoint for the local Proxmox VE host. Keep private LAN addresses in an ignored local tfvars file, not Git."
  type        = string

  validation {
    condition     = startswith(var.proxmox_endpoint, "https://")
    error_message = "The Proxmox endpoint must use HTTPS."
  }
}

variable "node_name" {
  description = "Proxmox node that hosts the disposable Phase 1 lab VM."
  type        = string
  default     = "pve"

  validation {
    condition     = var.node_name == "pve"
    error_message = "Phase 1 is restricted to the Proxmox node named pve."
  }
}

variable "vm_id" {
  description = "VMID reserved for the disposable OpenTofu-managed lab VM."
  type        = number
  default     = 9000

  validation {
    condition     = var.vm_id == 9000
    error_message = "Phase 1 is restricted to disposable VMID 9000."
  }
}

variable "template_vm_id" {
  description = "Manually maintained Debian 13 cloud template used as the clone source."
  type        = number
  default     = 9001

  validation {
    condition     = var.template_vm_id == 9001
    error_message = "Phase 1 must clone only from template VMID 9001."
  }
}

variable "pool_id" {
  description = "Dedicated Proxmox resource pool for disposable IaC workloads."
  type        = string
  default     = "tofu-lab"

  validation {
    condition     = var.pool_id == "tofu-lab"
    error_message = "Phase 1 is restricted to the tofu-lab resource pool."
  }
}

variable "datastore_id" {
  description = "Datastore allowed for the disposable VM and cloud-init disk."
  type        = string
  default     = "local-lvm"

  validation {
    condition     = var.datastore_id == "local-lvm"
    error_message = "Phase 1 is restricted to local-lvm storage."
  }
}

variable "bridge" {
  description = "Existing Proxmox bridge the disposable VM may use."
  type        = string
  default     = "vmbr0"

  validation {
    condition     = var.bridge == "vmbr0"
    error_message = "Phase 1 is restricted to vmbr0."
  }
}

variable "vm_name" {
  description = "Name of the disposable Phase 1 VM."
  type        = string
  default     = "tofu-lab-9000"
}

variable "cpu_cores" {
  description = "Virtual CPU cores assigned to the disposable VM."
  type        = number
  default     = 1

  validation {
    condition     = var.cpu_cores >= 1 && var.cpu_cores <= 2
    error_message = "Phase 1 CPU allocation must remain between 1 and 2 cores."
  }
}

variable "memory_mb" {
  description = "RAM assigned to the disposable VM in MiB."
  type        = number
  default     = 1536

  validation {
    condition     = var.memory_mb >= 512 && var.memory_mb <= 2048
    error_message = "Phase 1 memory must remain between 512 and 2048 MiB."
  }
}

variable "disk_size_gb" {
  description = "Size of the disposable VM system disk in GiB."
  type        = number
  default     = 8

  validation {
    condition     = var.disk_size_gb >= 3 && var.disk_size_gb <= 16
    error_message = "Phase 1 disk size must remain between 3 and 16 GiB."
  }
}

variable "linux_username" {
  description = "Linux account created through cloud-init for SSH access."
  type        = string
  default     = "iacadmin"
}

variable "ssh_public_key_path" {
  description = "Path to the dedicated public SSH key installed through cloud-init."
  type        = string
  default     = "~/.ssh/homelab_iac_ed25519.pub"
}
