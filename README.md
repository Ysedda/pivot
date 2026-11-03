# pivot

Backend engineer (TypeScript/Node, ~4 years) moving toward **DevOps / SRE / platform** and **non-CRUD backend** roles.

I already run a production Kubernetes platform at work (OpenTofu, Argo CD, CloudNativePG, Grafana stack). I can operate it, but I want to be able to *explain* every layer under the commands I type. This repo rebuilds those layers from scratch on a home lab, one small unit at a time, and keeps the notes.

## How it works

- **Units, not phases.** Each unit is 1–3 hours and self-contained, so progress survives busy weeks. See [ROADMAP.md](ROADMAP.md).
- **Done = I can explain it.** A unit is ticked when it's built, broken on purpose, fixed, and I can walk through it out loud, not when the commands ran once.
- **One Go service travels the whole roadmap.** Graceful shutdown, then TLS, then a minimal image, probes, GitOps delivery, metrics and SLOs, all on code I wrote.
- **Incidents get postmortems.** Real ones from the lab and drills on purpose: [postmortems/](postmortems/).

## Where things are

| Path | What |
| --- | --- |
| [ROADMAP.md](ROADMAP.md) | All units, by block, with what "done" means for each |
| [units/](units/) | Per unit: what to read, exercises, build, break, explain |
| [baseline/](baseline/) | Where I started (gap check, 2026-10-30), retaken after blocks 2, 4 and 7 |
| [lab/](lab/) | The lab: hardware, network design, decisions |
| [lessons/](lessons/) | What surprised me or bit me, per block |
| [tips.md](tips.md) | Flat cheatsheet of patterns worth keeping |
| [lab-bootstrap/](lab-bootstrap/) | Idempotent Bash hardening scripts (SSH, nftables, fail2ban) |
| [postmortems/](postmortems/) | Incident write-ups |

## Lab

One Proxmox VE box (i7-12650H, 10 cores / 16 threads, 15 GB RAM, 1 TB NVMe) on a home network. Wi-Fi only, so guests sit on a NAT bridge. Details and the reasoning in [lab/](lab/).

## Current unit

→ **1.1 Reinstall Proxmox myself** ([ROADMAP.md](ROADMAP.md#1-linux--the-lab-host))
