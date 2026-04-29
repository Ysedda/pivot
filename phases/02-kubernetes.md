# Phase 2 — Kubernetes deep dive

**Duration:** 6 weeks  
**Target end:** 2026-07-14  
**Hours budget:** ~70

## Goal

Move from K8s consumer to K8s operator. Understand every control-plane component, debug from the kubelet up, and pass the **CKA** exam at the end of the phase.

## Why this phase

This is the centerpiece of the SRE pivot. Most platform/infra SRE jobs assume operator-level K8s. Phase 1 made the underlying Linux real; phase 2 makes K8s stop being magic.

## Deliverable

Two-node cluster spanning Pi + VPS over Wireguard, with:

- **Cilium** as CNI (run Flannel first to establish baseline, then swap).
- **Traefik** ingress, **cert-manager** for TLS.
- All phase-1 services migrated as **hand-written Helm charts** (not generated, not copy-pasted).
- Audit logging enabled, RBAC tightened, NetworkPolicies non-default.

**Definition of done:** the same domain that served phase-1 services now resolves to ingress on the cluster, certs auto-renew, and `kubectl get networkpolicy -A` shows a non-trivial allowlist.

**Forcing function:** schedule the **CKA exam** in week 6 of this phase. Book it in week 1.

## Checklist

### Read first, install second
- [ ] Read about each control-plane component before installing anything: apiserver, etcd, scheduler, controller-manager, kubelet, kube-proxy. One paragraph per component in `tasks/lessons.md`.
- [ ] Understand the kubelet–CRI–container-runtime path. Know what containerd actually does.

### Kubernetes the Hard Way
- [ ] Walk Kelsey Hightower's *Kubernetes the Hard Way*, adapted to lab (Pi + VPS over wg).
- [ ] Generate certs by hand for the control plane. Don't skip this — it's the part that pays interview dividends.
- [ ] Bring up etcd, apiserver, controller-manager, scheduler, kubelet, kube-proxy — manually. Get a pod running.
- [ ] **Then tear it all down** and reinstall with k3s for daily use. The point was the journey.

### CNI deep dive
- [ ] Install Flannel on k3s. Trace a packet pod → pod across nodes with `tcpdump` on the wg interface.
- [ ] Replace Flannel with Cilium. Compare. Read about eBPF dataplane vs iptables kube-proxy mode.
- [ ] Apply a `NetworkPolicy` that breaks one of your services. Diagnose with `kubectl describe` and `cilium monitor`.

### Workload primitives
- [ ] One workload of each: Deployment, StatefulSet (Gitea with PVC), DaemonSet (a node-exporter), Job, CronJob.
- [ ] Probes: liveness vs readiness vs startup — write all three on one workload, intentionally fail each, observe.
- [ ] Resources: requests vs limits. Trigger an OOMKill on purpose. Trigger a CPU throttle. Read `kubectl top` and `/sys/fs/cgroup`.
- [ ] PodDisruptionBudget + node drain — drain a node, confirm graceful behavior.

### Storage
- [ ] local-path-provisioner for first PVCs.
- [ ] Then **Longhorn** for replicated storage across Pi and VPS. Survive a node reboot with data intact.

### Security & ops
- [ ] Enable apiserver audit logging. Ship to a file on the VPS (you'll move to Loki in phase 5).
- [ ] Tighten RBAC: a non-admin ServiceAccount with the minimum permissions to deploy your apps.
- [ ] NetworkPolicies: default-deny per namespace, allow only what's needed.
- [ ] Try `kubeaudit` or `kube-bench` and fix at least 5 findings.

### Helm
- [ ] Write a hand-rolled Helm chart for one of your services. Templates, values, helpers, NOTES.txt. No `helm create` boilerplate.
- [ ] `helm upgrade --atomic --wait` your way to a clean deploy.

### CKA prep
- [ ] Book the exam in week 1 of this phase.
- [ ] Practice on killercoda.com / killer.sh until 90%+ on timed mock exams.
- [ ] Sit the exam.

### Drill
- [ ] **Incident drill:** kill etcd on purpose (snapshot first!). Recover. Time it. Postmortem.

## Resources

- *Kubernetes the Hard Way* — Kelsey Hightower (free, on GitHub).
- *Kubernetes Up & Running* (Hightower / Burns / Beda) — reference, not cover-to-cover.
- killercoda.com / killer.sh — CKA scenarios.
- Cilium docs — https://docs.cilium.io/
- Helm docs — https://helm.sh/docs/

## Stretch

- Try Talos Linux instead of Ubuntu under k3s. Immutable infra is the future.
- Add a second worker (cheapest Hetzner box). Three-node cluster, real failure scenarios.
- Read one Kubernetes Enhancement Proposal (KEP) start to finish for something recently shipped. Get a feel for how K8s evolves.
- **Go drip:** write a tiny Go HTTP server (`net/http`, ~50 lines), build it with a multi-stage Dockerfile, deploy via your hand-rolled Helm chart. The first piece of Go code in your lab — and the foundation for instrumenting in phase 5.

## Lessons

Append § Phase 2 to `tasks/lessons.md`. Be honest about what you didn't understand the first time.
