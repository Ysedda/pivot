# Phase 6 — Specialize + interview prep

**Duration:** 5 weeks  
**Target end:** 2026-11-17  
**Hours budget:** ~60

## Goal

Pick the SRE flavor that actually fits and ship a capstone project in it, while running interview prep in parallel.

## Why this phase

"SRE" covers wildly different jobs. Picking a flavor lets your portfolio + cover letters speak to one role with depth, instead of three with shallowness.

## Picking the flavor

By now you've felt the difference between phases 4 (K8s/infra + GitOps), 5 (reliability/observability), and 3 (Terraform/IaC). Pick based on what you actually enjoyed:

- **Infra / Cloud SRE** — networks, clusters, capacity, cost, on-call for infra.
- **Reliability SRE** — SLOs, error budgets, incident response, perf debugging at the app boundary.
- **Platform / DevEx** — internal platforms, golden paths, CI/CD, self-service infra for app teams.

Write the choice and *why* into `lessons.md` § Phase 6. Be specific.

## Capstone project (pick one based on flavor)

> **All flavors ship the capstone in Go.** By this phase you should be choosing Go where you'd previously have reached for TS — the K8s ecosystem and SRE tooling expect it. Stretching into Go for the capstone is non-negotiable; the Python you've been doing in earlier phases is for Ansible, not capstones.

### Infra flavor
- [ ] Write a small Kubernetes operator in **Go** with Kubebuilder. Suggested CRD: `LabService` that wraps Deployment + Service + Ingress + cert-manager Certificate into one resource.
- [ ] Add admission validation webhooks. Add status reporting. Add finalizers.
- [ ] Document with proper README + architecture diagram.

### Reliability flavor
- [ ] Build a proper **SLO platform**: SLOs defined as YAML in Git, generated into Prometheus rules via `sloth` or similar, dashboards templated.
- [ ] Write the **automated rollback agent in Go**: watches Alertmanager webhooks, decides whether to roll back, calls the Argo CD API. Real Go service, deployed to the cluster.
- [ ] Run a longer game day: 3 chained failures, 3 postmortems, action items tracked to closure.

### Platform flavor — release engineering capstone

The densest of the three capstones. You're building the platform that ships software *safely*, end-to-end. If you pick this flavor, expect to allocate more of your phase-6 hours to capstone vs. interview-prep drills than the Infra/Reliability flavors require — that's the trade-off for the depth.

Five concrete pieces, all wired together:

**1. Feature flag service (in Go)**
- [ ] Small Go service exposing HTTP (and optionally gRPC) for flag evaluation. Backed by Postgres on the cluster.
- [ ] Supports: kill switches, percentage rollouts, deterministic user-bucketing (hash-based), per-env defaults.
- [ ] Client SDK in Go consumed by at least one lab service.
- [ ] Audit log: who changed which flag, when, with what reason.

**2. Deploy strategies (Argo Rollouts)**
- [ ] Install Argo Rollouts on the cluster.
- [ ] **Blue-green** strategy live for one service.
- [ ] **Canary with analysis** for another — `AnalysisTemplate` queries phase-5 SLO metrics, aborts the rollout if burn rate exceeds threshold.
- [ ] Document tradeoffs (canary vs blue-green vs rolling vs recreate) in `PLATFORM.md`.

**3. SLO-driven auto-rollback**
- [ ] Tie phase 5's burn-rate alerts to Argo Rollouts: a fast-burn alert on a service mid-rollout aborts the rollout automatically.
- [ ] Test it deliberately: deploy a "bad" version with elevated error rate, watch the rollout abort within 5 min.

**4. Release automation**
- [ ] PR merged to main → auto semver bump → auto changelog → release tag pushed → Slack/Telegram notification → Argo Rollouts canary kicked off.
- [ ] Use `release-please` *or* write your own in Go (bonus drip).
- [ ] Released artifacts (container images, Helm charts) signed (cosign) and verifiable in CI.

**5. Enforced branching policy**
- [ ] Trunk-based across all platform repos. Branch protection on main: required reviews, required green CI, dismiss-stale-approvals, no force-push, signed commits required.
- [ ] Document the policy + rationale in `PLATFORM.md`.
- [ ] **Demonstrate violations:** record what fails (and where in the audit log it shows up) for: direct push to main, squash-merge without review, force-push, unsigned commit.

#### Definition of done — full E2E

In a fresh shell, posing as a new engineer:
1. From a feature branch, open a PR with a trivial code change to a lab service.
2. PR is blocked until CI passes and a review is approved (your own — fine for the eval).
3. After merge: version auto-bumps, changelog generates, release tag pushed, Slack/Telegram message lands.
4. Argo Rollouts kicks off a canary deploy.
5. Analysis template queries SLO metrics for 3+ min.
6. Auto-promote on success — or auto-rollback if you've intentionally tampered with metrics.
7. Final state observable in Grafana + Argo Rollouts UI.

Total time merge → fully-promoted production: **<15 min**. Zero manual `kubectl` or cluster-admin access.

## Interview prep (run in parallel, every week)

### Weekly system design
- [ ] One per week, 60–90 min each. Pick from: design a metrics pipeline, design a multi-region failover, design a CI/CD platform for 200 engineers, design an on-call rotation tool, design a feature-flag service.
- [ ] Write the design as a markdown file under `tasks/system-design/`. Diagram + tradeoffs + capacity math.

### Weekly troubleshooting drill
- [ ] One per week. Sources: killercoda.com, "broken cluster" repos, or break your own lab and recover.
- [ ] Time it. 45 min limit. Document approach in `tasks/troubleshooting/`.

### Behavioral
- [ ] Write 5 STAR-format stories from real work — at least one each on: failure, conflict, ambiguity, leadership, learning.
- [ ] Re-read every Friday until they sound natural.

### Logistics
- [ ] CV refresh, focused on the SRE pivot. Lead with this repo + capstone.
- [ ] LinkedIn updated.
- [ ] List of 10–15 target companies, with notes on what their SRE/Platform org looks like.

## Resources

- *Designing Data-Intensive Applications* (Kleppmann) — system design canon.
- *The Manager's Path* (Fournier) — even as IC, the framing on roles helps interviews.
- Kubebuilder book — https://book.kubebuilder.io/
- "Awesome SRE" GitHub list for reading material per topic.

## Stretch

- Speak at a meetup or write a deep blog post (counts as polish, but starting now is wise).
- Get one person in your target role to do a mock interview with you.

## Lessons

End of phase: ensure `lessons.md` has the capstone retrospective.
