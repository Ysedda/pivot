# Master TODO

The single source of truth for "what's left". Detailed context lives in `phases/0X-*.md`. This file is the running checklist.

## Phase 0 — Lab bootstrap (target: 2026-05-05)

- [ ] Confirm SSH access to the 2nd OVH VPS (the sacrificial one — prod stays untouched).
- [ ] (deferred — Pi unavailable) Flash Ubuntu Server 24.04 LTS to Pi.
- [ ] (deferred — Pi unavailable) Reserve Pi IP on router.
- [ ] `lab-bootstrap/bootstrap-host.sh` (idempotent: user, SSH hardening, firewall, fail2ban, unattended-upgrades).
- [ ] Idempotency test (run twice, second is a no-op).
- [ ] Generate Wireguard keys (kept out of repo).
- [ ] `lab-bootstrap/bootstrap-wireguard.sh` (install, templated config, systemd unit — service ready, mesh inactive).
- [ ] (deferred — needs Pi peer) Verify mesh: ping both ways, `wg show` handshake.
- [ ] `lab-bootstrap/README.md` — bootstrap-from-zero procedure, with deferred items called out.
- [ ] **Drill:** revoke own SSH key, recover via provider console rescue, time it. (Re-do as wg-mediated recovery when Pi access returns.)
- [ ] **Pass Phase 0 exit checkpoints ([`evals/00-bootstrap.md`](../evals/00-bootstrap.md)).**
- [ ] Write `tasks/lessons.md` § Phase 0.

## Phase 1 — Linux & networking (target: 2026-06-02)

- [ ] Real systemd unit for a long-running script (Restart, WatchdogSec, journalctl clean).
- [ ] Container from scratch: `unshare` + `cgcreate` + chrooted rootfs.
- [ ] Read & summarize `man namespaces(7)` and `man cgroups(7)`.
- [ ] Replace ufw with hand-written nftables rules.
- [ ] Source-NAT or routing for Pi services via VPS public IP.
- [ ] tcpdump verification of expected wg traffic.
- [ ] Domain → VPS DNS records configured.
- [ ] Run own internal CA (step-ca / cfssl), issue + trust internal cert.
- [ ] Caddy or Traefik on VPS with Let's Encrypt DNS-01 (wildcard).
- [ ] `openssl s_client` cert inspection — understand chain + SNI.
- [ ] Deploy Gitea + Vaultwarden + status page on Pi (Compose).
- [ ] Reverse proxy on VPS forwards to Pi over wg with TLS termination at VPS.
- [ ] Backups (rsync/restic), restore verified.
- [ ] **Drill:** misconfigure DNS or break a cert, debug end-to-end without reverting.
- [ ] **Pass Phase 1 exit checkpoints ([`evals/01-linux-networking.md`](../evals/01-linux-networking.md)).**
- [ ] Write `tasks/lessons.md` § Phase 1.

## Phase 2 — Kubernetes deep dive (target: 2026-07-14)

- [ ] **Book CKA exam in week 1 of this phase.**
- [ ] Read & summarize each control-plane component.
- [ ] Walk *Kubernetes the Hard Way* end-to-end on Pi + VPS.
- [ ] Tear it all down, install k3s for daily use.
- [ ] Flannel CNI, trace pod→pod packet with tcpdump on wg.
- [ ] Replace with Cilium, compare.
- [ ] Apply a NetworkPolicy that breaks something, debug with `cilium monitor`.
- [ ] One workload of each: Deployment, StatefulSet, DaemonSet, Job, CronJob.
- [ ] Probes: liveness + readiness + startup, intentionally fail each.
- [ ] Resources: trigger OOMKill and CPU throttle on purpose.
- [ ] PodDisruptionBudget + drain a node gracefully.
- [ ] local-path-provisioner first PVCs.
- [ ] Migrate to Longhorn, survive a node reboot with data intact.
- [ ] Apiserver audit logging to file on VPS.
- [ ] Tighten RBAC: minimum-perm ServiceAccount for deploys.
- [ ] Default-deny NetworkPolicies per namespace, allow only what's needed.
- [ ] kubeaudit / kube-bench, fix at least 5 findings.
- [ ] Hand-rolled Helm chart (no `helm create`), `helm upgrade --atomic --wait`.
- [ ] **Go drip:** write a tiny Go HTTP server (`net/http`, ~50 lines), multi-stage Dockerfile, deploy via your hand-rolled chart.
- [ ] killercoda / killer.sh: 90%+ on timed mocks.
- [ ] **Sit CKA.**
- [ ] **Drill:** kill etcd (snapshot first!), recover, time it.
- [ ] **Pass Phase 2 exit checkpoints ([`evals/02-kubernetes.md`](../evals/02-kubernetes.md)).**
- [ ] Write `tasks/lessons.md` § Phase 2.

