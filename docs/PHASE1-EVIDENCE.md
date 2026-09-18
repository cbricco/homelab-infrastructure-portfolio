# Phase 1 Lifecycle Evidence Notes

Lifecycle initially verified: 2026-09-16
Outputs and credential-cleanup checkpoint verified: 2026-09-17

This document summarizes supervised Phase 1 checks. It contains no credentials,
private keys, OpenTofu state, saved plans, raw API logs, or private-LAN
addresses.

## Baseline creation

The disposable VM was created from the manually maintained Debian 13 cloud
template.

Verified behavior:

1. OpenTofu initialized with the pinned provider.
2. Formatting and configuration validation passed.
3. The proposed plan was reviewed before application.
4. VM 9000 was created from template VM 9001.
5. The resulting VM configuration was checked directly in Proxmox.
6. The VM booted.
7. DHCP networking became available.
8. SSH access succeeded with the dedicated SSH key.
9. `cloud-init` reported completion.

## Controlled configuration change

The VM memory value was deliberately changed from 1024 MiB to 1536 MiB.

The change was reviewed in Git, formatted, validated, planned, reviewed, and
applied under human supervision. The resulting VM configuration was checked
directly in Proxmox, and a later OpenTofu plan reported no drift.

## Destroy and recreate exercise

The disposable VM was deliberately destroyed after review of the destroy plan.

Verified results:

- VM 9000 was destroyed as intended.
- Template VM 9001 remained intact.
- Unrelated LXC 100 remained intact.
- Unrelated Proxmox resources were not intentionally managed or destroyed.

## ACL issue discovered during recreation

The original limited VM-management role had been assigned directly to
`/vms/9000`.

This worked while VM 9000 existed. Destroying the VM also removed the
VM-specific ACL path. A later recreation attempt authenticated successfully but
received HTTP 403 because the required VM-management permission was no longer
present.

The design was corrected by assigning the limited VM-management role to the
persistent `/pool/tofu-lab` path instead.

That allowed the permission boundary to survive destruction and recreation of
the disposable VM.

## Successful recreation

After the ACL correction:

1. a fresh recreate plan was generated and reviewed;
2. VM 9000 was recreated successfully;
3. its Proxmox configuration was checked;
4. the VM booted;
5. IPv4 connectivity was verified;
6. the new SSH host fingerprint was reviewed;
7. SSH access succeeded;
8. `cloud-init status` reported `done`;
9. the VM was shut down cleanly;
10. a later OpenTofu plan reported no changes.

## Outputs

Three non-sensitive outputs were added:

- configured lab VM ID;
- configured lab VM name;
- configured Proxmox resource pool.

Applying the output declarations caused zero resources to be added, changed, or
destroyed. `tofu output` then returned the expected values from local state.

## Credential cleanup

The active Proxmox API token secret is stored in KDE Wallet on the current
workstation.

Verified:

- the secret can be retrieved from the wallet without displaying it;
- OpenTofu can authenticate with the retrieved value;
- the superseded token was removed from Proxmox;
- the temporary local text file that had contained the secret was deleted;
- an authenticated OpenTofu plan after cleanup reported no changes.

The token secret is not stored in this repository.

## Endpoint privacy cleanup

The real private-LAN Proxmox API endpoint was removed from tracked HCL.

The provider now receives the endpoint from an ignored local
`terraform.tfvars` file, and a sanitized `terraform.tfvars.example` is provided
for reproducibility without publishing the real LAN address.

After this change:

- `tofu fmt -check -recursive` passed;
- `tofu validate -no-color` passed;
- authenticated OpenTofu planning still reported no infrastructure changes.

## Current Phase 1 state

At the latest checkpoint:

- VM 9000 exists and is stopped;
- OpenTofu reports no configuration drift;
- the persistent pool ACL design is in place;
- the active API token is stored in protected local credential storage.

## Recovery limitation

Independent state backup and restoration have not yet been tested.

Credential retrieval from the current KDE Wallet has been tested, but
independent credential recovery after loss of the current workstation or wallet
has not been tested.

See [Recovery and State Handling](RECOVERY.md).
