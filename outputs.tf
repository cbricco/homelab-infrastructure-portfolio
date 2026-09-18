output "lab_vm_id" {
  description = "Configured Proxmox VMID for the disposable Phase 1 lab."
  value       = var.vm_id
}

output "lab_vm_name" {
  description = "Configured name for the disposable Phase 1 lab VM."
  value       = var.vm_name
}

output "lab_pool_id" {
  description = "Proxmox pool configured for the disposable Phase 1 lab."
  value       = var.pool_id
}
