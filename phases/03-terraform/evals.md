# Phase 3 — Evals

**Passing bar:** Drill 1 (disaster rebuild) pass + Drill 2 (cloud cycle) pass + Drill 3 (branch protection) pass + 1 of 2 break-fixes pass + both whiteboards delivered. ~5 hours of eval time.

## Drill 1 — Disaster rebuild (target: 30 min)

The signature deliverable, repeated as the eval. With your existing `infra/` and `ansible/` repos in hand:

1. Note current state of one lab service VM.
2. Delete the VM via the Proxmox UI.
3. Run `terraform apply` from `infra/`.
4. Run `ansible-playbook -i inventory/terraform.py site.yml` to configure the new VM.
5. Verify the service is back, certs valid, DNS resolves, data restored from backups.

**Pass:** end-to-end in <30 min wall time, no edits to TF or roles during the rebuild.
**Partial:** 30–45 min, or 1–2 manual interventions.
**Fail:** otherwise.

## Drill 2 — Cloud cycle (target: 20 min)

Provision → smoke test → destroy a VPS via the cloud TF module:

1. `terraform apply` against the cloud module (OVH or Scaleway) — VPS up.
2. `ansible-playbook -i inventory/terraform.py base-host.yml` — host hardened.
3. `ssh` confirms key-only auth, fail2ban running.
4. `terraform destroy` — VPS gone, cloud bill stops.

**Pass:** all four steps in <20 min, total spend logged in `lessons.md` <€2 for this run.

## Drill 3 — Branch protection enforced (target: 15 min)

On `infra/` (or a clean test repo with current rules removed):

1. Configure branch protection on `main`: required PR reviews, required green CI, dismiss stale approvals on push, no force-push, no direct push.
2. Demonstrate three denials: direct push to main, merge without review, force-push.
3. Capture the audit log entries for all three denials.

**Pass:** all three protections enforced, all three denials logged with timestamps. Screenshots or paste of audit log in `tasks/whiteboards/03/branch-protection.md`.

## Break-fix 1 — Partial terraform apply (target: 30 min)

Claude triggers a TF apply that fails halfway (e.g., kills the process mid-apply, or a downstream resource depends on something that doesn't exist yet).

**Pass:** state inspected with `terraform state list` + `terraform plan`, recovery via `terraform apply` (no `terraform state rm` shortcut). Partial credit if `state rm` was used but with a clear written justification.

## Break-fix 2 — TF/Ansible handoff broken (target: 20 min)

Claude breaks the dynamic inventory bridge: TF output format changed, or the inventory script choking on a new attribute.

**Pass:** identify the schema mismatch from `ansible-inventory --list` output, fix the bridge, retest end-to-end.

## Whiteboard 1 — Terraform state model (target: 10 min)

What's in `terraform.tfstate`? Why remote state? Why locking? What happens if two operators `apply` simultaneously without locking? What are the recovery paths from state corruption?

## Whiteboard 2 — Gitflow vs trunk-based (target: 10 min)

Where each shines, where each breaks. What infra constraints push teams toward one or the other (release cadence, feature-flag maturity, audit/regulatory needs)? Why might a regulated bank pick Gitflow even today, and what's the SRE-relevant cost when they do? Why does GitOps + Argo CD pair more naturally with trunk-based than with Gitflow?

## External attestation

None — but the disaster rebuild video (record it!) is portfolio gold for phase 7.

## Retention check (schedule for 2026-09-01)

Re-run Drill 1 cold against a different lab VM. The TF→Ansible loop should still be tight.
