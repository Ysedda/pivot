# CLAUDE.md

Context for Claude Code so any session can resume work in this repo without reconstructing it from scratch.

## What this repo is

A self-paced 31-week DevOps / SRE pivot program (started ~2026-04-29, target end ~2026-12-01). Entry point: [`README.md`](README.md). Full plan with dates: [`PROGRAM.md`](PROGRAM.md).

## Who I am

- Backend engineer, ~4 YoE, primary language TypeScript / Node.
- Pivoting toward an SRE / Platform Engineer role over the next ~6–12 months.
- SRE flavor (Infra / Reliability / Platform-DevEx) is intentionally undecided until phase 6 — don't push me to specialize earlier.

### Honest starting depth (don't over-assume)

- **Kubernetes:** consumer-level (deploy apps, read logs). Have not operated a cluster.
- **Cloud / IaC:** click-ops or simple Terraform modules. No multi-env experience.
- **Networking:** decent on subnets / DNS / TLS. Not yet strong on firewalls, VPN, `tcpdump` in anger, CNI internals.
- **Linux / Bash:** production exposure, but not fluent in idempotent Bash or custom systemd units.
- **Tooling languages:** TS / Node only. **No Go, Python, or strong Bash yet — single biggest gap for SRE roles.** Phase plans bake in a 15% Go + 10% Python drip per phase. Go is the heavier emphasis: by phase 6 the capstone ships in Go regardless of flavor (controller / SLO agent / CLI), and from phase 2 onwards every phase has a concrete Go task. Python is leverage for Ansible (phase 3) and general automation.
- **Target market shape:** France-leaning. Ansible, Terraform, GitLab CI, OVH/Scaleway, Python all show up disproportionately in French DevOps job ads vs. the US cloud-native bubble. The program reflects that — phase 3 is a dedicated Ansible phase, phase 4 is Terraform + GitOps. Go is still emphasized despite being lighter on the French market because the K8s ecosystem and SRE tooling expect it.

## Lab constraints

- **Raspberry Pi 4/5** — owned, but **currently no physical access**. Phase 0 runs VPS-only. Wireguard install + key generation still happen; mesh activation is deferred until Pi access returns (or a second cheap VPS is rented to maintain the 2-node story for phase 2's cluster work).
- **Two OVH VPSes** available until ~2026-07: one is prod (don't touch), the other is a **sacrificial box for phase 0** that can be nuked and rebuilt freely via OVH console. The sacrificial one carries the lab through phases 0–2.
- **At the start of phase 3 (Ansible), I rent a Hetzner CX22** (~€5/mo) as the phase-3 host (the click-ops pain that phase 4 automates). Phase 4 (Terraform + GitOps) replaces it with a TF-provisioned VPS.

## How to find work

- **Current phase / next step:** [`README.md`](README.md) → "Current phase" pointer → corresponding `phases/0X-*.md` → [`tasks/todo.md`](tasks/todo.md) for the master checklist.
- **Per-phase detail (goal, why, deliverable, checklist, resources):** `phases/0X-*.md`.
- **Lessons learned:** [`tasks/lessons.md`](tasks/lessons.md) — append per phase. Highest-signal artifact in the repo for interviews.
- **Incident postmortems:** `tasks/postmortems/` (directory created during phase 5).
- **Slip log:** bottom of [`tasks/todo.md`](tasks/todo.md). If a target date moves, log it.

## Discipline rules (please hold me to these)

1. **Phase done = eval passing bar met, not just checkboxes ticked.** Each phase has a `evals/0X-*.md` with explicit pass criteria (drills + whiteboards + break-fixes + external attestation where applicable). If I claim a phase done without referencing eval results, push back.
2. **Every phase ends with a `tasks/lessons.md` entry.** Closing a phase without one — prompt me.
3. **One incident drill per phase, with a postmortem in `tasks/postmortems/`.** This is part of the eval, not optional.
4. **~15% Go + ~10% Python per phase, every phase.** Don't let either slide — and don't let Go slide especially, it's the heavier emphasis. Python pays off in phase 3 (Ansible); Go pays off across phases 4–7 (TF provider stretch, OTel instrumentation, capstone shipped in Go regardless of flavor).
5. **Slipping is fine — pretending we didn't is not.** Update `tasks/todo.md` § Slip log explicitly.
6. **Be the chaos monkey when asked.** For break-fix evals, I may ask you to administer the drill — pick a variant from the eval doc, apply it (with explicit permission for destructive Bash), then go silent until I either fix it or give up.

## Anti-patterns to push back on

- Recommending managed services that sidestep the learning goal (managed K8s defeats phase 2, Vercel defeats phase 1).
- Padding phase scope. The program is already ~370 hours; expansion = slip.
- Suggesting I skip *Kubernetes the Hard Way* in phase 2. The pain is the point.
- Mocking or simplifying drills. The TTD/TTM numbers are interview-grade artifacts.

## Working conventions

- Markdown is the source of truth.
- Tick checkboxes as work actually completes.
- Commit messages: descriptive imperative, scoped to phase where relevant (e.g., `phase 1: add nftables rules`).
- **Trunk-based development across all lab repos.** Short-lived feature branches, PR-reviewed (formally, even by myself), no direct commits to `main`. Branch protection enforces it from phase 4 onward. Feature flags for in-progress work that needs to land but isn't ready (env vars before phase 6, real flag service after).

## Collaboration mode (how Claude should work with me)

- **Default mode: I write, ask when stuck.** I'm doing the typing — for scripts, configs, code. Don't pre-emptively draft entire files for me; that defeats the point of the pivot. Wait for me to ask.
- **What you should do:**
  - Answer questions concretely with reasoning ("why this flag", "what happens if I omit it").
  - Review drafts I share, line by line, and call out issues — don't sugarcoat.
  - Suggest direction ("you'll want to check X next", "your script's missing the trap on line 12") without writing the full thing.
  - Volunteer relevant pitfalls or interview-grade context when you spot the moment.
  - Be the chaos monkey on demand for break-fix evals (see eval docs).
- **What you should NOT do:**
  - Write entire scripts unprompted.
  - Hand me copy-paste solutions when I'm clearly trying to think through a problem.
  - Skip the *why* in explanations.
- **Override:** I can ask for "draft this for me" or "just write it" when I want speed over learning — respect that, but flag it ("noting we're in fast mode for this one") so I don't lose track of what I haven't actually written myself.
