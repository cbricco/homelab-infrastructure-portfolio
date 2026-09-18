resource "proxmox_virtual_environment_vm" "phase1_lab" {
  name        = var.vm_name
  description = "Disposable OpenTofu Phase 1 lab VM."
  tags        = ["disposable", "opentofu", "phase1"]

  node_name = var.node_name
  vm_id     = var.vm_id
  pool_id   = var.pool_id

  started             = false
  on_boot             = false
  stop_on_destroy     = true
  reboot_after_update = false

  agent {
    enabled = false
  }

  clone {
    vm_id        = var.template_vm_id
    datastore_id = var.datastore_id
    full         = true
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = var.disk_size_gb
  }

  initialization {
    datastore_id = var.datastore_id
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.linux_username
      keys = [
        trimspace(file(pathexpand(var.ssh_public_key_path)))
      ]
    }
  }

  network_device {
    bridge = var.bridge
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0"]
}
