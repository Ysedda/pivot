# Roadmap

Ordered by how often the topic comes up in interviews, and so each block builds on the previous one.

**Rules**

- A unit is done when: built by me, broken on purpose and fixed, and I can explain it out loud (Claude quizzes, I answer without notes). Then lessons are written.
- Each block ends with a short mock interview on that block.
- No dates. If nothing moved for 2 weeks, pick the smallest open unit and do just that.
- 🐹 = Go work on the service in `app/` (created in 1.3).

## 0. Kickoff

- [x] Baseline gap check: [baseline/2026-10-30.md](baseline/2026-10-30.md)
- [x] New repo, old plan archived (private, local `pivot-v1`)
- [x] 5–6 interview stories (situation, task, action, result) from work, anonymized, kept **outside** this repo
- [x] CV and LinkedIn headline repositioned: "backend engineer who runs production"

## 1. Linux & the lab host

- [ ] **1.1 Reinstall Proxmox myself.** Wi-Fi with `wpa_supplicant`, static IP, NAT bridge for guests. Write down each decision in [lab/](lab/): why NAT (bridging over Wi-Fi doesn't work), what `ip_forward` and `MASQUERADE` do, LVM-thin vs ZFS.
- [ ] **1.2 Incident: the host keeps dropping off the network.** Find the causes from the logs (`journalctl -b -1`, `iw`, `logind.conf`), fix them, write [postmortem #1](postmortems/).
- [ ] **1.3 Processes and signals.** SIGTERM vs SIGKILL, exit codes 143/137, zombies, the PID 1 problem. 🐹 Start `app/`: an HTTP server that drains in-flight requests on SIGTERM, with a test. (go-tdd chapters first: pointers & errors, maps, dependency injection.)
- [ ] **1.4 systemd.** Write a unit for the Go service: restart policy, journald, `systemctl status` and `journalctl -u` reading.
- [ ] **1.5 Troubleshooting method.** USE (utilization, saturation, errors) per resource. Drills with `stress-ng`: CPU hog, memory leak to OOM kill, disk full, I/O saturation. Claude breaks, I find it, timed.
- [ ] **1.6 Hardening on a VM.** Re-run [lab-bootstrap/](lab-bootstrap/) on a cloud-init VM, finish unattended-upgrades and the orchestrator script, prove idempotency.

## 2. Networking

- [ ] **2.1 Life of a request.** DNS (`dig +trace`), TCP handshake (`tcpdump`), TLS handshake (`openssl s_client`), HTTP (`curl -v`). Explain each step on a whiteboard.
- [ ] **2.2 DNS failure drills.** Broken `resolv.conf`, unreachable resolver, blocked port 53, wrong record. Diagnose with `dig @server`.
- [ ] **2.3 Routing, NAT and firewalls.** Trace the lab's own NAT path, conntrack, nftables rules on a VM. Default-deny, fail-closed.
- [ ] **2.4 TLS for real.** Own CA, issue certs, reverse proxy in front of the Go service. 🐹 Server timeouts, client retries with backoff and jitter.
- [ ] Mock interview: block 2. Retake the baseline.

## 3. Containers

- [ ] **3.1 A container from scratch.** `unshare` for namespaces, cgroups v2 limits, a root filesystem. Then compare with what `docker run` does.
- [ ] **3.2 Images.** Layers and cache, multi-stage build, scratch/distroless, non-root, signal handling as PID 1. 🐹 Dockerfile for `app/`.
- [ ] **3.3 Image CI.** GitHub Actions builds on pull request, pushes to GHCR on merge, tags by version.
- [ ] Mock interview: block 3.

## 4. Kubernetes internals

- [ ] **4.1 Build a cluster with kubeadm** on 3 Proxmox VMs (1 control plane, 2 workers). Stretch: Kubernetes the Hard Way.
- [ ] **4.2 What happens on `kubectl apply`.** API server, etcd, controllers, scheduler, kubelet, container runtime. Watch it happen with events and etcd keys.
- [ ] **4.3 Cluster networking.** CNI (Cilium), how a Service IP reaches a pod (kube-proxy rules or eBPF), CoreDNS. Trace one packet.
- [ ] **4.4 Workload config.** Liveness vs readiness vs startup probes, requests/limits and QoS, OOM kills, ConfigMaps and Secrets. 🐹 `/healthz`, `/readyz`, config from env.
- [ ] **4.5 Debug drills.** CrashLoopBackOff, ImagePullBackOff, Pending, OOMKilled, DNS failures. Claude breaks, I fix, timed.
- [ ] **4.6 Storage.** PV, PVC, StorageClass, a StatefulSet surviving a node reboot.
- [ ] **4.7 Upgrade the cluster by one minor version** with `kubeadm upgrade`, without downtime for the Go service.
- [ ] Mock interview: block 4. Retake the baseline. Optional: CKA.

## 5. Infrastructure as code

- [ ] **5.1 OpenTofu creates the VMs** (`bpg/proxmox` provider). Rebuild the block 4 cluster VMs from code.
- [ ] **5.2 State.** What's inside, remote backend with locking, what two concurrent applies do.
- [ ] **5.3 Drift and import drills.** Change something by hand, read the plan, fix it three ways. Import an unmanaged resource.
- [ ] **5.4 Ansible basics.** Configure the VMs after creation (common in French job ads). Turn one lab-bootstrap script into a role and compare.
- [ ] Mock interview: block 5.

## 6. GitOps & delivery

- [ ] **6.1 Argo CD from scratch**, managing itself.
- [ ] **6.2 Helm chart for the Go service**, written by hand; app-of-apps or ApplicationSet.
- [ ] **6.3 Promotion and rollback.** dev → prod through pull requests, rollback with `git revert`, drift and self-heal drill.
- [ ] **6.4 Secrets.** SOPS or Sealed Secrets, nothing in plaintext in git.
- [ ] Mock interview: block 6.

## 7. Operations & SRE

- [ ] **7.1 Metrics.** Prometheus and Grafana. 🐹 Rate, errors and duration metrics in the Go service.
- [ ] **7.2 Logs and traces.** Loki, OpenTelemetry traces from the Go service.
- [ ] **7.3 SLOs and alerts.** Define an SLO, multi-window burn-rate alerts.
- [ ] **7.4 Incident drill.** Claude breaks production at a random time; I run the response, mitigate first, write the postmortem.
- [ ] Mock interview: block 7. Retake the baseline.

## Stretch (only if a target role asks for it)

- 🐹 A small Kubernetes controller with kubebuilder, or a CLI for the Proxmox API.
- Flux instead of Argo CD, to compare.
- Talos Linux instead of kubeadm.
