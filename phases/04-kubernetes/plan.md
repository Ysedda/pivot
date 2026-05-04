# Phase 4 — Kubernetes + GitOps + release flow

**Duration:** 6 weeks  
**Target end:** 2026-09-01  
**Hours budget:** ~70

## Goal

Move from K8s consumer to K8s operator. Understand every control-plane component, debug from the kubelet up, pass the **CKA** exam, and make Argo CD the only mechanism that touches application state on the cluster. By the end of the phase, container images flow through a real CI pipeline with semver tags + RC pattern, and `kubectl apply` against app workloads is banned.

## Why this phase

This is the centerpiece of the SRE pivot. Most platform/infra SRE jobs assume operator-level K8s. Phases 1–3 made Linux, Ansible, storage, and TF real; phase 4 makes K8s stop being magic *and* enforces the GitOps reconciliation loop production teams rely on. The release-flow piece closes the loop from "code committed" to "running in prod" — the part most labs skip and most interviews ask about.

## Deliverable

A real cluster on Proxmox VMs (3-5 nodes within the 16GB envelope), with:

- **Cilium** as CNI (run Flannel first to establish baseline, then swap).
- **Traefik** ingress, **cert-manager** for TLS.
- All phase-2 services migrated as **hand-written Helm charts** (not generated, not copy-pasted).
- **Argo CD** installed and managing all app state. App-of-apps with auto-sync, prune, selfHeal.
- **Container image CI**: multi-stage Dockerfile per service, build-on-PR for validation, push-on-merge to a registry (GHCR or GitLab Registry).
- **Release flow**: semver tags trigger image tagging, RC pattern for staging→prod promotion, GitOps PRs update Argo `targetRevision` (see `tasks/release-flow.md`).
- One **secrets pattern** (SOPS+age / sealed-secrets / external-secrets) chosen + implemented.
- Audit logging enabled, RBAC tightened, NetworkPolicies non-default.

**Definition of done:** the same domain that served phase-2 services now resolves to ingress on the cluster, certs auto-renew, `kubectl get networkpolicy -A` shows a non-trivial allowlist, and a `kubectl edit` against an Argo-managed resource is reverted within seconds. A trivial PR end-to-end (PR → CI → merge → image push → Argo sync → running pod) completes in <10 min.

**Forcing function:** schedule the **CKA exam** in week 6 of this phase. Book it in week 1.

## Checklist

### Read first, install second
- [ ] Read about each control-plane component before installing anything: apiserver, etcd, scheduler, controller-manager, kubelet, kube-proxy. One paragraph per component in `lessons.md`.
- [ ] Understand the kubelet–CRI–container-runtime path. Know what containerd actually does.

### Kubernetes the Hard Way
- [ ] Walk Kelsey Hightower's *Kubernetes the Hard Way*, adapted to the lab (Proxmox VMs over the home LAN).
- [ ] Generate certs by hand for the control plane. Don't skip this — it's the part that pays interview dividends.
- [ ] Bring up etcd, apiserver, controller-manager, scheduler, kubelet, kube-proxy — manually. Get a pod running.
- [ ] **Then tear it down** and reinstall with k3s for daily use. The point was the journey.

### CNI deep dive
- [ ] Install Flannel on k3s. Trace a packet pod → pod across nodes with `tcpdump`.
- [ ] Replace Flannel with Cilium. Compare. Read about eBPF dataplane vs iptables kube-proxy mode.
- [ ] Apply a `NetworkPolicy` that breaks one of your services. Diagnose with `kubectl describe` and `cilium monitor`.

### Workload primitives
- [ ] One workload of each: Deployment, StatefulSet (Gitea with PVC), DaemonSet (a node-exporter), Job, CronJob.
- [ ] Probes: liveness vs readiness vs startup — write all three on one workload, intentionally fail each, observe.
- [ ] Resources: requests vs limits. Trigger an OOMKill on purpose. Trigger a CPU throttle. Read `kubectl top` and `/sys/fs/cgroup`.
- [ ] PodDisruptionBudget + node drain — drain a node, confirm graceful behaviour.

### Storage
- [ ] local-path-provisioner for first PVCs.
- [ ] Then **Longhorn** for replicated storage across Proxmox VMs. Survive a node reboot with data intact.

