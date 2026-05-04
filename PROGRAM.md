# Program

## Honest gap analysis

| Area              | Current                              | Target for SRE pivot                                  |
| ----------------- | ------------------------------------ | ----------------------------------------------------- |
| Kubernetes        | Consumer (deploy, read logs)         | Operator (built clusters, debug control plane)        |
| Cloud / IaC       | Click-ops or simple Terraform        | Multi-env Terraform, remote state, modules            |
| Networking        | Decent (subnets, DNS, TLS)           | Strong (firewalls, VPN, tcpdump in anger, CNI)        |
| Observability     | Touched it                           | Built it: Prometheus + Loki + Grafana + OTel + SLOs   |
| Linux / Bash      | Production exposure                  | Comfortable writing idempotent Bash, systemd units    |
| Storage primitives| Click + grow disks                   | LVM, inodes, fstab, df/du fluent                      |
| Tooling languages | TS / Node only                       | + solid Bash, + Python (Ansible/automation), + Go (controllers) |
| SRE practices     | None                                 | SLOs, error budgets, postmortems, on-call hygiene     |

## Phases at a glance

| #   | Theme                                                       | Duration | Target end  | Hours |
| --- | ----------------------------------------------------------- | -------- | ----------- | ----- |
| 0   | Lab bootstrap                                               | 1 wk     | 2026-05-05  | 10    |
| 1   | Linux & networking in anger                                 | 4 wks    | 2026-06-02  | 50    |
| 2   | Ansible + lab bring-up (Proxmox + WG hub) + storage         | 4 wks    | 2026-06-30  | 50    |
| 3   | Terraform                                                   | 3 wks    | 2026-07-21  | 35    |
| 4   | Kubernetes + GitOps + image CI / release flow               | 6 wks    | 2026-09-01  | 70    |
| 5   | Observability + SRE practices                               | 5 wks    | 2026-10-06  | 60    |
| 6   | Specialize + interview prep                                 | 5 wks    | 2026-11-10  | 60    |
| 7   | Polish + apply                                              | 2 wks    | 2026-11-24  | 20    |

Total: ~30 weeks, ~355 hours. Slip is expected — track it explicitly in `tasks/todo.md` and reset target dates rather than pretending.

## Phase summaries

### Phase 0 — Lab bootstrap (`phases/00-bootstrap/plan.md`)

VPS hardened end-to-end via idempotent Bash split into focused scripts (host, firewall, fail2ban, unattended-upgrades, plus a top-level orchestrator). Any host can be nuked and rebuilt in <15 min. Wireguard moved to phase 2 alongside Proxmox bring-up — no day-1 peer in phase 0 means no point installing it.

### Phase 1 — Linux & networking (`phases/01-linux-networking/plan.md`)

Prove "decent at networking" is real: nftables, systemd unit writing, namespaces & cgroups (container-from-scratch), own DNS + own CA, reverse proxy with TLS via Let's Encrypt DNS-01, debug with `tcpdump` / `dig` / `ss`. Self-host 2–3 services on the lab VPS as the dogfooding target — phase 2 migrates them declaratively to Proxmox VMs.

### Phase 2 — Ansible + lab bring-up + storage (`phases/02-ansible/plan.md`)

The most directly French-market-aligned phase. Manage the lab declaratively via Ansible: roles, inventory, `ansible-vault`, Molecule-tested. Lab grows in week 1: Proxmox VE installed on the spare 16GB PC, Wireguard hub-and-spoke up via the OVH VPS (lab access from work), storage primitives (inodes / LVM / df / du / partitions) absorbed via Proxmox install + Ansible storage modules. Phase-1 services migrate from the VPS to Proxmox VMs declaratively — that migration is the motivation for the phase. Convert the phase-0 Bash bootstrap to a `base-host` role; keep both side-by-side as a learning artifact.

### Phase 3 — Terraform (`phases/03-terraform/plan.md`)

Real IaC, hybrid lab + cloud. Terraform provisions VMs on the lab Proxmox box (primary, ~80% of phase, zero spend) plus a short cloud-TF exercise (OVH or Scaleway, ~€3-10 spend) for cloud-API interview signal. Remote state with locking. TF → Ansible bridge: dynamic inventory reading TF state. CI for `terraform plan` on PRs (GitLab CI preferred) + branch protection enforced from this phase onward. Disaster drill: nuke a lab VM, `terraform apply` → `ansible-playbook`, services back in <30 min.

