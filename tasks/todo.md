# Master TODO

The single source of truth for "what's left". Detailed context lives in `phases/0X-<phase>/plan.md`. This file is the running checklist.

## Phase 0 — Lab bootstrap (target: 2026-05-05)

- [X] Confirm SSH access to the 2nd OVH VPS (the sacrificial one — prod stays untouched).
- [X] `lab-bootstrap/bootstrap-host.sh` (idempotent: deploy user, sudoers NOPASSWD, gh.keys → authorized_keys, sshd_config hardening via `00-hardening.conf`).
- [X] Idempotency test for `bootstrap-host.sh` (run twice — second produces only expected file rewrites, no new state).
- [ ] `lab-bootstrap/bootstrap-firewall.sh` (nftables — default-deny inbound, allow port 22).
- [ ] `lab-bootstrap/bootstrap-fail2ban.sh` (install + sshd jail).
- [ ] `lab-bootstrap/bootstrap-unattended.sh` (unattended-upgrades + reboot policy decided).
- [ ] `lab-bootstrap/bootstrap.sh` (top-level orchestrator: host → firewall → fail2ban → unattended).
- [ ] `lab-bootstrap/README.md` — bootstrap-from-zero procedure.
- [ ] **Drill:** revoke own SSH key, recover via provider console rescue, time it.
- [ ] **Pass Phase 0 exit checkpoints ([`phases/00-bootstrap/evals.md`](../phases/00-bootstrap/evals.md)).**
- [ ] Append lessons in `phases/00-bootstrap/lessons.md`.

## Phase 1 — Linux & networking (target: 2026-06-02)

- [ ] Real systemd unit for a long-running script (Restart, WatchdogSec, journalctl clean).
- [ ] Container from scratch: `unshare` + `cgcreate` + chrooted rootfs.
- [ ] Read & summarize `man namespaces(7)` and `man cgroups(7)`.
- [ ] Replace ufw with hand-written nftables rules.
- [ ] tcpdump on `eth0` while curling a service — identify ClientHello / TCP retransmits.
- [ ] `ss -tlnp` / `lsof -i` — map listening sockets to processes.
- [ ] Domain → VPS DNS records configured.
- [ ] Run own internal CA (step-ca / cfssl), issue + trust internal cert.
- [ ] Caddy or Traefik on VPS with Let's Encrypt DNS-01 (wildcard).
- [ ] `openssl s_client` cert inspection — understand chain + SNI.
- [ ] Deploy Gitea + Vaultwarden + status page on the VPS (Compose).
- [ ] Reverse proxy on VPS forwards to local services with TLS termination at the proxy.
- [ ] Backups (rsync/restic), restore verified.
- [ ] **Drill:** misconfigure DNS or break a cert, debug end-to-end without reverting.
- [ ] **Pass Phase 1 exit checkpoints ([`phases/01-linux-networking/evals.md`](../phases/01-linux-networking/evals.md)).**
- [ ] Append lessons in `phases/01-linux-networking/lessons.md`.

## Phase 2 — Ansible + lab bring-up + storage (target: 2026-06-30)

### Lab kickoff
- [ ] Install Proxmox VE 8.x on the spare 16GB PC. Static IP, admin user, API token.
- [ ] Storage layout decision (LVM-thin vs ZFS) documented in `lessons.md`.
- [ ] Storage primer: inodes / partitions / df vs du / LVM (PV/VG/LV) — notes in `lessons.md`.
- [ ] Provision 3-4 Ubuntu 24.04 VMs in Proxmox (cloud-init template + clones).
- [ ] Wireguard hub-and-spoke: hub on OVH VPS, peers = Proxmox host + work-laptop, `PersistentKeepalive` for NAT traversal.
- [ ] Verify SSH from work-laptop to a Proxmox VM via WG.
- [ ] WG hub successor plan written for post-July OVH expiry.

### Ansible foundations
- [ ] Read & summarize Ansible's execution model (control node → SSH → modules → JSON return).
- [ ] Inventory: static `hosts.yml` of Proxmox VMs, group_vars / host_vars precedence test.
- [ ] First playbook: install + configure on multiple VMs. Tag tasks. Run with `--tags`, `--check`, `--diff`.
- [ ] Refactor that playbook into a `role` with defaults / tasks / templates / handlers / meta.
- [ ] Galaxy / collections pinned in `requirements.yml` (`community.general`, `ansible.posix`, `community.docker`).

### Real conversions
- [ ] Convert `lab-bootstrap/bootstrap-host.sh` → `base-host` role. Keep Bash version side-by-side.
- [ ] **`storage` role** — LVM provisioning via `community.general.lvg` + `lvol`, fstab via `ansible.posix.mount`, idempotent.
- [ ] `wireguard` role with templated `wg0.conf`, peer keys in `ansible-vault`.
- [ ] Convert phase-1 reverse-proxy + service deployment to roles.
- [ ] Migrate Gitea + Vaultwarden + status page from VPS to Proxmox VMs declaratively.
- [ ] DNS records updated to point at Proxmox-VM-backed services.