### Security & ops
- [ ] Enable apiserver audit logging. Ship to a file on a node (you'll move to Loki in phase 5).
- [ ] Tighten RBAC: a non-admin ServiceAccount with the minimum permissions to deploy your apps.
- [ ] NetworkPolicies: default-deny per namespace, allow only what's needed.
- [ ] Try `kubeaudit` or `kube-bench` and fix at least 5 findings.

### Helm
- [ ] Hand-rolled Helm chart per phase-2 service. Templates, values, helpers, NOTES.txt. No `helm create` boilerplate.
- [ ] Per-env values (`values.yaml` + `values-staging.yaml` + `values-prod.yaml`) — practice the pattern even within one cluster (namespace separation).
- [ ] `helm upgrade --atomic --wait` your way to a clean deploy.

### Container image CI
- [ ] Multi-stage Dockerfile per service: a build stage producing the artifact, a minimal runtime stage (`distroless` or `alpine`).
- [ ] CI on PR: build image (no push), validate (lint, scan with `trivy` if cheap).
- [ ] CI on merge to main: build + push to registry (GHCR or GitLab Registry). Tag with `:sha-<short>` (immutable) and `:main` (floating, for dev env auto-track).
- [ ] Image registry chosen (GHCR or GitLab) — document why in `lessons.md`. Both are free for public; GitLab integrates if you went GitLab CI in phase 3.
- [ ] At least one Helm chart consumes the registry-published image.

### Release flow
- [ ] **Read `tasks/release-flow.md` before starting this section** — covers semver tagging, RC pattern, GitOps promotion, environment separation, and versioning conventions.
- [ ] CI on git tag `vX.Y.Z-rc.N`: tag the same image (don't rebuild — bit-for-bit identical) as `:vX.Y.Z-rc.N`.
- [ ] CI on git tag `vX.Y.Z`: tag the existing image as `:vX.Y.Z`.
- [ ] Three Argo CD `Application`s per service: dev (tracks `:main`), staging (tracks `:vX.Y.Z-rc.*`), prod (tracks `:vX.Y.Z`). Or use an `ApplicationSet` to template across `apps-dev` / `apps-staging` / `apps-prod` namespaces.
- [ ] **Demonstrate one full release cycle:** feature branch PR → merge → dev deploys → cut `v0.1.0-rc.1` → staging deploys → cut `v0.1.0` → PR to bump prod's `targetRevision` → prod deploys. Time it end-to-end.

### Argo CD + GitOps
- [ ] Install Argo CD on the cluster (Helm). Manage Argo itself via Argo (auto-managed-by-self pattern).
- [ ] **App-of-apps**: one root `Application` pointing at `gitops/apps/`, which contains an `Application` per service.
- [ ] Auto-sync with `prune: true` and `selfHeal: true`. Test it: manually `kubectl edit` something Argo manages, watch it revert.
- [ ] Sync-failure alerting placeholder — wired to Alertmanager in phase 5.

### Secrets
- [ ] Pick *one* secrets pattern: SOPS + age, sealed-secrets, or external-secrets-operator backed by Vault / Bitwarden Secrets Manager. Document why over the alternatives.
- [ ] Migrate any hardcoded secrets in your Helm charts to that pattern.

### CKA prep
- [ ] Book the exam in week 1 of this phase.
- [ ] Practice on killercoda.com / killer.sh until 90%+ on timed mock exams.
- [ ] Sit the exam.

### Drills
- [ ] **Incident drill:** kill etcd on purpose (snapshot first!). Recover. Time it. Postmortem in `tasks/postmortems/`.
- [ ] **Drift drill:** delete a Deployment by hand, watch Argo restore it. Time the reconciliation interval.

## Resources

- *Kubernetes the Hard Way* — Kelsey Hightower (free, on GitHub).
- *Kubernetes Up & Running* (Hightower / Burns / Beda) — reference, not cover-to-cover.
- killercoda.com / killer.sh — CKA scenarios.
- Cilium docs — https://docs.cilium.io/
- Helm docs — https://helm.sh/docs/
- Argo CD docs (especially app-of-apps) — https://argo-cd.readthedocs.io/
- SOPS — https://github.com/getsops/sops
- `tasks/release-flow.md` — semver, RC pattern, GitOps promotion, versioning.

## Stretch

- Try Talos Linux instead of Ubuntu under k3s. Immutable infra is the future.
- Add a sixth Proxmox VM as a worker. Real failure scenarios.
- Read one Kubernetes Enhancement Proposal (KEP) start to finish for something recently shipped. Get a feel for how K8s evolves.
- **Go drip:** write a tiny Go HTTP server (`net/http`, ~50 lines), build it with the multi-stage Dockerfile pattern, deploy via your hand-rolled Helm chart. Foundation for instrumenting in phase 5.
- Replace Argo CD with **Flux** in a torn-down/rebuilt cluster. Compare. Form an opinion you can defend in interviews.
- Sign released images with `cosign` (free preview of phase-6 Platform capstone).

## Lessons

By end of phase, ensure `lessons.md` is honest about what you didn't understand the first time, especially: where Argo's reconciliation surprised you, the secrets-pattern tradeoffs, where the CNI dataplane behaved differently than expected, and the release-flow gotchas (image-tag immutability, promotion-by-PR vs mutating tags).
