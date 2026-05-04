# Phase 4 — Evals

**Passing bar:** Drills 1–3 pass + at least 2 of 3 break-fixes pass + both whiteboards delivered + **CKA exam passed**. The CKA is the non-negotiable external attestation; without it, the phase is incomplete regardless of other progress. ~10 hours of eval time excluding the CKA itself.

## Drill 1 — From-memory deploy (target: 20 min, kubernetes.io docs allowed)

On a clean namespace, deploy a brand-new app you haven't used in this lab before (e.g., a tiny Go HTTP server or `nginxdemos/hello`). From memory, write YAML for:

- Deployment with 2 replicas, resource requests + limits, liveness + readiness probes.
- Service (ClusterIP).
- Ingress with a hostname routed via Traefik.
- cert-manager Certificate issued via Let's Encrypt.

Apply, wait, then `curl https://<host>` returns 200 with a valid cert.

**Pass:** clean curl in <20 min, no copy-paste from your existing repo.
**Partial:** 20–40 min, or one resource taken from a kubernetes.io example without modification.
**Fail:** otherwise.

## Drill 2 — CNI packet trace (target: 30 min)

Pod-to-pod across nodes. Two pods on different Proxmox VMs. Make a request between them and capture:

1. Source pod's veth — outgoing packet.
2. cilium_host (or equivalent) — encapsulation in progress.
3. The cluster overlay interface (cilium_vxlan / cilium_geneve, or the host's eth0 if Cilium is in native-routing mode) — encapsulated or routed traffic between nodes.
4. Destination veth — packet entering the target pod.
5. Cilium flow log: `cilium monitor` showing the policy verdict.

**Pass:** five captures + a short note explaining the dataplane mode (VXLAN vs Geneve vs native routing) and what changes between them.

## Drill 3 — CKA mock at speed (target: 2 hours)

Sit a full timed mock on killer.sh or killercoda.com.

**Pass:** ≥90% on the mock. This is the predictor for the real exam.
**Partial:** 80–90% — diagnose weak categories, drill them, retake.
**Fail:** <80% — defer real exam booking until you hit 85%+ twice.

## Break-fix 1 — NetworkPolicy breaks DNS (target: 20 min)

Claude applies a NetworkPolicy that's almost-correct but breaks egress to kube-system/coredns.

**Pass:** identify with `kubectl exec ... nslookup` + `kubectl logs -n kube-system coredns` + `cilium monitor`, fix the policy, all in <20 min.

## Break-fix 2 — CrashLoopBackOff diagnosis (target: 10 min)

Claude deploys a pod that crashloops for one of: missing config, wrong image tag, missing volume mount, OOMKill from too-low limits, failing init container, broken probe path.

**Pass:** root cause identified from `kubectl describe` + `kubectl logs -p` + events in <10 min.

## Break-fix 3 — etcd member down (target: 15 min, KTHW cluster only)

Applies only if you kept the KTHW 3-node cluster alive. Claude stops one etcd. You diagnose via `etcdctl endpoint status` and restore quorum.

**Pass:** quorum restored in <15 min without data loss. (If you only kept k3s, skip this drill — but try to keep the KTHW cluster alive at least through evals.)

## Whiteboard 1 — Control plane on paper (target: 15 min)

Draw and label every control-plane component (apiserver, etcd, scheduler, controller-manager, kubelet, kube-proxy, container runtime). Then trace what each one does between `kubectl apply -f deployment.yaml` and a running container. Annotate every API call.

## Whiteboard 2 — CNI vs kube-proxy vs CoreDNS (target: 10 min)

Explain the responsibilities of each, where they overlap, and where Cilium's eBPF mode replaces parts of kube-proxy. Why might you still want kube-proxy alongside Cilium? When wouldn't you?

## External attestation

- **CKA exam pass.** Schedule in week 1, sit in week 6. This is the phase's defining proof point.

## Retention check (schedule for 2026-10-13)

Redo Drill 2 (the CNI packet trace). Networking under K8s is the part most likely to fade.