### Variables, templates, vault
- [ ] Jinja2 templates with loops / conditionals / filters.
- [ ] `ansible-vault create` + edit + `--vault-password-file` in CI mode. Rotation story documented.
- [ ] Variable-precedence cheat-sheet in `phases/02-ansible/lessons.md`.

### Quality & testing
- [ ] `ansible-lint` clean across all roles.
- [ ] `yamllint` clean across `ansible/`.
- [ ] Molecule scenario for `base-host` role: converge → idempotency check → destroy.
- [ ] Dynamic inventory script in **Python** (Python drip), reads from JSON file.

### Drill
- [ ] **Storage incident drill:** inode exhaustion or full LV recovery via Ansible. Postmortem.

- [ ] **Pass Phase 2 exit checkpoints ([`phases/02-ansible/evals.md`](../phases/02-ansible/evals.md)).**
- [ ] Append lessons in `phases/02-ansible/lessons.md`.

## Phase 3 — Terraform (target: 2026-07-21)

### TF foundations
- [ ] `terraform init`, providers, modules, outputs, variables — notes in `lessons.md`.
- [ ] State model whiteboard (`tasks/whiteboards/03/state.md`).

### Proxmox provider (primary)
- [ ] Choose `telmate/proxmox` or `bpg/proxmox`, document why.
- [ ] API token from phase 2 configured, secrets out of repo.
- [ ] Module: `vm` — provisions a Proxmox VM from a cloud-init template.
- [ ] Module: `network` — VLAN / firewall rules.
- [ ] Provision + destroy a fresh VM via TF (real create/destroy cycle, not import).

### Cloud exercise (3-5 days)
- [ ] Pick OVH Public Cloud or Scaleway, document why.
- [ ] API token configured, hourly billing accepted.
- [ ] Module: `cloud-vps` — provisions one VPS, DNS records, outputs.
- [ ] Provision → smoke test → destroy 2-3 times.
- [ ] Spend tracking in `lessons.md` (target <€10).

### Remote state
- [ ] S3-compatible backend with locking (Cloudflare R2, Scaleway Object Storage, or Hetzner).
- [ ] Two workspaces: `lab` and `experimental`. Isolation proven.

### TF → Ansible bridge
- [ ] Dynamic inventory reading TF state.
- [ ] One-command flow: `terraform apply && ansible-playbook -i inventory/terraform.py site.yml`.
- [ ] Document handoff in `infra/README.md`.

### CI + branch protection
- [ ] CI: `terraform fmt`, `validate`, `plan` on PRs (GitLab CI preferred for French-market signal).
- [ ] `apply` only on merge to main, gated behind manual approval.
- [ ] Branching policy write-up in `tasks/whiteboards/03/branching.md`.
- [ ] Branch protection on `main` for `infra/`: reviews, green CI, dismiss-stale, no force-push, no direct push.
- [ ] Three deliberate denials demonstrated, audit log captured.

### Drills
- [ ] **Disaster drill:** delete a Proxmox VM, rebuild via `terraform apply` → `ansible-playbook` end-to-end, target <30 min.
- [ ] **Break-fix:** partial `terraform apply` failure, recover without `state rm` shortcut.

- [ ] **Pass Phase 3 exit checkpoints ([`phases/03-terraform/evals.md`](../phases/03-terraform/evals.md)).**
- [ ] Append lessons in `phases/03-terraform/lessons.md`.

## Phase 4 — Kubernetes + GitOps + release flow (target: 2026-09-01)

- [ ] **Book CKA exam in week 1 of this phase.**
- [ ] Read & summarize each control-plane component.
- [ ] Walk *Kubernetes the Hard Way* end-to-end on Proxmox VMs.
- [ ] Tear it all down, install k3s for daily use.
- [ ] Flannel CNI, trace pod→pod packet with `tcpdump`.
- [ ] Replace with Cilium, compare.
- [ ] Apply a NetworkPolicy that breaks something, debug with `cilium monitor`.
- [ ] One workload of each: Deployment, StatefulSet, DaemonSet, Job, CronJob.
- [ ] Probes: liveness + readiness + startup, intentionally fail each.
- [ ] Resources: trigger OOMKill and CPU throttle on purpose.
- [ ] PodDisruptionBudget + drain a node gracefully.
- [ ] local-path-provisioner first PVCs.
- [ ] Migrate to Longhorn, survive a node reboot with data intact.
- [ ] Apiserver audit logging to file on a node.
- [ ] Tighten RBAC: minimum-perm ServiceAccount for deploys.
- [ ] Default-deny NetworkPolicies per namespace, allow only what's needed.
- [ ] kubeaudit / kube-bench, fix at least 5 findings.
- [ ] Hand-rolled Helm chart per phase-2 service (no `helm create`).
- [ ] Per-env values: `values.yaml` + `values-staging.yaml` + `values-prod.yaml`.
- [ ] `helm upgrade --atomic --wait` clean deploy.

