# Phase 1 — Linux & networking in anger

**Duration:** 4 weeks  
**Target end:** 2026-06-02  
**Hours budget:** ~50

## Goal

Turn "decent at networking" into real depth. By the end of this phase you should be able to debug a broken Linux box and a misrouted packet without Stack Overflow.

## Why this phase

K8s in phase 2 is a giant abstraction over Linux primitives — namespaces, cgroups, iptables, DNS, certs. If those primitives are fuzzy, K8s will feel like magic, and magic is what fails on call at 3am.

## Deliverable

Self-host 2–3 services on the Pi, exposed via the VPS as a reverse proxy, with TLS issued via Let's Encrypt DNS-01, all traffic between Pi and VPS over Wireguard.

Suggested service stack: **Gitea** + **Vaultwarden** + a tiny **status page** (could be a single TS/Node app you already wrote). Later phases will migrate these into Kubernetes — pick something you actually want to use, the dogfooding matters.

**Definition of done:** opening `https://gitea.<your-domain>` (or whichever) in a browser shows a valid cert and a working app, and a `tcpdump` on the Pi confirms traffic arrives via the wg interface.

## Checklist

### Linux primitives
- [ ] Write a real systemd unit (not `nohup`) for a long-running script. Add `Restart=`, `WatchdogSec=`, `journalctl -u` cleanly.
- [ ] Build a "container from scratch": `unshare` for namespaces + `cgcreate` for cgroups + a chrooted rootfs from `debootstrap`. Run a process, prove it's isolated.
- [ ] Read & summarize: `man namespaces(7)`, `man cgroups(7)`. One paragraph each in `tasks/lessons.md`.

### Firewall & networking
- [ ] Replace ufw with hand-written **nftables** rules. Inbound: SSH only from wg subnet, HTTP/HTTPS from internet on VPS, nothing public on Pi.
- [ ] Configure source-NAT or routing so Pi-hosted services are reachable via the VPS public IP.
- [ ] Run `tcpdump -i wg0` while curling a service. Confirm what you expect to see.

### DNS & TLS
- [ ] Point a real domain (sub-domain of one you own) at the VPS. Set up DNS records in your registrar or Cloudflare.
- [ ] Run your own internal CA (e.g., `step-ca` or `cfssl`). Issue a cert for an internal-only service. Trust it on your laptop.
- [ ] For public services: Caddy or Traefik with Let's Encrypt **DNS-01** challenge (so you can issue wildcard certs without exposing port 80 publicly on the Pi).
- [ ] Inspect a cert on the wire: `openssl s_client -connect host:443 -servername host`.

### Services
- [ ] Deploy Gitea + Vaultwarden + status page on the Pi as Docker Compose stacks. Persist data on a known path, document backup strategy.
- [ ] Reverse proxy on the VPS forwards to Pi over wg. TLS terminated at the VPS.
- [ ] Set up automated backups (rsync or restic) of service data to the VPS or a cheap object store. Verify a restore.

### Drills
- [ ] **Incident drill:** intentionally misconfigure DNS or break a cert. Debug end-to-end without reverting. Write a postmortem in `tasks/lessons.md`.

## Resources

- *The Linux Programming Interface* (Kerrisk) — chapters on namespaces, cgroups. Skim, don't grind.
- *Linux Network Administrator's Guide* — old but still correct on the fundamentals.
- nftables wiki — https://wiki.nftables.org/
- Caddy docs (DNS-01) — https://caddyserver.com/docs/

## Stretch

- IPv6 on the wg mesh. Real-world preparation; many cloud providers default-on now.
- Run `mtr` and `traceroute` in both directions during a drill. Understand asymmetric routing.
- Replace Docker Compose with rootless Podman. You'll appreciate it in phase 2.

## Lessons

End of phase: append § Phase 1 to `tasks/lessons.md`.
