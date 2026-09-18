# Phase 1 Variable Reference

Phase 1 intentionally constrains most infrastructure values so this disposable
learning lab cannot casually expand into unrelated Proxmox resources.

| Variable | Purpose | Phase 1 setting |
| --- | --- | --- |
| `proxmox_endpoint` | Proxmox HTTPS API endpoint | Supplied locally through ignored `terraform.tfvars` |
| `node_name` | Proxmox node | Restricted to `pve` |
| `vm_id` | Disposable VM | Restricted to `9000` |
| `template_vm_id` | Debian cloud template | Restricted to `9001` |
| `pool_id` | Persistent lab pool | Restricted to `tofu-lab` |
| `datastore_id` | VM storage | Restricted to `local-lvm` |
| `bridge` | VM network bridge | Restricted to `vmbr0` |
| `vm_name` | VM name | Defaults to `tofu-lab-9000` |
| `cpu_cores` | Virtual CPUs | 1-2 |
| `memory_mb` | RAM | 512-2048 MiB; current value 1536 |
| `disk_size_gb` | System disk | 3-16 GiB; current value 8 |
| `linux_username` | cloud-init account | Defaults to `iacadmin` |
| `ssh_public_key_path` | Public SSH key location | Local filesystem path |

## Local configuration

Copy the safe example before configuring a new working copy:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Set the real Proxmox HTTPS endpoint only in `terraform.tfvars`. That file is
ignored by Git.

## API credential

The Proxmox API token secret is stored separately from this repository and is
supplied to OpenTofu through the `PROXMOX_VE_API_TOKEN` environment variable.

Do not put API token secrets, passwords, private keys, OpenTofu state, or saved
plans in tracked variable files.

## Safety intent

Validation rules restrict the disposable lab to known VM, template, pool,
storage, and network identifiers. CPU, memory, and disk ranges are also
bounded.

These constraints are learning-project safety controls. They are not a claim
