# Phase 0 — Lab bootstrap

**Duration:** 1 week  
**Target end:** 2026-05-05  
**Hours budget:** ~10

## Goal

Get the lab VPS to a known, hardened, repeatable state. Idempotent Bash split into focused scripts; the host can be nuked and rebuilt in <15 min with no manual fiddling.

> **Use the 2nd OVH VPS** as the phase-0 sacrificial host (the prod VPS stays untouched). The "rebuild from blank in 15 min" drill requires freedom to nuke and re-provision via OVH console — that's exactly what the 2nd box is for.

> **Lab git workflow (locked in from this phase onward):** all lab repos use **trunk-based development** — short-lived feature branches, PRs reviewed (formally, even by yourself), no direct commits to main. Branch protection enforces it from phase 3 onward (when CI is in place to gate on). Feature flags for in-progress work that needs to land but isn't ready (env vars before phase 6, real flag service after). Document the *why* of trunk-based-over-Gitflow for this lab in `tasks/whiteboards/00/branching.md` — it'll be referenced again in phase 3.

## Why this phase

This is the smallest possible "infrastructure as code" exercise. Bash now, Ansible in phase 2, Terraform in phase 3. The discipline starts here: idempotent scripts, no manual `apt install` you can't reproduce.

## Deliverable

A `lab-bootstrap/` directory (top-level in this repo) containing idempotent Bash scripts that take a fresh Ubuntu Server image to:

- Non-root user with SSH key auth, password login disabled.
- nftables/ufw enabled with only SSH allowed.
- fail2ban installed and configured for SSH.
- unattended-upgrades enabled with reboot policy decided.

**Definition of done:** nuke the lab VPS via provider console, run the bootstrap script, and the host returns to the hardened state in under 15 min with no manual fiddling after `ssh-copy-id`.

> **Wireguard moves to phase 2.** With the Pi dropped from the program, there's no day-1 peer for a mesh. WG installs fresh in phase 2 alongside Proxmox bring-up, where the work-laptop ↔ Proxmox use case actually motivates it.

## Checklist

- [x] Confirm SSH access to a sacrificial host (2nd OVH VPS used — prod VPS stays untouched, freedom to nuke/rebuild via OVH console).
- [x] `lab-bootstrap/bootstrap-host.sh` — strict-mode Bash; deploy user + sudoers NOPASSWD + gh.keys → authorized_keys + sshd_config hardening via `00-hardening.conf`.
- [x] Idempotency test for `bootstrap-host.sh` — second run shows only expected file rewrites, no new state. Drill 1 wall time: **3:04** (target <15 min).
- [ ] `lab-bootstrap/bootstrap-firewall.sh` — nftables, default-deny inbound, allow port 22.
- [ ] `lab-bootstrap/bootstrap-fail2ban.sh` — install + sshd jail (port 22 defaults).
- [ ] `lab-bootstrap/bootstrap-unattended.sh` — unattended-upgrades + reboot policy decided.
- [ ] `lab-bootstrap/bootstrap.sh` — top-level orchestrator: host → firewall → fail2ban → unattended.
- [ ] Document the bootstrap procedure in `lab-bootstrap/README.md`.
- [ ] **Incident drill:** revoke your own SSH key on the VPS. Recover via the provider's console rescue mode. Time it.

## Resources

- Bash strict mode (the canonical article) — `set -euo pipefail`, traps, IFS.
- `man systemd.service` — read it once. You'll write your own units in phase 1.

## Stretch

- Provision the VPS itself via `cloud-init` user-data so re-provisioning is one provider-API call away (you'll lean on this in phase 3).
- Tiny health-check timer that writes `/var/log/lab-health.log` and gets scraped in phase 5.
- Replace ufw with hand-written nftables rules — you'll need this fluency in phase 1 anyway.
- **Convert `bootstrap-host.sh` to an Ansible playbook.** Pure preview of phase 2. The Bash-vs-Ansible diff side-by-side is one of the most useful learning artifacts you'll produce; commit both. Don't replace the Bash version — keep both, and note in `lessons.md` what each model gets right.

## Lessons

When this phase ends, ensure `lessons.md` has the 3–5 things that bit you or surprised you.
