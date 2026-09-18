# Phase 1 Recovery and State Handling

Last updated: 2026-09-17

This guide records recovery boundaries and requirements for the local Proxmox
Phase 1 lab. It distinguishes tested lifecycle behavior from recovery work that
still requires an actual restore drill.

## Recovery scope

- OpenTofu manages only disposable VMID 9000 in the `tofu-lab` pool.
- Debian cloud template VMID 9001 is a prerequisite for recreating that VM.
- Existing services, including LXC 100, are outside this project's management
  scope.
- Backup data, recovery-source disks, and unrelated Proxmox resources are also
  outside this project's management scope.
- OpenTofu plan, apply, and destroy operations remain human-supervised.
- Infrastructure-changing plans must be reviewed before approval.

## State and generated files

The project currently uses OpenTofu local state in the repository working
directory.

Local working files may include:

- `terraform.tfstate`;
- `terraform.tfstate.backup`;
- saved `*.tfplan` files;
- `.terraform/` provider working data;
- ignored `terraform.tfvars`.

These files are not Git-tracked.

The tracked `.terraform.lock.hcl` file pins the provider dependency for
repeatability.

State and saved plans may contain sensitive infrastructure information. They
must not be committed, uploaded, pasted into public documentation, or treated
as source files.

A Git clone plus `tofu init` does not reconstruct the state of an existing
deployment.

## Current credential storage

The active Proxmox API token secret is stored in KDE Wallet on the current
workstation.

Retrieval from the current wallet has been tested successfully without
displaying the secret. OpenTofu has also authenticated successfully with the
retrieved value.

The superseded Proxmox API token was removed.

The token secret is not stored in:

- Git;
- tracked HCL;
- `terraform.tfvars.example`;
- project documentation.

Independent recovery of the credential after loss of the current workstation
or wallet has not yet been tested.

## Local endpoint handling

The real private-LAN Proxmox endpoint is stored only in ignored local
`terraform.tfvars`.

The tracked `terraform.tfvars.example` contains a non-routable example endpoint.

A new working copy therefore requires its own local endpoint configuration
before planning against a Proxmox host.

## State-backup limitation

A separate encrypted off-workstation state backup and a tested restore procedure
have not yet been established.

Until that work is complete, loss of the current workstation could require
careful manual reconciliation before OpenTofu can safely resume management of
the existing VM.

This remains a documented limitation of the learning lab.

## Rebuilding a working copy when a trusted state backup exists

When a known-good state backup is available:

1. restore the repository from its trusted Git source;
2. install the expected OpenTofu version;
3. run `tofu init -lockfile=readonly`;
4. copy `terraform.tfvars.example` to `terraform.tfvars`;
5. set the local Proxmox HTTPS endpoint in the ignored file;
6. restore access to the protected Proxmox API credential without putting the
   secret in Git or documentation;
7. restore the matching OpenTofu state using restrictive local permissions;
8. run `tofu fmt -check -recursive`;
9. run `tofu validate -no-color`;
10. create and review a fresh plan;
11. continue only if that plan matches the intended VM 9000 configuration and
    proposes no unexpected changes.

Do not reuse an old saved plan after restoring state or changing configuration.
Generate and review a fresh plan.

## If state is missing or does not match

Stop before running:

- `tofu apply`;
- `tofu destroy`;
- `tofu import`.

Preserve the Proxmox VM and every available state copy.

Do not create replacement state against an existing VM, edit state by hand, or
import the VM without a separately reviewed recovery procedure.

First reconcile:

- the Git configuration;
- available state copies;
- the actual Proxmox VM;
- pool membership;
- required ACLs.

## Proxmox access and recreation requirements

The tested ACL design places the limited `TofuLabVM` role on the persistent
`/pool/tofu-lab` path.

An earlier VM-specific ACL on `/vms/9000` disappeared when that disposable VM
was destroyed. This prevented recreation until the permission design was
corrected.

Before recreating VM 9000, verify that:

- the reviewed VM-management role remains assigned to `/pool/tofu-lab`;
- template VMID 9001 remains available with required audit and clone access;
- required storage access remains available;
- required network-bridge access remains available;
- required node read access remains available.

If an expected ACL is missing, stop and restore the reviewed permission design.

Do not work around the failure by broadly increasing OpenTofu privileges.

## Recovery verification

A recovery is not complete merely because OpenTofu initializes.

Before calling the Phase 1 lab recovered:

- confirm restored state corresponds to VMID 9000;
- review a fresh plan;
- verify there are no unexpected changes;
- verify the expected VM configuration directly in Proxmox;
- when booted, verify network and cloud-init state;
- confirm template VMID 9001 remains intact;
- confirm unrelated services remain outside OpenTofu management.

## Current readiness status

Tested:

- creation;
- controlled configuration change;
- drift checking;
- destroy;
- recreation;
- boot;
- DHCP networking;
- SSH;
- cloud-init completion;
- persistent-pool ACL behavior;
- credential retrieval from the current KDE Wallet;
- authenticated no-change planning.

Not yet tested:

- independent encrypted state backup and restore;
- credential recovery after loss of the current workstation or wallet.

Those limitations should remain documented until real recovery drills are
completed.
