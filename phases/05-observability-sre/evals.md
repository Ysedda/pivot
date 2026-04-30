# Phase 5 — Evals

**Passing bar:** Drills 1–2 pass + Game Day passes (alert fires, mitigation in budget, postmortem written) + both whiteboards delivered. ~6 hours of eval time.

## Drill 1 — SLO from scratch (target: 90 min)

Pick a *new* HTTP endpoint you haven't instrumented yet. From scratch:

1. Define the SLI in plain English + as a Prometheus query.
2. Define the SLO target (with rationale — why 99.5%, not 99.9%?).
3. Calculate error budget in minutes/month.
4. Write multi-window multi-burn-rate alerts (2% budget in 1h fast, 10% in 6h slow — Google SRE workbook formula).
5. Build a Grafana dashboard showing SLI, target line, error budget remaining, burn rate per window.
6. Trigger an artificial spike, confirm fast-burn alert fires.

**Pass:** alert correctly fires in test, dashboard reads naturally, in <90 min.
**Partial:** alert fires but with wrong window, or dashboard requires live editing.
**Fail:** otherwise.

## Drill 2 — Trace-to-log correlation (target: 15 min)

Given a sample 500 error in the app:

1. Find the log line in Loki via the trace_id.
2. Click into the trace in Tempo from that log line.
3. Identify the failing span and its attributes.

**Pass:** all three jumps work natively in Grafana — no copy-pasting trace_ids by hand.

## Game Day — break-fix, formal (target: alert <5 min, mitigate <15 min, postmortem within 24h)

This is the headline eval of phase 5. Claude (or a colleague) injects, without warning, one of:

- DB pod kill on a service with PVC.
- Disk fills (write a 9 GB file).
- Network partition between Pi and VPS (drop wg traffic for 60s, restore).
- Infinite loop in app code via a deployed broken image.
- Certificate expired (rewind clock or use a pre-expired cert).
- Critical Prometheus rule deleted (silent failure mode — should you have detected this?).

You don't watch the dashboard. The alert is the trigger.

**Pass criteria:**
- TTD (alert → ack) < 5 min.
- TTM (mitigation, service back to SLI compliance) < 15 min.
- TTR (root-cause documented) within 24h.
- Postmortem in `tasks/postmortems/` using a real template (Google's).
- ≥2 action items filed and at least 1 closed before phase ends.

**Pass:** all five criteria met.
**Partial:** TTM 15–30 min, or postmortem light on contributing factors.
**Fail:** TTD >10 min (alert misconfigured) or no postmortem.

## Whiteboard 1 — Multi-window multi-burn-rate (target: 10 min)

Why two windows? Why both fast and slow burn rates? What happens with a single 1h-window alert during (a) a flapping outage, (b) a slow degradation? Walk through the math.

## Whiteboard 2 — Budget arithmetic on the fly (target: 5 min)

Given 99.9% SLO over 30 days:
- Allowed downtime/month?
- 5-minute outage burns what % of budget?
- Two 30-second outages per day for a week — fast or slow burn alert?

No calculator. Show the working.

## External attestation

The postmortem should be reviewable by someone in an SRE role. Send it to one — informal feedback over coffee counts.

## Retention check (schedule for 2026-11-24)

Re-run Drill 1 against a different endpoint. SLO mechanics atrophy faster than you'd think.
