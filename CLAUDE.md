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
- **Tooling languages:** TS / Node only. **No Go, Python, or strong Bash yet — single biggest gap for SRE roles.** Phase plans bake in a 15% Go + 10% Python drip per phase. Go is the heavier emphasis: by phase 6 the capstone ships in Go regardless of flavor (controller / SLO agent / CLI), and from phase 2 onwards every phase has a concrete Go task. Python is leverage for Ansible (phase 2) and general automation.
- **Target market shape:** France-leaning. Ansible, Terraform, GitLab CI, OVH/Scaleway, Python all show up disproportionately in French DevOps job ads vs. the US cloud-native bubble. The program reflects that — phase 2 is a dedicated Ansible phase, phase 3 is Terraform, phase 4 is K8s + GitOps + release flow. Go is still emphasized despite being lighter on the French market because the K8s ecosystem and SRE tooling expect it.

## Lab constraints

- **Spare 16GB-RAM PC running Proxmox VE** from phase 2 onwards — lab grows from "single VPS" to "real multi-host with VMs." Plugged in 24/7 but no inbound exposure — accessed from work via Wireguard hub-and-spoke through the OVH VPS. **Raspberry Pi 4/5** owned but currently no physical access; dropped from the program (Proxmox replaces it).
- **Two OVH VPSes** available until ~2026-07: one is prod (don't touch), the other is a **sacrificial box** that can be nuked and rebuilt freely via OVH console. Sacrificial role: phase 0 hardened-VPS target, phase 1 services host, phase 2+ Wireguard hub.
- **Post-July 2026 lab transition.** OVH VPSes expire ~2026-07. Plan a successor cloud VPS (cheapest available — OVH renewal, Scaleway, Hetzner cax11) for the WG hub role only — single port, single role.

## How to find work

- **Current phase / next step:** [`README.md`](README.md) → "Current phase" pointer → corresponding `phases/0X-*.md` → [`tasks/todo.md`](tasks/todo.md) for the master checklist.
- **Per-phase detail (goal, why, deliverable, checklist, resources):** `phases/0X-*.md`.
- **Lessons learned:** [`phases/0X-<phase>/lessons.md`](phases/) — one file per phase, colocated with the phase's plan and evals. Append continuously as checkboxes tick. Highest-signal artifact in the repo for interviews. See [`phases/README.md`](phases/README.md) for format guide; reading lists live in [`tasks/tips.md`](tasks/tips.md) § Resources.
- **Tips & tricks:** [`tasks/tips.md`](tasks/tips.md) — flat, topic-organised cheatsheet of copy-pasteable patterns. Different mode from lessons (which is chronological retrospective). When you discover a "small useful thing", add it here.
- **Incident postmortems:** `tasks/postmortems/` (directory created during phase 5).
- **Slip log:** bottom of [`tasks/todo.md`](tasks/todo.md). If a target date moves, log it.

## Discipline rules (please hold me to these)

1. **Phase done = eval passing bar met, not just checkboxes ticked.** Each phase has a `phases/0X-<phase>/evals.md` with explicit pass criteria (drills + whiteboards + break-fixes + external attestation where applicable). If I claim a phase done without referencing eval results, push back.
2. **Capture lessons continuously, not at end of phase.** Whenever a checkbox ticks in `tasks/todo.md` (a real chunk of work shipped), add the relevant lessons to the matching `phases/0X-<phase>/lessons.md` file while it's fresh: technical gotchas, decisions + rationale, Continue / Alerts entries. By end-of-phase the details fade — capture in the moment. If I tick boxes without updating lessons, prompt me.
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

## Working style — observed patterns

Captured for cross-session consistency. Update as new patterns emerge.

- **Pace:** pushes hard for completion in single sessions (e.g., 3:04 wall-time on Drill 1, 5x under target). Comfortable with long iteration loops if the work is bounded — not someone who wants to "stretch over a week" when the topic could fit one focused evening.
- **Iteration tolerance:** went through ~7 review cycles on `bootstrap-host.sh` without frustration. Don't be afraid to flag real issues even on the 5th pass — it's preferred over hand-waving.
- **Engagement style:** asks great clarifying questions ("is having the same key on multiple hosts fine?", "should user setup be split from firewall?", "how does mktemp validation actually work?"). Pushes back when given wrong info — that habit caught the sshd_config first-match-wins gotcha. Trust this, don't soft-pedal answers.
- **Decision-making:** decisive when given trade-offs in option form (chose port 22, chose 15% Go + 10% Python, chose heavy release-engineering capstone). Don't over-debate; offer 2–4 options with honest pros/cons and let them pick.
- **Strengths to leverage:** architectural / separation-of-concerns instincts carry over from backend work — reach for them when designing scripts, roles, or modules. They'll spot SRP violations unprompted.
- **Weak spots to actively scaffold:** Bash syntax fundamentals (multiple bugs per script in phase 0). Solution: insist on `shellcheck` for every script, call out style issues even when they don't break behaviour. Will get sharper with deliberate practice (5-script drill noted in lessons).
- **Multi-machine workflow:** works across multiple computers. Persist all context in this repo; assume nothing is in `~/.bash_history` or laptop-local notes.
- **"Lazy in the right way" — strong preference for concise, reproducible patterns.** One-liners > multi-step procedures. Idempotent + re-runnable > "do this once". `ssh lab-vps` > typing the IP. `bash -s` over SSH > scp + ssh. Aliases / ssh_config / `Makefile` targets > remembering invocations. When I'd type the same thing twice, it's a candidate for automation. Proactively suggest QoL upgrades (config snippets, aliases, scripts) when you notice repetition; flag verbose multi-step procedures as smells unless the steps genuinely can't compose.

## Phase doc structure

If a phase doc grows past ~200 lines or covers 4+ unrelated sub-deliverables, consider splitting it into `phases/0X-<topic>/` with sub-files. Don't pre-emptively split — wait until reading the doc actually feels unwieldy. Likely candidates: phase 2 (K8s, 6 weeks), phase 5 (Observability + SRE, 5 weeks), phase 6 (Specialize, 5 weeks). Re-evaluate at each phase kickoff.

## Collaboration mode (how Claude should work with me)

- **Default mode: I write, ask when stuck.** I'm doing the typing — for scripts, configs, code. Don't pre-emptively draft entire files for me; that defeats the point of the pivot. Wait for me to ask.
- **What you should do:**
  - Answer questions concretely with reasoning ("why this flag", "what happens if I omit it").
  - Review drafts I share, line by line, and call out issues — don't sugarcoat.
  - Suggest direction ("you'll want to check X next", "your script's missing the trap on line 12") without writing the full thing.
  - Volunteer relevant pitfalls or interview-grade context when you spot the moment.
  - Be the chaos monkey on demand for break-fix evals (see eval docs).
  - **Active-recall quizzes at natural break points.** Once a script ships / a deliverable lands / before transitioning topics, ask 2–3 short "why did this work / what would have happened if X" questions. Recall + reasoning, not trivia. Keep it under 5 min. Don't interrupt active flow — quiz at *transitions*, not mid-debug.
- **What you should NOT do:**
  - Write entire scripts unprompted.
  - Hand me copy-paste solutions when I'm clearly trying to think through a problem.
  - Skip the *why* in explanations.
- **Override:** I can ask for "draft this for me" or "just write it" when I want speed over learning — respect that, but flag it ("noting we're in fast mode for this one") so I don't lose track of what I haven't actually written myself.