## Phase 3 — Configuration management with Ansible (target: 2026-08-11)

- [ ] Rent a small Hetzner CX22 (~€5/mo) — temporary lab VPS for this phase. Click-ops, intentionally.
- [ ] Read & summarize Ansible's execution model (control node → SSH → modules → JSON return).
- [ ] Inventory: static `hosts.yml`, group_vars / host_vars precedence test.
- [ ] First playbook: install + configure on both hosts. Tag tasks. Run with `--tags`, `--check`, `--diff`.
- [ ] Refactor that playbook into a `role` with defaults / tasks / templates / handlers / meta.
- [ ] Galaxy / collections pinned in `requirements.yml`.
- [ ] Convert `lab-bootstrap/bootstrap-host.sh` → `base-host` role. Keep Bash version side-by-side.
- [ ] Phase-1 reverse-proxy + service deployment converted to roles.
- [ ] `wireguard` role with templated `wg0.conf`, peer keys in `ansible-vault`.
- [ ] `k3s` install role, idempotent.
- [ ] Jinja2 templates with loops / conditionals / filters.
- [ ] `ansible-vault create` + edit + `--vault-password-file` in CI mode. Rotation story documented.
- [ ] Variable-precedence cheat-sheet in `tasks/lessons.md`.
- [ ] `ansible-lint` clean across all roles.
- [ ] `yamllint` clean across `ansible/`.
- [ ] Molecule scenario for `base-host` role: converge → idempotency check → destroy.
- [ ] Dynamic inventory script in **Python** (Python drip), reads from JSON file.
- [ ] **Incident drill:** non-idempotent task introduced (`command:` w/ no guard), run twice, observe drift, refactor, postmortem.
- [ ] **Pass Phase 3 exit checkpoints ([`evals/03-ansible.md`](../evals/03-ansible.md)).**
- [ ] Write `tasks/lessons.md` § Phase 3.

## Phase 4 — IaC + GitOps (target: 2026-09-08)

- [ ] Hetzner Cloud (or chosen) Terraform provider configured, API tokens out of repo.
- [ ] Module: `vps` (provisions VPS, DNS records, outputs).
- [ ] Module: `network` (private network / firewall).
- [ ] Remote state with locking (S3-compatible).
- [ ] `lab` and `experimental` workspaces, isolation proven.
- [ ] CI: `terraform plan` on PRs (GitLab CI preferred for French-market signal), apply on merge with manual gate.
- [ ] **Branching & CI policy:** trunk-based confirmed; Gitflow-vs-trunk write-up in `tasks/whiteboards/04/branching.md`.
- [ ] Branch protection on `main` for `infra/` + `gitops/`: required reviews, required green CI, no force-push, no direct push.
- [ ] Three deliberate denials demonstrated (direct push, unreviewed merge, force-push) with audit log captured.
- [ ] **TF → Ansible bridge:** dynamic inventory reading TF state. One-command flow: `terraform apply && ansible-playbook -i inventory/terraform.py site.yml`.
- [ ] One hand-written Helm chart per phase-1 service.
- [ ] Per-env values (`values.yaml` + `values-prod.yaml`).
- [ ] Argo CD installed via Helm; Argo manages itself.
- [ ] App-of-apps pattern with auto-sync, prune, selfHeal.
- [ ] Manual `kubectl edit` reverted by Argo, observed.
- [ ] Sync-failure alerting placeholder for phase 5 wiring.
- [ ] Secrets pattern decided + implemented (SOPS+age / sealed-secrets / external-secrets), documented.
- [ ] Migrate hardcoded secrets out of charts.
- [ ] **Go drip (recommended):** small custom Terraform provider in Go using the Plugin Framework. Suggested scope: a provider for a tiny lab inventory JSON service.
- [ ] **Drill:** delete a Deployment by hand, watch Argo restore it.
- [ ] **Disaster drill:** delete VPS in provider console, rebuild via `terraform apply` → `ansible-playbook` → Argo sync end-to-end.
- [ ] **Pass Phase 4 exit checkpoints ([`evals/04-iac-gitops.md`](../evals/04-iac-gitops.md)).**
- [ ] Write `tasks/lessons.md` § Phase 4.

