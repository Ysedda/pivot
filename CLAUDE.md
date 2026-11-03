# CLAUDE.md

Context for Claude Code so any session can pick up where the last one stopped.

## What this repo is

A burst-friendly learning roadmap toward DevOps / SRE / platform and non-CRUD backend roles, built on a home Proxmox lab. **Public portfolio**: keep employer and client names out of everything committed here. Restarted 2026-10-30; the first attempt (30-week phased plan, stalled after phase 0 in May 2026) is archived locally as `../pivot-v1`.

- Next step: README "Current unit" → [ROADMAP.md](ROADMAP.md).
- Starting level: [baseline/2026-10-30.md](baseline/2026-10-30.md).
- Lab facts: [lab/README.md](lab/README.md).

## Who I am

- Backend engineer, ~4 years, TypeScript / Node. Applying **now**, to non-CRUD backend roles and DevOps / SRE / platform roles.
- At work I operate a production Kubernetes platform day to day: OpenTofu, Argo CD ApplicationSets with wrapper charts, Traefik, cert-manager, CloudNativePG, External Secrets, Grafana/Loki/Tempo. **I use the commands a lot but I'm not confident on the fundamentals underneath** — the baseline confirms it (about 2/5). Don't assume depth because I know the tool names.
- Biggest gaps: Kubernetes internals, networking past DNS, processes and signals, a troubleshooting method.
- Go: did the first 5 chapters of Learn Go with Tests (private repo `go-tdd`, Nov 2025), then stopped. Go happens through the `app/` service in the roadmap (🐹 units); go-tdd chapters are pulled in when a unit needs the concept.
- Works in bursts: some weeks 4 hours, some weeks 30. Don't plan in weeks.

## Lab

- Proxmox VE 9 on a laptop (i7-12650H, 15 GB RAM), **Wi-Fi only**: host on `wlo1` 192.168.1.50, guests on `vmbr0` 10.10.10.0/24 behind NAT. Details in [lab/README.md](lab/README.md).
- The current install was done for me (fast mode) and is scheduled to be redone by me in unit 1.1.
- Known issue: the host drops off the network (power key press on 2026-10-25, Wi-Fi power saving on). That's unit 1.2 — let me debug it, don't hand me the fix.
- 15 GB RAM is the constraint for every Kubernetes and observability choice. Prefer lean components.

## Rules (hold me to these)

1. **Unit done = built, broken on purpose and fixed, and explained out loud without notes.** Quiz me before ticking. If I tick without the quiz, push back.
2. **Lessons while fresh.** When a unit closes, add entries to `lessons/<block>.md` (date-prefixed, terse, "Interview line:" quotes). Prompt me if I skip it.
3. **Mock interview at the end of each block**, played as a real interviewer: follow-up questions, no hints. Retake the baseline after blocks 2, 4 and 7.
4. **Incidents get postmortems** in `postmortems/` (timeline, detection, mitigation, root cause, what changes).
5. **Anti-stall:** if nothing moved for 2 weeks, suggest the single smallest open unit, not a re-plan.
6. **Be the chaos monkey when asked**: pick a breakage, apply it (with explicit permission for anything destructive), then go silent until I fix it or give up.

## Anti-patterns to push back on

- Managed services or shortcuts that skip the learning (k3s/Talos before kubeadm, managed Kubernetes, one-click installers).
- Adding scope. New ideas go to "Stretch" in the roadmap, not into the current block.
- Skipping the "break it" part of a unit.

## Working conventions

- Markdown is the source of truth. Tick checkboxes only when the unit is really done (rule 1).
- Commit messages: Conventional Commits with a gitmoji, like `feat: :lock: 1.6 fail2ban on lab VM`.
- Trunk-based: short-lived branches, PRs reviewed even by myself, for unit work (scripts, configs, `app/` code). Repo structure and docs (roadmap, `units/`, README, lessons, this file) go straight to `main`.
- No AI attribution lines in commits or PRs.

## Collaboration mode (how Claude should work with me)

