# Phase 4 — Evals

**Passing bar:** Drill 1 (the disaster rebuild) pass + Drill 2 pass + 1 of 2 break-fixes pass + both whiteboards delivered. ~5 hours of eval time.

## Drill 1 — Disaster rebuild (target: 60 min)

The signature deliverable, repeated as the eval. With your existing infra/gitops repos in hand:

1. Note current state — apps, certs, dashboards (placeholder for phase 5).
2. Delete the VPS via the provider console.
3. Run `terraform apply` from `infra/`.
4. Run `ansible-playbook -i inventory/terraform.py site.yml` to configure the new host.
5. Sync Argo CD root app.
6. Verify all phase-1 services back, certs valid.

**Pass:** end-to-end in <60 min wall time, no manual `kubectl apply` for app workloads, no edits to TF or charts during the rebuild.
**Partial:** 60–90 min, or 1–2 manual interventions.
**Fail:** otherwise.

## Drill 2 — GitOps reconciliation timing (target: 15 min)

In `gitops/`, change a value in a Helm chart (e.g., bump replicas from 2 to 3 for one service). PR, merge to main.

**Pass:** running pod count reflects the change within 60s of merge, with no manual sync.

## Break-fix 1 — Manual drift vs Argo (target: 15 min)

Claude `kubectl edit`s an Argo-managed Deployment to set a wrong image tag.

- With `selfHeal: true`: how long until reverted?
- With `selfHeal: false`: how do you detect drift?

**Pass:** correctly predict the behavior in both modes + observe it within the time limit. Document in `tasks/whiteboards/03/argo-drift.md`.

## Break-fix 2 — Partial terraform apply (target: 30 min)

Claude triggers a TF apply that fails halfway (e.g., kills the process mid-apply, or a downstream resource depends on something that doesn't exist yet).

**Pass:** state inspected with `terraform state list` + `terraform plan`, recovery via `terraform apply` (no `terraform state rm` shortcut). Partial credit if `state rm` was used but with a clear written justification.

## Whiteboard 1 — Terraform state model (target: 10 min)

What's in `terraform.tfstate`? Why remote state? Why locking? What happens if two operators `apply` simultaneously without locking? What are the recovery paths?

## Whiteboard 2 — Argo CD reconciliation (target: 10 min)

The reconciliation loop: who watches what, what's the trigger interval, what's the difference between sync and self-heal, what's the difference between auto-prune on and off, what does "out of sync" actually mean (refs, manifests, live state)?

## Whiteboard 3 — Gitflow vs trunk-based (target: 10 min)

Where each shines, where each breaks. What infra constraints push teams toward one or the other (release cadence, feature-flag maturity, audit/regulatory needs)? Why might a regulated bank pick Gitflow even today, and what's the SRE-relevant cost when they do? Why does GitOps + Argo CD pair more naturally with trunk-based than with Gitflow?

## Drill 3 — Branch protection enforced (target: 15 min)

On `infra/` (or a clean test repo with current rules removed):

1. Configure branch protection on `main`: required PR reviews, required green CI, dismiss stale approvals on push, no force-push, no direct push.
2. Demonstrate three denials: direct push to main, merge without review, force-push.
3. Capture the audit log entries for all three denials.

**Pass:** all three protections enforced, all three denials logged with timestamps. Screenshots or paste of audit log in `tasks/whiteboards/04/branch-protection.md`.

## External attestation

None — but the disaster rebuild video (record it!) is portfolio gold for phase 7.

## Retention check (schedule for 2026-10-20)

Re-run Drill 2 cold. The GitOps loop should still be tight.