### Container image CI
- [ ] Multi-stage Dockerfile per service (build stage + minimal runtime).
- [ ] CI on PR: build image (no push), validate (lint, optional `trivy` scan).
- [ ] CI on merge to main: build + push to registry (GHCR or GitLab Registry). Tag `:sha-<short>` and `:main`.
- [ ] Registry choice documented in `lessons.md`.

### Release flow (read `tasks/release-flow.md` first)
- [ ] CI on git tag `vX.Y.Z-rc.N`: re-tag the existing image (no rebuild) as `:vX.Y.Z-rc.N`.
- [ ] CI on git tag `vX.Y.Z`: re-tag as `:vX.Y.Z`.
- [ ] Three Argo `Application`s per service: dev (`:main`), staging (RC tag), prod (final tag) — or `ApplicationSet` across `apps-dev`/`apps-staging`/`apps-prod` namespaces.
- [ ] **Full release cycle demoed:** PR → merge → dev deploy → cut RC → staging deploy → cut final → PR to bump prod `targetRevision` → prod deploy. Time it.

### Argo CD + GitOps
- [ ] Install Argo CD via Helm; Argo manages itself.
- [ ] App-of-apps pattern with auto-sync, prune, selfHeal.
- [ ] Manual `kubectl edit` reverted by Argo, observed.
- [ ] Sync-failure alerting placeholder for phase 5 wiring.

### Secrets
- [ ] Pattern decided + implemented (SOPS+age / sealed-secrets / external-secrets), documented.
- [ ] Migrate hardcoded secrets out of charts.

### Go drip
- [ ] Tiny Go HTTP server (`net/http`, ~50 lines), multi-stage Dockerfile, deployed via your Helm chart through the CI pipeline.

### CKA prep
- [ ] killercoda / killer.sh: 90%+ on timed mocks.
- [ ] **Sit CKA.**

### Drills
- [ ] **Incident drill:** kill etcd (snapshot first!), recover, time it.
- [ ] **Drift drill:** delete a Deployment by hand, watch Argo restore it.

- [ ] **Pass Phase 4 exit checkpoints ([`phases/04-kubernetes/evals.md`](../phases/04-kubernetes/evals.md)).**
- [ ] Append lessons in `phases/04-kubernetes/lessons.md`.

## Phase 5 — Observability + SRE practices (target: 2026-10-06)

- [ ] kube-prometheus-stack on cluster, persistent storage on Longhorn.
- [ ] Grafana with Prometheus + Loki + Tempo data sources, pinned versions.
- [ ] Loki + Promtail/Alloy.
- [ ] Tempo with 100% sampling.
- [ ] OTel Collector DaemonSet → Prometheus / Loki / Tempo.
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
- [ ] **Pass Phase 5 exit checkpoints ([`phases/05-observability-sre/evals.md`](../phases/05-observability-sre/evals.md)).**
- [ ] Append lessons in `phases/05-observability-sre/lessons.md`.

## Phase 6 — Specialize + interview prep (target: 2026-11-10)

- [ ] Pick flavor (Infra / Reliability / Platform), write reasoning in lessons.
- [ ] Capstone — **all flavors ship in Go** (see `phases/06-specialize/plan.md`).
- [ ] Weekly system design (5 total) in `tasks/system-design/`.
- [ ] Weekly troubleshooting drill (5 total) in `tasks/troubleshooting/`.
- [ ] 5 STAR behavioral stories drafted and rehearsed.
- [ ] CV refreshed for SRE pivot.
- [ ] LinkedIn updated.
- [ ] Target list: 10–15 companies with notes on their SRE org.
- [ ] **Pass Phase 6 exit checkpoints ([`phases/06-specialize/evals.md`](../phases/06-specialize/evals.md)).**
- [ ] Append lessons in `phases/06-specialize/lessons.md`.

## Phase 7 — Polish + apply (target: 2026-11-24)

- [ ] READMEs polished across every repo / subdir.
- [ ] Architecture diagrams (Mermaid or images) per repo.
- [ ] 2–3 deep blog posts published.
- [ ] Cross-links from this repo to posts.
- [ ] One-page CV final.
- [ ] LinkedIn headline rewrite.
- [ ] First applications sent.
- [ ] Per application: customized CV + cover letter linked to specific deliverable.
- [ ] **Pass Phase 7 exit checkpoints ([`phases/07-polish-apply/evals.md`](../phases/07-polish-apply/evals.md)).**
- [ ] Append lessons in `phases/07-polish-apply/lessons.md` (final retrospective).

---

## Slip log

When a target date moves, add a line here so slip is visible.

- _(empty — no slip yet)_
