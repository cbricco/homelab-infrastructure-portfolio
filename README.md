# Homelab Infrastructure as Code

This is a personal homelab learning project built with OpenTofu and a local
Proxmox VE host.

The goal is to build practical, explainable experience with
Terraform-compatible HCL and Infrastructure-as-Code workflows without
presenting the work as professional infrastructure or public-cloud experience.

## Phase 1 scope

Phase 1 manages one completely disposable Debian virtual machine on Proxmox.

The lab intentionally does not manage or import:

- existing production-like services
- backup or recovery data
- the existing Uptime Kuma container
- Proxmox host configuration
- physical storage devices
- recovery-source disks

The disposable VM can be created, changed, destroyed, and recreated without
intentionally changing those systems.

## Tooling

- OpenTofu 1.12.6
- Terraform-compatible HCL
- Proxmox VE 9.2.20
- `bpg/proxmox` provider 0.113.1
- Debian 13 GenericCloud image
- cloud-init
- Git

## Lab architecture

OpenTofu manages one VM with the following design:

- Proxmox node: `pve`
- disposable VM ID: `9000`
- source template VM ID: `9001`
- Proxmox resource pool: `tofu-lab`
- storage: `local-lvm`
- network bridge: `vmbr0`
- CPU: 1 core
- memory: 1536 MiB
- root disk: 8 GiB
- IPv4 configuration: DHCP
- cloud-init user: `iacadmin`
- automatic boot: disabled

The VM is cloned from a manually prepared Debian 13 cloud-image template.

The real Proxmox API endpoint is supplied through an ignored local
`terraform.tfvars` file rather than being committed to Git. See
[Phase 1 Variable Reference](docs/VARIABLES.md).

## What I worked through

Phase 1 involved supervised work with:

- reading and changing Terraform-compatible HCL
- OpenTofu initialization, formatting, validation, planning, applying, and
  destroying
- reviewing proposed infrastructure changes before applying them
- cloning a disposable Proxmox VM from a template
- cloud-init configuration
- SSH-key-based access
- checking declared configuration against actual infrastructure
- making a controlled configuration change and checking for drift
- destroying and recreating a disposable workload
- documenting recovery limitations
- troubleshooting a Proxmox permissions failure during recreation
- keeping API credentials and state out of Git

During the destroy/recreate exercise, the recreated VM initially failed with an
HTTP 403 permission error. The original VM-management permission had been
associated with the disposable VM itself, so it did not survive destruction of
that VM.

The permission was later associated with the persistent `tofu-lab` resource
pool instead. Because the pool remains in place when the disposable VM is
deleted, the required permission was still available when the VM was recreated.

## AI-assisted workflow

AI was used extensively to draft and revise the HCL configuration,
documentation, troubleshooting steps, and command sequences in this personal
project.

My role has been defining the lab goal and safety boundaries, performing the
supervised operations, reviewing plans and verification results, checking
behavior in Proxmox, and deciding whether changes should proceed.

I do not present this repository as independently authored code or professional
infrastructure experience. It documents work I have personally operated,
reviewed, and am learning to explain.

## Outputs

The configuration exposes three non-sensitive values:

- `lab_vm_id`
- `lab_vm_name`
- `lab_pool_id`

`tofu output` reads these values from local OpenTofu state.

A fresh working copy does not automatically contain the state of an existing
deployment. See [Recovery and State Handling](docs/RECOVERY.md).

## Security and change-control boundaries

Infrastructure operations are intentionally human-supervised.

The Proxmox service account is scoped to the resources needed for this
disposable lab rather than receiving broad administrator access.

The current design uses permissions for:

- VM management inside the dedicated `tofu-lab` resource pool
- clone access to template VM 9001
- allocation access to `local-lvm`
- use of `vmbr0`
- limited node read access

A dedicated SSH key is used for the disposable VM.

The active Proxmox API token secret is stored in KDE Wallet on the current
workstation and is supplied to OpenTofu through `PROXMOX_VE_API_TOKEN`.

The secret is not stored in Git or tracked variable files. The superseded token
has been removed.

The provider currently uses `insecure = true` because this is a local learning
lab using the current Proxmox TLS setup. That is a documented lab tradeoff, not
a production-ready TLS configuration.

Never commit:

- API token secrets
- passwords
- private SSH keys
- OpenTofu state
- saved plans
- private environment files

## Verified lifecycle

Phase 1 has completed this supervised lifecycle:

```text
baseline configuration
    -> plan review
    -> create
    -> boot/network/SSH/cloud-init verification
    -> controlled memory change
    -> no-drift plan
    -> reviewed destroy
    -> unrelated-resource checks
    -> ACL failure discovery
    -> permission-design correction
    -> recreate
    -> boot/network/SSH/cloud-init verification
    -> credential cleanup
    -> authenticated no-change plan
```

The memory setting was deliberately changed from 1024 MiB to 1536 MiB and
verified.

VM 9000 was then deliberately destroyed after review of the destroy plan.
Template VM 9001 and unrelated LXC 100 remained intact.

After correcting the ACL design, VM 9000 was recreated successfully and passed
boot, network, SSH, and cloud-init checks.

The VM is currently stopped.

The latest authenticated OpenTofu plan reported:

```text
No changes. Your infrastructure matches the configuration.
```

Detailed evidence is in
[Phase 1 Lifecycle Evidence](docs/PHASE1-EVIDENCE.md).

## Reproducing the configuration locally

Create a private local variable file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace the example endpoint with the HTTPS endpoint
for the local Proxmox lab.

Then:

```bash
tofu init -lockfile=readonly
tofu fmt -check -recursive
tofu validate -no-color
```

Provide the Proxmox API token to the OpenTofu process through protected local
credential retrieval. Do not put the token secret in `terraform.tfvars`.

Then create a plan:

```bash
tofu plan -no-color
```

Review every infrastructure-changing plan before approval.

Apply and destroy operations remain human-supervised. This project does not use
unattended `-auto-approve`.

## Repository safety

The repository intentionally ignores:

- `.terraform/`
- `*.tfstate`
- `*.tfstate.*`
- `*.tfplan`
- `*.plan`
- local `*.tfvars`
- environment files
- credential directories
- private SSH keys

`terraform.tfvars.example` is intentionally safe to track and contains no real
LAN endpoint or credential.

The provider dependency lock file is committed for repeatability.

## Recovery status

The VM lifecycle itself has been exercised through create, change, destroy, and
recreate.

Credential retrieval from the current KDE Wallet has also been verified.

However:

- independent encrypted off-workstation state backup has not been tested
- restoration from an independent state backup has not been tested
- credential recovery after loss of the current workstation or wallet has not
  been tested

These are documented limitations, not completed capabilities.

See [Recovery and State Handling](docs/RECOVERY.md).

## Current Phase 1 status

Verified:

- OpenTofu configuration is valid
- provider version is pinned
- disposable VM definition works
- scoped Proxmox permissions work across recreation
- create/change/destroy/recreate lifecycle works
- SSH and cloud-init work
- outputs are defined and verified
- active API-token retrieval from protected local storage works
- latest authenticated plan reports no drift

Current VM state:

- VM 9000 exists
- VM 9000 is stopped

## Planned next steps

- establish and test an encrypted off-workstation state backup
- perform an actual state restore drill
- document independent credential recovery
- repeat the privacy/secret review before future public updates
- keep the sanitized portfolio snapshot separate from the local development
  history

This repository is a sanitized employer-facing snapshot; its publication
history is intentionally separate from the local development history.

A later phase may introduce a very small noncritical public-cloud workload, but
no public-cloud deployment is claimed by this Phase 1 project.