## Phase 5 — Observability + SRE practices (target: 2026-10-13)

- [ ] kube-prometheus-stack on cluster, persistent storage on Longhorn.
- [ ] Grafana with Prometheus + Loki + Tempo data sources, pinned versions.
- [ ] Loki + Promtail/Alloy.
- [ ] Tempo with 100% sampling.
- [ ] OTel Collector DaemonSet → Prometheus / Loki / Tempo.
- [ ] Heavy components pinned to VPS node via nodeSelector.
- [ ] Pick one TS service (or write a fresh **Go** service — bonus Go drip), add OTel SDK + auto-instrumentations.
- [ ] Structured JSON logs with trace_id, log→trace jump verified in Grafana.
- [ ] Custom RED metrics on handlers.
- [ ] Pick SLI + SLO target + error budget for the app.
- [ ] Multi-window multi-burn-rate alerts (per SRE workbook).
- [ ] Grafana SLO dashboard: SLI, target, budget remaining, burn rate per window.
- [ ] Alertmanager → Slack/Telegram/email, fire test confirmed.
- [ ] SRE book chapters 1–6 read.
- [ ] SRE workbook chapters on SLO engineering + alerting on SLOs.
- [ ] Plan a failure (DB pod kill with PVC).
- [ ] Execute, watch dashboard only after alert fires.
- [ ] Record TTD, TTM, TTR.
- [ ] Postmortem in `tasks/postmortems/<date>-<title>.md`.
- [ ] At least 2 action items filed and closed.
- [ ] **Pass Phase 5 exit checkpoints ([`evals/05-observability-sre.md`](../evals/05-observability-sre.md)).**
- [ ] Write `tasks/lessons.md` § Phase 5.

## Phase 6 — Specialize + interview prep (target: 2026-11-17)

- [ ] Pick flavor (Infra / Reliability / Platform), write reasoning in lessons.
- [ ] Capstone — **all flavors ship in Go** (see `phases/06-specialize.md`).
- [ ] Weekly system design (5 total) in `tasks/system-design/`.
- [ ] Weekly troubleshooting drill (5 total) in `tasks/troubleshooting/`.
- [ ] 5 STAR behavioral stories drafted and rehearsed.
- [ ] CV refreshed for SRE pivot.
- [ ] LinkedIn updated.
- [ ] Target list: 10–15 companies with notes on their SRE org.
- [ ] **Pass Phase 6 exit checkpoints ([`evals/06-specialize.md`](../evals/06-specialize.md)).**
- [ ] Write `tasks/lessons.md` § Phase 6.

## Phase 7 — Polish + apply (target: 2026-12-01)

- [ ] READMEs polished across every repo / subdir.
- [ ] Architecture diagrams (Mermaid or images) per repo.
- [ ] 2–3 deep blog posts published.
- [ ] Cross-links from this repo to posts.
- [ ] One-page CV final.
- [ ] LinkedIn headline rewrite.
- [ ] First applications sent.
- [ ] Per application: customized CV + cover letter linked to specific deliverable.
- [ ] **Pass Phase 7 exit checkpoints ([`evals/07-polish-apply.md`](../evals/07-polish-apply.md)).**
- [ ] Write `tasks/lessons.md` § Phase 7 (final retrospective).

---

## Slip log

When a target date moves, add a line here so slip is visible.

- _(empty — no slip yet)_
