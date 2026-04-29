# Program

## Honest gap analysis

| Area              | Current                              | Target for SRE pivot                                  |
| ----------------- | ------------------------------------ | ----------------------------------------------------- |
| Kubernetes        | Consumer (deploy, read logs)         | Operator (built clusters, debug control plane)        |
| Cloud / IaC       | Click-ops or simple Terraform        | Multi-env Terraform, remote state, modules            |
| Networking        | Decent (subnets, DNS, TLS)           | Strong (firewalls, VPN, tcpdump in anger, CNI)        |
| Observability     | Touched it                           | Built it: Prometheus + Loki + Grafana + OTel + SLOs   |
| Linux / Bash      | Production exposure                  | Comfortable writing idempotent Bash, systemd units    |
| Tooling languages | TS / Node only                       | + solid Bash, + Python (Ansible/automation), + Go (controllers) |
| SRE practices     | None                                 | SLOs, error budgets, postmortems, on-call hygiene     |

## Phases at a glance

| #   | Theme                                       | Duration | Target end  | Hours |
| --- | ------------------------------------------- | -------- | ----------- | ----- |
| 0   | Lab bootstrap                               | 1 wk     | 2026-05-05  | 10    |
| 1   | Linux & networking in anger                 | 4 wks    | 2026-06-02  | 50    |
| 2   | Kubernetes deep dive (+ CKA)                | 6 wks    | 2026-07-14  | 70    |
| 3   | Configuration management with Ansible       | 4 wks    | 2026-08-11  | 50    |
| 4   | IaC + GitOps                                | 4 wks    | 2026-09-08  | 50    |
| 5   | Observability + SRE practices               | 5 wks    | 2026-10-13  | 60    |
| 6   | Specialize + interview prep                 | 5 wks    | 2026-11-17  | 60    |
| 7   | Polish + apply                              | 2 wks    | 2026-12-01  | 20    |

Total: ~31 weeks, ~370 hours. Slip is expected — track it explicitly in `tasks/todo.md` and reset target dates rather than pretending.

## Phase summaries

### Phase 0 — Lab bootstrap (`phases/00-bootstrap.md`)

Pi + VPS hardened and Wireguarded. Idempotent Bash bootstrap so any host can be nuked and rebuilt in <15 min.

### Phase 1 — Linux & networking (`phases/01-linux-networking.md`)

Prove "decent at networking" is real: nftables, systemd unit writing, namespaces & cgroups (container-from-scratch), own DNS + own CA, reverse proxy with TLS via Let's Encrypt DNS-01, debug with `tcpdump` / `dig` / `ss`. Self-host 2–3 services on Pi exposed via VPS over Wireguard.

### Phase 2 — Kubernetes deep dive (`phases/02-kubernetes.md`)

Walk *Kubernetes the Hard Way* against the lab, then redo with k3s for daily use. Cilium CNI, Traefik ingress, cert-manager. Migrate phase-1 services as Helm releases. Sit the **CKA** exam at the end as a forcing function.

### Phase 3 — Configuration management with Ansible (`phases/03-ansible.md`)

The most directly French-market-aligned phase. Manage the lab declaratively via Ansible: roles, inventory, `ansible-vault`, Molecule-tested. Convert the phase-0 Bash bootstrap to a `base-host` role; keep both side-by-side as a learning artifact. Lab note: the temporary VPS expires at the start of this phase — rent a small Hetzner box click-ops style (you'll automate it away in phase 4).

### Phase 4 — IaC + GitOps (`phases/04-iac-gitops.md`)

Terraform provisions infra (replacing the click-opped Hetzner box from phase 3 with a TF-managed one), Ansible from phase 3 configures it, Argo CD reconciles app state on the cluster. The canonical French-market trifecta. Hand-written Helm chart per service. Burn the lab down and rebuild from `git clone` + three commands.

### Phase 5 — Observability + SRE practices (`phases/05-observability-sre.md`)

Self-install LGTM stack. Instrument an app with OpenTelemetry (preferably a fresh **Go** service, not the TS one). Define SLIs/SLOs and implement multi-window burn-rate alerts. Run a game day, write the postmortem. Read the Google SRE book + workbook in parallel.

### Phase 6 — Specialize + interview prep (`phases/06-specialize.md`)

Pick a flavor (Infra / Reliability / Platform-DevEx) based on what felt best in phases 2–5. Capstone project in that flavor — **shipped in Go regardless of flavor**. The Platform flavor is the densest: a full **release-engineering capstone** (feature flag service in Go, Argo Rollouts canary + blue-green, SLO-driven auto-rollback, release automation, enforced trunk-based branching). In parallel: weekly system design + weekly troubleshooting drill.

### Phase 7 — Polish + apply (`phases/07-polish-apply.md`)

Portfolio-quality READMEs, 2–3 blog posts deep enough to prove understanding, then apply.

## Cross-cutting habits

- **`tasks/lessons.md`** — append per phase. What surprised me, what bit me, what I'd do differently. Highest interview signal in the whole repo.
- **One incident drill per phase** — intentional breakage, timed TTD/TTM, written postmortem.
- **Language drip — 15% Go + 10% Python per phase.** Go is leaned into harder than Python: by phase 6 you should be writing controllers, CLIs, and small services in Go without reaching for TS as a fallback. Python is leverage for Ansible (phase 3) and general automation. Go is the lingua franca of the K8s ecosystem and SRE tooling — the more comfortable you are reading and writing it by interview season, the better. The phase 6 capstone ships in Go regardless of flavor.
- **Game day per phase** — pick something to break, time the recovery.

## Heads-ups

- **French market shape.** The job market this program optimizes for is heavy on Ansible, Terraform, GitLab CI, OVH/Scaleway, and Python; lighter on Go than the US cloud-native bubble. The plan reflects this — phase 3 is dedicated to Ansible, phase 4 to Terraform + GitOps, language drip includes Python, and CI examples lean GitLab. (Go is still emphasized because the K8s ecosystem demands it for capstone work.)
- **Lab transition at start of phase 3.** The current second VPS is available until ~2026-07. Phases 0–2 run on it. At the start of phase 3 (Ansible) you'll rent a temporary Hetzner box manually — exactly the click-ops you'll automate away in phase 4.
- **Pi memory ceiling.** The full LGTM stack will choke a Pi 4. Plan: heavy obs components (Prometheus, Loki) on the VPS, agents on the Pi.
- **Public k8s API surface.** The VPS is internet-facing. Audit logging, RBAC, NetworkPolicies from day one in phase 2 — not "later".
- **CKA cost & timing.** Around $395 (voucher discounts often available). Book it as a hard deadline at the start of phase 2; nothing focuses preparation like a paid clock.
- **Language gap.** TS/Node alone won't cut it. The 15% Go + 10% Python drip per phase is non-negotiable — Go especially, since the K8s ecosystem and most SRE tooling converges on it. Python pays off immediately in phase 3 (Ansible). Go pays off across phases 4–7 (TF provider stretch, OTel instrumentation, capstone, controller reading).
