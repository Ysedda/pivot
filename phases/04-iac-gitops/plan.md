# Phase 4 — IaC + GitOps

**Duration:** 4 weeks
**Target end:** 2026-09-08
**Hours budget:** ~50

## Goal

Make the lab fully declarative end-to-end. **Terraform** provisions infrastructure (replacing the click-opped Hetzner box from phase 3 with a TF-managed one); **Ansible** (from phase 3) configures it; **Argo CD** reconciles app state on the cluster. Manual `kubectl apply` is banned for application workloads.

## Why this phase

"Click-ops or simple Terraform" → "ships real IaC" is one of the most cited gaps for SRE candidates. Combined with Ansible from phase 3, you'll have the canonical French-market trifecta — Terraform provisions, Ansible configures, Argo CD reconciles. Argo CD specifically is the modern way most platform teams operate; learning it now means it's not a surprise on day one of a new job.

## Deliverable

Two top-level sub-directories in this repo (alongside `ansible/` from phase 3):

- **`infra/`** — Terraform that creates the lab VPS on the chosen provider (Hetzner Cloud recommended), configures DNS, and stores state remotely.
- **`gitops/`** — Argo CD `Application` manifests for every app on the cluster.
- Plus: a **Terraform → Ansible bridge** — a dynamic inventory plugin (or script) that reads Terraform state and presents the new VPS to Ansible.

**Definition of done:** delete the VPS through the provider console, then run `terraform apply` → `ansible-playbook site.yml` → apply Argo CD root app, and within an hour everything is back: hardened VPS, Wireguarded to Pi, K8s ingress live, all phase-1 services serving traffic.

## Checklist

### Terraform
- [ ] Hetzner Cloud (or chosen) provider configured, API tokens out of repo.
- [ ] Module: `vps` — provisions VPS, configures DNS records, outputs IP and hostname.
- [ ] Module: `network` — private network / firewall rules where applicable.
- [ ] Remote state: S3-compatible backend (Hetzner Object Storage, Cloudflare R2, Scaleway). Locking enabled.
- [ ] Two workspaces or two state files: `lab` (current) and `experimental`. Prove they're isolated.
- [ ] CI: `terraform plan` on PRs (GitLab CI most common in France; GitHub Actions if you prefer). `apply` only on merge to main, gated behind manual approval.

### TF → Ansible handoff
- [ ] Write a Terraform output (or a local file) shaped like an Ansible inventory.
- [ ] Plug it into the dynamic inventory you wrote in phase 3 — or use the `community.general.terraform_state` inventory plugin.
- [ ] One-command flow: `terraform apply && ansible-playbook -i inventory/terraform.py site.yml`.
- [ ] Document the handoff in `infra/README.md` — this is exactly the pattern interviewers ask about.

### Branching & CI policy
- [ ] Confirm the **trunk-based** policy from phase 0 in writing — `tasks/whiteboards/04/branching.md` comparing Gitflow vs trunk-based *for this specific lab*: what would change, what would break, what each gives you. Reference it from `infra/README.md` and `gitops/README.md`.
- [ ] Branch protection on `main` for `infra/` and `gitops/`: required PR reviews, required green CI, dismiss stale approvals on push, no force-push, no direct push.
- [ ] Demonstrate (and document the resulting denials) that policy actually fires: try a direct push to main, an unreviewed merge, a force-push.
- [ ] Optional: configure a **merge queue** (GitHub merge train / GitLab merge trains). Worth seeing once even if the lab doesn't need it.

### Helm chart per service
- [ ] One hand-written chart per phase-1 service, in `gitops/charts/<service>/`. Reuse the chart from phase 2 as a starting point.
- [ ] Per-env values (`values.yaml` + `values-prod.yaml`) even if "prod" is the same cluster — practice the pattern.

### Argo CD
- [ ] Install Argo CD on the cluster (Helm). Manage Argo itself via Argo (the auto-managed-by-self pattern).
- [ ] **App-of-apps**: one root `Application` pointing at `gitops/apps/`, which contains an `Application` per service.
- [ ] Auto-sync with `prune: true` and `selfHeal: true`. Test it: manually `kubectl edit` something Argo manages, watch it revert.
- [ ] Sync-failure alerting placeholder — wired to Alertmanager in phase 5.

### Secrets
- [ ] Pick *one* secrets pattern: SOPS + age, sealed-secrets, or external-secrets-operator backed by Hashicorp Vault / Bitwarden Secrets Manager. Document why over the alternatives.
- [ ] Migrate any hardcoded secrets in your Helm charts to that pattern.

### Drills
- [ ] **Incident drill:** delete a Deployment by hand. Argo brings it back. Time it. Postmortem if it doesn't behave as expected.
- [ ] **Disaster drill:** delete the VPS in the provider console. Rebuild via `terraform apply` → `ansible-playbook` → Argo sync end-to-end. Time it.

## Resources

- Terraform Hetzner Cloud provider docs — registry.terraform.io.
- Argo CD docs (especially app-of-apps) — https://argo-cd.readthedocs.io/
- *Terraform: Up & Running* (Brikman) — chapters on modules, state, workspaces.
- SOPS — https://github.com/getsops/sops
- `community.general.terraform` inventory plugin docs — for the TF→Ansible bridge.

## Stretch

- Replace Argo CD with **Flux** in a torn-down/rebuilt cluster. Compare. Form an opinion you can defend in interviews.
- `make` target running `terraform fmt`, `terraform validate`, `tflint`, `checkov` (or `tfsec`).
- Terragrunt or Atmos for multi-env DRY-ness. Decide whether the complexity is worth it for two envs.
- **Go drip stretch (heavy — recommended):** write a small **custom Terraform provider in Go** using the Plugin Framework. Suggested scope: a provider for a tiny "lab inventory" JSON service running on the cluster. This is the highest-leverage Go practice in the program — TF provider code is heavily Go-idiomatic and a great signal in interviews.

## Lessons

End of phase: ensure `lessons.md` covers, especially: where Argo's reconciliation surprised you, and where the TF→Ansible handoff felt awkward.
