# Phase 5 — Observability + SRE practices

**Duration:** 5 weeks  
**Target end:** 2026-10-13  
**Hours budget:** ~60

## Goal

Self-install the observability stack, instrument an app properly, define SLOs that mean something, and run a real game day. Read the SRE book in parallel — by phase 6 you should be able to talk SLOs / error budgets / postmortems fluently.

## Why this phase

SRE without observability is just sysadmin. The hands-on stack experience plus the SRE book vocabulary is what flips an interview from "knows ops" to "thinks like an SRE".

## Deliverable

A real dashboard, a real SLO, and a real postmortem — all linked from `tasks/lessons.md` § Phase 5.

Concretely:
- **LGTM** stack on cluster: Prometheus, Loki, Tempo, Grafana, with Promtail/Alloy and OTel collector.
- One TS/Node app instrumented with **OpenTelemetry** producing traces + metrics + structured logs.
- One **SLO** defined for that app with multi-window burn-rate alerting.
- One **postmortem** for an incident you induced yourself, with action items closed in this repo.

**Definition of done:** a Grafana dashboard URL that shows golden signals + SLO burn rate, an Alertmanager route that pages you (Slack/email/Telegram) when burn rate exceeds threshold, and a written postmortem in `tasks/postmortems/`.

## Checklist

### Stack on cluster
- [ ] Prometheus + Alertmanager via kube-prometheus-stack Helm chart. Persistent storage on Longhorn (from phase 2).
- [ ] Grafana: connect Prometheus, Loki, Tempo as data sources. Pin the version, not "latest".
- [ ] Loki + Promtail (or Grafana Alloy) for logs.
- [ ] Tempo for traces. Sample at 100% in lab; learn the levers.
- [ ] OpenTelemetry Collector as a DaemonSet receiving from apps, fanning out to Prometheus / Loki / Tempo.
- [ ] Move heavy components (Prometheus, Loki) to the VPS node via nodeSelector — Pi memory is the constraint.

### Instrument an app
- [ ] Pick one of your phase-1 services, **or — recommended for the Go drip — write a small fresh service in Go** and instrument that. Go's OTel ecosystem is more idiomatic and you'll learn more.
- [ ] If TS: add `@opentelemetry/sdk-node` + auto-instrumentations (HTTP, Prisma if applicable). If Go: `go.opentelemetry.io/otel` + the relevant instrumentation libs.
- [ ] Add structured JSON logs with trace_id correlation. Verify in Loki you can jump from a log line to the trace.
- [ ] Add custom RED metrics (Rate, Errors, Duration) at the handler level.

### SLOs that mean something
- [ ] Pick an SLI: e.g., "fraction of HTTP requests with status < 500 and duration < 200ms".
- [ ] Pick an SLO target: e.g., 99.5% over 28 days. Calculate the error budget in minutes.
- [ ] Implement Google's **multi-window multi-burn-rate** alert (read the SRE workbook chapter on this — don't wing the formula).
- [ ] Build a Grafana dashboard showing SLI, SLO target, error budget remaining, burn rate per window.
- [ ] Wire Alertmanager to a real channel (Slack webhook, Telegram bot, email). Test it fires.

### SRE book reading
- [ ] *Site Reliability Engineering* — chapters 1–6 (intro, embracing risk, SLOs, eliminating toil, monitoring, automation). Skim the rest.
- [ ] *Site Reliability Workbook* — chapter on SLO engineering, chapter on alerting on SLOs. Take notes in `tasks/lessons.md`.

### Game day
- [ ] Plan a failure: e.g., kill the DB pod for a service that has a PVC. Decide what should happen.
- [ ] Execute. Don't watch the dashboard during — watch only after the alert fires.
- [ ] Time-to-detect (alert fired), time-to-mitigate (service back), time-to-resolve (root cause documented).
- [ ] Write the postmortem in `tasks/postmortems/<date>-<title>.md` using a real template (Google's is fine — search "Google postmortem template").
- [ ] File at least 2 action items as issues or `tasks/todo.md` items and *actually close them*.

## Resources

- Google SRE book + workbook (free online) — sre.google/books.
- Brendan Gregg's *Systems Performance* — reference for perf debugging.
- Prometheus docs — relabeling chapter is the one that really matters.
- OpenTelemetry JS docs — opentelemetry.io.

## Stretch

- Add Pyroscope for continuous profiling of your TS app. Find a real CPU hotspot.
- Set up [SLO Generator](https://github.com/google/slo-generator) or `sloth` so SLOs are defined as YAML and rendered into Prometheus rules.
- Synthetic monitoring with Blackbox Exporter — alert on cold-path endpoints.

## Lessons

Append § Phase 5 to `tasks/lessons.md`. The postmortem itself is the headline artifact for interviews — make it good.
