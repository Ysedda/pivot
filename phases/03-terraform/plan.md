# Phase 3 — Terraform

**Duration:** 3 weeks  
**Target end:** 2026-07-21  
**Hours budget:** ~35

## Goal

Make the lab fully provisionable via Terraform. Proxmox provider for the bulk of work (zero spend, real lab) plus a short cloud-TF exercise (OVH or Scaleway) for cloud-API IaC interview signal. CI + branch protection on `main` enforced from this phase forward — first phase with infra-as-code that demands a CI gate.

## Why this phase

"Click-ops or simple Terraform" → "ships real IaC" is one of the most cited gaps for SRE candidates. The French market in particular asks for Terraform fluency on cloud APIs. Combined with Ansible from phase 2, you'll have most of the canonical French-market trifecta — Terraform provisions, Ansible configures (GitOps reconciles arrives in phase 4 with K8s).

> **Lab cost:** Proxmox provider work is free (uses your lab). The cloud exercise spends €3–10 total via hourly billing on OVH Public Cloud or Scaleway — provision, smoke test, destroy. Don't leave instances running.

## Deliverable

Two top-level sub-directories in this repo:

- **`infra/`** — Terraform that provisions lab VMs on Proxmox, manages remote state.
- **`infra-cloud/`** — short cloud exercise: provisions one cloud VPS via OVH or Scaleway provider, demonstrates the API-driven flow.

Plus: a **Terraform → Ansible bridge** — a dynamic inventory plugin (or script) that reads Terraform state and presents the new VMs to Ansible.

**Definition of done:** delete a Proxmox lab VM. Run `terraform apply` from `infra/` → `ansible-playbook site.yml` (using the dynamic TF→Ansible inventory) → service back. Total <30 min, no manual VM creation.

## Checklist

### TF foundations
- [ ] `terraform init`, providers, modules, outputs, variables. Notes in `lessons.md`.
- [ ] State model: what's in `terraform.tfstate`, why remote state, why locking. Whiteboard answer in `tasks/whiteboards/03/state.md`.

### Proxmox provider (primary)
- [ ] Choose provider: `telmate/proxmox` or `bpg/proxmox`. Document why in `lessons.md`.
- [ ] API token from phase 2's Proxmox install configured, secrets out of repo (env var or `*.auto.tfvars` excluded by `.gitignore`).
- [ ] Module: `vm` — provisions a VM from a cloud-init template. Cloud-init user-data either runs `bootstrap-host.sh` directly, or installs the SSH key and lets Ansible do the rest.
- [ ] Module: `network` — VLAN / firewall rules where applicable.
- [ ] Provision a fresh VM via `terraform apply`. Destroy via `terraform destroy`. Real create/destroy cycle (not just import).

### Cloud exercise (3-5 days, OVH or Scaleway)
- [ ] Pick provider: OVH Public Cloud (OpenStack-based) or Scaleway. Document why in `lessons.md`.
- [ ] API token configured, hourly billing accepted.
- [ ] Module: `cloud-vps` — provisions a single VPS, configures DNS records, outputs IP and hostname.
- [ ] Provision → smoke test (Ansible base-host run) → destroy. Repeat 2-3 times to internalise the create/destroy rhythm.
- [ ] **Spend tracking:** log €amount spent in `lessons.md`. Goal: <€10 total. Helps with future SRE roles where cost-awareness is the SRE side of the job.

### Remote state
- [ ] S3-compatible backend: Cloudflare R2, Scaleway Object Storage, or Hetzner Object Storage. Locking enabled.
- [ ] Two workspaces or two state files: `lab` (current) and `experimental`. Prove they're isolated.

### TF → Ansible handoff
- [ ] TF output (or local file) shaped like an Ansible inventory.
- [ ] Plug into the dynamic inventory you wrote in phase 2 — or use the `community.general.terraform_state` inventory plugin.
- [ ] One-command flow: `terraform apply && ansible-playbook -i inventory/terraform.py site.yml`.
- [ ] Document the handoff in `infra/README.md` — this is exactly the pattern interviewers ask about.

### CI + branch protection
- [ ] CI pipeline: `terraform fmt`, `terraform validate`, `terraform plan` on PRs (GitLab CI most common in France; GitHub Actions if you prefer).
- [ ] `apply` only on merge to main, gated behind manual approval.
- [ ] **Branching policy write-up** in `tasks/whiteboards/03/branching.md`: trunk-based vs Gitflow for *this specific lab*. Reference from `infra/README.md`.
- [ ] Branch protection on `main` for `infra/`: required PR reviews, required green CI, dismiss stale approvals on push, no force-push, no direct push.
- [ ] Demonstrate (and document the resulting denials) that policy actually fires: try a direct push, an unreviewed merge, a force-push.

### Drills

- [ ] **Disaster drill:** delete a Proxmox lab VM. Rebuild via `terraform apply` → `ansible-playbook` end-to-end. Time it. Target <30 min.
- [ ] **Break-fix:** partial `terraform apply` failure (kill `terraform` mid-apply, or trigger a downstream resource that depends on something missing). Inspect state with `terraform state list` + `plan`, recover via re-apply (no `state rm` shortcut unless documented why).

## Resources

- Terraform docs — registry.terraform.io.
- Proxmox provider docs (telmate or bpg) — registry.terraform.io.
- OVH provider docs — registry.terraform.io/providers/ovh/ovh.
- Scaleway provider docs — registry.terraform.io/providers/scaleway/scaleway.
- *Terraform: Up & Running* (Brikman) — chapters on modules, state, workspaces.
- `community.general.terraform` inventory plugin docs — for the TF→Ansible bridge.

## Stretch

- `make` target running `terraform fmt`, `terraform validate`, `tflint`, `checkov` (or `tfsec`).
- Terragrunt or Atmos for multi-env DRY-ness. Decide whether the complexity is worth it for two envs.
- **Go drip stretch (heavy — recommended):** write a small **custom Terraform provider in Go** using the Plugin Framework. Suggested scope: a provider for a tiny "lab inventory" JSON service running on a Proxmox VM. The highest-leverage Go practice in the program — TF provider code is heavily Go-idiomatic and a great signal in interviews.
- A second cloud provider (Hetzner Cloud, AWS free tier) for breadth.

## Lessons

End of phase: ensure `lessons.md` covers, especially: where the state model surprised you, where the TF→Ansible handoff felt awkward, the Proxmox-provider quirks vs cloud-provider polish, and the branching policy reasoning.
