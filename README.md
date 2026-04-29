# DevOps / SRE Pivot

A self-paced 31-week program toward an SRE / Platform Engineer role, built around a home lab (Raspberry Pi 4/5 + lab VPS). Named "pivot" because that's the actual goal — career pivot from backend to SRE / Platform.

## What this is

I'm a backend engineer (TS/Node, ~4 YoE) pivoting toward SRE / Platform. This repo is the program I'm working through. It's structured as themed phases, each with a single concrete deliverable. No phase moves to the next without shipping it.

## Layout

- [`PROGRAM.md`](PROGRAM.md) — full program: gap analysis, phases at a glance, cross-cutting habits, dates.
- [`phases/`](phases/) — one doc per phase with deliverable, checklist, resources, stretch goals.
- [`evals/`](evals/) — phase-completion attestation: drills, whiteboards, break-fixes, external proofs. **Phase done = evals passed, not just checkboxes ticked.**
- [`tasks/todo.md`](tasks/todo.md) — master checklist across phases.
- [`tasks/lessons.md`](tasks/lessons.md) — running log of what surprised me, what bit me. The single most interview-relevant artifact in this repo.

## Discipline rules

1. **Don't advance phases until the eval passing bar is met** — see `evals/0X-*.md`. Deliverable shipped + drills passed + whiteboard delivered + external attestation (where applicable).
2. After every phase: append a `tasks/lessons.md` § Phase 0X entry.
3. One incident drill per phase: break something on purpose, time TTD/TTM, write a postmortem in `tasks/postmortems/`.
4. ~15% Go + ~10% Python per phase. Go is the heavier emphasis — capstone (phase 6) ships in Go regardless of flavor. Python is leverage for Ansible (phase 3) and general automation.
5. Schedule retention checks at the end of each phase (calendar reminders 6 weeks out — the phase's eval doc names the drill to repeat).

## Current phase

→ [Phase 0 — Lab bootstrap](phases/00-bootstrap.md)