### Phase 4 — Kubernetes + GitOps + release flow (`phases/04-kubernetes/plan.md`)

Walk *Kubernetes the Hard Way* against the lab Proxmox VMs, then redo with k3s for daily use. Cilium CNI, Traefik ingress, cert-manager. Migrate phase-2 services as **hand-written Helm charts**. Argo CD reconciles app state — `kubectl apply` for app workloads is banned by phase end. **Container image CI** (multi-stage Dockerfile + build-on-PR + push-on-merge to GHCR or GitLab Registry) and the **release-flow basics** — semver tagging, RC pattern, GitOps promotion via PR (see `tasks/release-flow.md`). Pick a secrets pattern (SOPS / sealed-secrets / external-secrets) and migrate. Sit the **CKA** exam at the end as a forcing function.

### Phase 5 — Observability + SRE practices (`phases/05-observability-sre/plan.md`)

Self-install LGTM stack on the cluster. Instrument an app with OpenTelemetry (preferably a fresh **Go** service, not the TS one). Define SLIs/SLOs and implement multi-window burn-rate alerts. Run a game day, write the postmortem. Read the Google SRE book + workbook in parallel.

### Phase 6 — Specialize + interview prep (`phases/06-specialize/plan.md`)

Pick a flavor (Infra / Reliability / Platform-DevEx) based on what felt best in phases 4–5. Capstone project in that flavor — **shipped in Go regardless of flavor**. The Platform flavor is the densest: a full **release-engineering capstone** that builds on phase 4's release flow (feature flag service in Go, Argo Rollouts canary + blue-green, SLO-driven auto-rollback, cosign image signing, enforced trunk-based branching). In parallel: weekly system design + weekly troubleshooting drill.

### Phase 7 — Polish + apply (`phases/07-polish-apply/plan.md`)

Portfolio-quality READMEs, 2–3 blog posts deep enough to prove understanding, then apply.

## Cross-cutting habits

- **`phases/0X-<phase>/lessons.md`** — one file per phase, colocated with the phase's plan and evals. Append continuously as checkboxes tick. What surprised me, what bit me, what I'd do differently. Highest interview signal in the whole repo. See `phases/README.md` for format guide and `tasks/tips.md` § Resources for reading lists.
- **One incident drill per phase** — intentional breakage, timed TTD/TTM, written postmortem.
- **Language drip — 15% Go + 10% Python per phase.** Go is leaned into harder than Python: by phase 6 you should be writing controllers, CLIs, and small services in Go without reaching for TS as a fallback. Python is leverage for Ansible (phase 2) and general automation. Go is the lingua franca of the K8s ecosystem and SRE tooling — the more comfortable you are reading and writing it by interview season, the better. The phase 6 capstone ships in Go regardless of flavor.
- **Game day per phase** — pick something to break, time the recovery.

## Heads-ups

- **French market shape.** The job market this program optimizes for is heavy on Ansible, Terraform, GitLab CI, OVH/Scaleway, and Python; lighter on Go than the US cloud-native bubble. The plan reflects this — phase 2 is dedicated to Ansible (early), phase 3 to Terraform, phase 4 covers K8s + GitOps + release flow, language drip includes Python, CI examples lean GitLab. (Go is still emphasized because the K8s ecosystem demands it for capstone work.)
- **Lab transition at start of phase 2.** Proxmox VE installed on the spare 16GB PC; the OVH sacrificial VPS becomes the WG hub. Phase-1 services migrate from the VPS to Proxmox VMs declaratively via Ansible — the migration is the motivation for the phase.
- **Post-July 2026 OVH expiry.** Both OVH VPSes expire ~2026-07. Plan a successor cloud VPS (cheapest available — OVH renewal, Scaleway, Hetzner cax11) for the Wireguard hub role only — single role, single port, ~€3-5/mo.
- **Public k8s API surface.** The cluster will be reachable over WG. Audit logging, RBAC, NetworkPolicies from day one in phase 4 — not "later".
- **CKA cost & timing.** Around $395 (voucher discounts often available). Book it as a hard deadline at the start of phase 4; nothing focuses preparation like a paid clock.
- **Language gap.** TS/Node alone won't cut it. The 15% Go + 10% Python drip per phase is non-negotiable — Go especially, since the K8s ecosystem and most SRE tooling converges on it. Python pays off immediately in phase 2 (Ansible). Go pays off across phases 3–7 (TF provider stretch, OTel instrumentation, capstone, controller reading).
