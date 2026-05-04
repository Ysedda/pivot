# Phase 1 — Linux & networking in anger

**Duration:** 4 weeks  
**Target end:** 2026-06-02  
**Hours budget:** ~50

## Goal

Turn "decent at networking" into real depth. By the end of this phase you should be able to debug a broken Linux box and a misrouted packet without Stack Overflow.

## Why this phase

K8s in phase 4 is a giant abstraction over Linux primitives — namespaces, cgroups, iptables, DNS, certs. If those primitives are fuzzy, K8s will feel like magic, and magic is what fails on call at 3am.

## Deliverable

Self-host 2–3 services on the lab VPS, with a reverse proxy fronting them and TLS issued via Let's Encrypt DNS-01.

Suggested service stack: **Gitea** + **Vaultwarden** + a tiny **status page** (could be a single TS/Node app you already wrote). Phase 2 migrates these declaratively to Proxmox VMs via Ansible — pick something you actually want to use, the dogfooding matters.

**Definition of done:** opening `https://gitea.<your-domain>` (or whichever) in a browser shows a valid cert and a working app, served from the VPS with the reverse proxy logging the request and a `tcpdump` capture confirming the TLS handshake.

> **Why no multi-host topology yet?** Pi is dropped from the program; Proxmox doesn't arrive until phase 2. Phase 1 stays single-host on the VPS — the reverse proxy is degenerate (localhost → localhost) but everything else (nftables, certs, DNS, tcpdump, namespaces) remains rich. Phase 2 introduces the multi-host story by migrating these services to Proxmox VMs over the WG hub.

## Checklist

### Linux primitives
- [ ] Write a real systemd unit (not `nohup`) for a long-running script. Add `Restart=`, `WatchdogSec=`, `journalctl -u` cleanly.
- [ ] Build a "container from scratch": `unshare` for namespaces + `cgcreate` for cgroups + a chrooted rootfs from `debootstrap`. Run a process, prove it's isolated.
- [ ] Read & summarize: `man namespaces(7)`, `man cgroups(7)`. One paragraph each in `lessons.md`.

### Firewall & networking
- [ ] Replace ufw with hand-written **nftables** rules. Inbound: SSH key-only, HTTP/HTTPS from internet, default-deny everything else.
- [ ] Run `tcpdump -i eth0` while curling a service. Identify ClientHello (SNI), TCP retransmits, response packets.
- [ ] Use `ss -tlnp` and `lsof -i` to map listening sockets to processes. Sanity-check that nothing surprising is listening.

### DNS & TLS
- [ ] Point a real domain (sub-domain of one you own) at the VPS. Set up DNS records in your registrar or Cloudflare.
- [ ] Run your own internal CA (e.g., `step-ca` or `cfssl`). Issue a cert for an internal-only service. Trust it on your laptop.
- [ ] For public services: Caddy or Traefik with Let's Encrypt **DNS-01** challenge (so you can issue wildcard certs without exposing port 80 publicly).
- [ ] Inspect a cert on the wire: `openssl s_client -connect host:443 -servername host`.

### Services
- [ ] Deploy Gitea + Vaultwarden + status page on the VPS as Docker Compose stacks. Persist data on a known path, document backup strategy.
- [ ] Reverse proxy on the VPS forwards to local services. TLS terminated at the proxy.
- [ ] Set up automated backups (rsync or restic) of service data to a cheap object store. Verify a restore.

### Drills
- [ ] **Incident drill:** intentionally misconfigure DNS or break a cert. Debug end-to-end without reverting. Write a postmortem in `tasks/postmortems/`.

## Resources

- *The Linux Programming Interface* (Kerrisk) — chapters on namespaces, cgroups. Skim, don't grind.
- *Linux Network Administrator's Guide* — old but still correct on the fundamentals.
- nftables wiki — https://wiki.nftables.org/
- Caddy docs (DNS-01) — https://caddyserver.com/docs/

## Stretch

- Run `mtr` and `traceroute` to/from your VPS during a drill. Understand asymmetric routing.
- Replace Docker Compose with rootless Podman. You'll appreciate it in phase 4.
- **Preview phase 2:** install Proxmox VE on the spare 16GB PC ahead of time so phase 2 starts faster. Don't yet bring up VMs.

## Lessons

End of phase: ensure `lessons.md` has all the major surprises captured.
