# Phases

Each phase has its own folder with three files:

```
0X-<phase-name>/
├── plan.md      # goal, deliverable, checklist, resources, stretch
├── evals.md     # exit checkpoints — drills, whiteboards, break-fixes
└── lessons.md   # retrospective entries, append continuously
```

For the program at a glance (dates, summaries, cross-cutting habits) see [`../PROGRAM.md`](../PROGRAM.md).

---

## Lessons format

Append entries continuously, not at end of phase. By end-of-phase the details fade.

Format per entry:

> **Date — Phase X — short title**
> Body — prose-tight or short bullets. What I expected → what actually happened → what I'd do differently next time.

Suggested sub-entry types (use whichever fit, none mandatory):

- **Decisions** — judgment calls + rationale. Interview-grade material.
- **Tech worth keeping** — interview-grade technical takeaways.
- **Continue** — what worked, keep doing.
- **Alerts** — weak spots to drill.

Curated reading lists / resources per skill area: see [`../tasks/tips.md`](../tasks/tips.md) § Resources.

---

## Evals — phase-completion attestation

Checking boxes proves I did the work. Passing evals proves I learnt something. The single biggest failure mode of self-paced learning is fooling yourself: read about Cilium's eBPF dataplane, nod, tick the box, three weeks later can't explain it on a whiteboard. Evals close that loop.

### Eval flavors

- **Drill** — hands-on. Do X, get Y, in time T.
- **Whiteboard** — explain cold, no notes. Ideally to another human; otherwise write it as a doc under `tasks/whiteboards/0X/<topic>.md`.
- **Break-fix** — something is broken, fix it. Diagnose then resolve under a time limit.
- **External attestation** — exam, mock interview, public artifact. The strongest signal.

### The rules

- **Fresh-restart rule.** Drills pass only when done on a clean lab without your own phase notes. Allowed: man pages, official upstream docs (kubernetes.io, prometheus.io, etc.). Forbidden: your own `lessons.md`, your own old configs, the phase plan itself.
- **Time pressure is part of the eval.** Limits exist because production has them. If a drill takes 2x the budgeted time, that's a partial pass — log it and re-run within a week.
- **Three-tier scoring: pass / partial / fail.** Be ruthless — interview panels will be. Don't grade yourself "pass" if you copy-pasted, looked at your own notes, or skipped a sub-criterion.
- **Retention check.** Each phase nominates one drill to repeat ~6 weeks after the phase ends. Schedule a calendar reminder. If you can't redo the simplest drill cold after 6 weeks, the phase didn't stick — revisit before claiming it on a CV.

### Phase-passing bar

Each `evals.md` opens with a **Passing bar** section: the explicit criterion for "phase done". Tick the phase's final deliverable in `tasks/todo.md` only after passing the bar.

### Claude as the chaos monkey

For break-fix drills, instruct Claude to administer the eval. Example prompt:

> "Administer break-fix drill #N from `phases/0X-<phase>/evals.md`. Pick one of the listed variants, apply it to the lab, then go silent. Don't reveal what you changed until I either fix it or formally give up. Time limit: T minutes."

For drills that demand external grading (mock interview, README skim test), recruit a human.

---

## Cross-cutting checkpoints (any time)

Run any time you doubt readiness — not tied to a phase exit. Litmus tests for skills the program assumes you've absorbed by the end.

- **Bash strict-mode literacy.** Write a 30-line idempotent Bash script from scratch in 10 min: `set -euo pipefail`, traps, usage function. No reference.
- **`tcpdump` from blank.** On a live host, capture HTTPS traffic to a specific destination, decode TCP flags, identify a retransmit. No flag-doc lookup.
- **`kubectl` muscle memory.** In a fresh cluster, no reference: get pods + grep status, exec into a container, port-forward, scale a deployment, drain a node, view recent events sorted by time.
- **Read a Go function and explain it.** Any function from a real K8s controller. Then a Kubebuilder controller. By phase 6 (capstone in Go) you should not flinch.

---

## When a checkpoint fails

- Don't fudge it. Add to `tasks/todo.md` § Slip log: `2026-MM-DD — checkpoint <X> failed in 0X-<phase>/evals.md, blocked by <gap>`.
- Schedule a focused 2–4 hour study session on the specific gap.
- Retry. If it fails again, the phase plan probably under-covered the topic — note in `0X-<phase>/lessons.md` so future-me knows.
- A checkpoint failed twice and resolved is interview-grade evidence in itself: that pattern of "spotted a gap, drilled it, retried" is exactly what staff engineers want to hear.

---

## Where artefacts live

- Drill notes & timings → `0X-<phase>/lessons.md` (drill, date, pass/partial/fail, notes).
- Whiteboard write-ups → `../tasks/whiteboards/0X/<topic>.md`.
- Postmortems from break-fix drills → `../tasks/postmortems/<date>-<title>.md`.
- Reusable copy-paste patterns → `../tasks/tips.md`.
- Resources / reading lists → `../tasks/tips.md` § Resources.
