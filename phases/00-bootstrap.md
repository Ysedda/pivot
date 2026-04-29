# Phase 0 — Lab bootstrap

**Duration:** 1 week  
**Target end:** 2026-05-05  
**Hours budget:** ~10

## Goal

Get the lab VPS to a known, hardened, repeatable state. Wireguard install + key generation are part of the bootstrap; the mesh isn't activated yet (Pi peer unavailable for now).

> **Adapted scope — Pi unavailable for now.** Phase 0 runs VPS-only. The bootstrap script installs Wireguard and generates keys, but the mesh stays inactive until the Pi returns (or a second VPS is rented for cluster work in phase 2). Don't block on this — the bootstrap script is the deliverable.

> **Use the 2nd OVH VPS** as the phase-0 sacrificial host (the prod VPS stays untouched). The "rebuild from blank in 15 min" drill requires freedom to nuke and re-provision via OVH console — that's exactly what the 2nd box is for.

> **Lab git workflow (locked in from this phase onward):** all lab repos use **trunk-based development** — short-lived feature branches, PRs reviewed (formally, even by yourself), no direct commits to main. Branch protection enforces it from phase 4 onward (when CI is in place to gate on). Feature flags for in-progress work that needs to land but isn't ready (env vars before phase 6, real flag service after). Document the *why* of trunk-based-over-Gitflow for this lab in `tasks/whiteboards/00/branching.md` — it'll be referenced again in phase 4.

## Why this phase

This is the smallest possible "infrastructure as code" exercise. Bash now, Ansible in phase 3, Terraform in phase 4. The discipline starts here: idempotent scripts, no manual `apt install` you can't reproduce.

## Deliverable

A `lab-bootstrap/` directory (top-level in this repo) containing idempotent Bash scripts that take a fresh Ubuntu Server image to:

- Non-root user with SSH key auth, password login disabled.
- nftables/ufw enabled with only SSH + Wireguard ports allowed.
- fail2ban installed and configured for SSH.
- unattended-upgrades enabled with reboot policy decided.
- Wireguard installed, keys generated, `wg0.conf` templated. **Mesh activation deferred** (no Pi peer yet).

**Definition of done:** nuke the lab VPS via provider console, run the bootstrap script, and the host returns to the hardened state in under 15 min with no manual fiddling after `ssh-copy-id`. Wireguard service installed and `wg-quick@wg0` configured (will activate once a peer is available).

## Checklist

- [ ] Rent a Hetzner CX22 (or equivalent ~€5/mo VPS) for phase-0 work — a sacrificial box you can nuke and rebuild freely.
- [ ] (deferred — Pi unavailable) Flash Ubuntu Server 24.04 LTS on Pi.
- [ ] (deferred — Pi unavailable) Reserve Pi IP on the router.
- [ ] Write `lab-bootstrap/bootstrap-host.sh` — strict-mode Bash; user creation, SSH hardening, firewall, fail2ban, unattended-upgrades.
- [ ] Test idempotency: run twice on the same host, second run must be a no-op (or only re-apply config drift).
- [ ] Generate Wireguard keys (one keypair per host, store privately — *not* in this repo).
- [ ] Write `lab-bootstrap/bootstrap-wireguard.sh` — installs wg, drops a templated config, enables `wg-quick@wg0` systemd unit (won't connect — peer absent — but service is installed and ready).
- [ ] (deferred — needs Pi peer) Verify mesh: `ping` over the wg IP both ways; check `wg show` handshake on both ends.
- [ ] Document the bootstrap procedure in `lab-bootstrap/README.md`. Note the Pi-deferred items explicitly.
- [ ] **Incident drill:** revoke your own SSH key on the VPS. Recover via the provider's console rescue mode. Time it. (When Pi access returns, repeat as wg-mediated recovery.)

## Resources

- WireGuard quickstart — https://www.wireguard.com/quickstart/
- Bash strict mode (the canonical article) — `set -euo pipefail`, traps, IFS.
- `man systemd.service` — read it once. You'll write your own units in phase 1.

## Stretch

- Provision the VPS itself via `cloud-init` user-data so re-provisioning is one provider-API call away (you'll lean on this in phase 4).
- Tiny health-check timer that writes `/var/log/lab-health.log` and gets scraped in phase 5.
- Replace ufw with hand-written nftables rules — you'll need this fluency in phase 2.
- **Convert `bootstrap-host.sh` to an Ansible playbook.** Pure preview of phase 3. The Bash-vs-Ansible diff side-by-side is one of the most useful learning artifacts you'll produce; commit both. Don't replace the Bash version — keep both, and note in `tasks/lessons.md` what each model gets right.

## Lessons

When this phase ends, write `tasks/lessons.md` § Phase 0 with the 3–5 things that bit you or surprised you.