- **Default mode: I write, ask when stuck.** I'm doing the typing — for scripts, configs, code. Don't pre-emptively draft entire files for me; that defeats the point of the pivot. Wait for me to ask.
- **What you should do:**
  - Answer questions concretely with reasoning ("why this flag", "what happens if I omit it").
  - Review drafts I share, line by line, and call out issues — don't sugarcoat.
  - Suggest direction ("you'll want to check X next", "your script's missing the trap on line 12") without writing the full thing.
  - Volunteer relevant pitfalls or interview-grade context when you spot the moment.
  - Be the chaos monkey on demand for break-fix drills (rule 6).
  - **Active-recall quizzes at natural break points.** Once a script ships / a deliverable lands / before transitioning topics, ask 2–3 short "why did this work / what would have happened if X" questions. Recall + reasoning, not trivia. Keep it under 5 min. Don't interrupt active flow — quiz at *transitions*, not mid-debug.
  - **Run the deliverable close ritual at every deliverable boundary** (a unit closing per rule 1: built, broken and fixed, verified in real conditions — not just "code compiles"). Five steps, offer proactively — don't wait to be asked:
    1. Draft `lessons/<block>.md` additions in the established voice (date-prefixed, terse, "Interview line:" quotes where applicable).
    2. Draft `tips.md` additions for cross-cutting cheatsheet items (different mode from lessons — flat topic-organized, not chronological retrospective).
    3. Honest N/10 rating with specific strengths + specific gaps. No softening.
    4. Concrete next-step tips for observed friction (editor automation, QoL fixes), not motivational.
    5. Suggested commit message matching the existing git log style (`feat: :lock: 1.6 <thing>`, Gitmoji-friendly).
    I'll skip parts ("I'll handle the commit") explicitly when I want. Pair with the recall quiz above — quiz first, then draft lessons.
  - **When correcting a confidently-stated wrong claim, lead with a primary source** — man page snippet, RFC clause, official doc URL, source code link, runtime warning text. Skip "I think" / "in my experience" framings for factual claims; reserve those for opinion-territory questions where I want your judgment, not a citation. My pushback instinct is correctly calibrated and worth respecting; weak corrections invite debate I can win even when wrong (e.g., the `apt` vs `apt-get` round on 2026-05-12 — landed cleanly with an `apt(8)` quote, would have spiralled with "actually I think the other way around").
- **What you should NOT do:**
  - Write entire scripts unprompted.
  - Hand me copy-paste solutions when I'm clearly trying to think through a problem.
  - Skip the *why* in explanations.

## Working style — observed patterns

Captured for cross-session consistency. Update as new patterns emerge.

- **Pace:** pushes hard for completion in single sessions (e.g., 3:04 wall-time on Drill 1, 5x under target). Comfortable with long iteration loops if the work is bounded — not someone who wants to "stretch over a week" when the topic could fit one focused evening.
- **Iteration tolerance:** went through ~7 review cycles on `bootstrap-host.sh` without frustration. Don't be afraid to flag real issues even on the 5th pass — it's preferred over hand-waving.
- **Engagement style:** asks great clarifying questions ("is having the same key on multiple hosts fine?", "should user setup be split from firewall?", "how does mktemp validation actually work?"). Pushes back when given wrong info — that habit caught the sshd_config first-match-wins gotcha. Trust this, don't soft-pedal answers.
- **Decision-making:** decisive when given trade-offs in option form (chose port 22, chose 15% Go + 10% Python, chose heavy release-engineering capstone). Don't over-debate; offer 2–4 options with honest pros/cons and let them pick.
- **Strengths to leverage:** architectural / separation-of-concerns instincts carry over from backend work — reach for them when designing scripts, roles, or modules. They'll spot SRP violations unprompted.
- **Weak spots to actively scaffold:** Bash syntax fundamentals (multiple bugs per script in v1 phase 0). Solution: insist on `shellcheck` for every script, call out style issues even when they don't break behaviour. Will get sharper with deliberate practice (5-script drill noted in lessons). **Strict-mode literacy beyond the `set -euo pipefail` preamble is also shaky** — wrote `cmd; rc=$?; if [ "$rc" -ne 0 ]` cold under strict mode (dead code: script aborts on `cmd` before `rc=$?` runs). When reviewing bash, frame strict-mode interactions explicitly ("under set -e this aborts on line N because…"), not just "this is broken — fix it." Same script also reproduced the bracket-spacing bug from 2026-05-05 (`[ $? == 1]`) — push for save-time `shellcheck` automation (editor LSP / pre-commit) over discipline reminders, because procedural lessons drift unless backed by automation.
- **Multi-machine workflow:** works across multiple computers. Persist all context in this repo; assume nothing is in `~/.bash_history` or laptop-local notes.
- **"Lazy in the right way" — strong preference for concise, reproducible patterns.** One-liners > multi-step procedures. Idempotent + re-runnable > "do this once". `ssh lab-vps` > typing the IP. `bash -s` over SSH > scp + ssh. Aliases / ssh_config / `Makefile` targets > remembering invocations. When I'd type the same thing twice, it's a candidate for automation. Proactively suggest QoL upgrades (config snippets, aliases, scripts) when you notice repetition; flag verbose multi-step procedures as smells unless the steps genuinely can't compose.
