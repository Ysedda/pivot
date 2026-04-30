# Phase 6 — Evals

**Passing bar:** Capstone E2E passes + 5 system-design exercises completed and peer-reviewed + 5 troubleshooting drills completed + behavioral stories rehearsed + 1 mock interview taken. ~10 hours of eval time.

## Capstone E2E — flavor-specific drill

### Infra flavor — operator E2E (target: 30 min)

For your custom controller:
1. From a clean namespace, `kubectl apply` a CRD instance.
2. Within 60s, observe expected child resources created.
3. Modify a field on the CR; observe reconciliation.
4. `kubectl delete` the CR; observe finalizers + clean teardown.

**Pass:** all four steps behave as designed, observable via `kubectl get events` and controller logs.

### Reliability flavor — auto-rollback (target: 20 min)

1. Deploy a "bad" version (intentionally elevated error rate).
2. Watch SLO burn-rate alert fire.
3. Watch your auto-rollback hook trigger an Argo rollback.
4. Service recovers within budget.

**Pass:** rollback fires within 5 min of bad deploy, no manual intervention.

### Platform flavor — release engineering E2E (target: 15 min)

The capstone's full pipeline, end-to-end:

1. From a feature branch, open a PR with a trivial code change to a lab service.
2. PR is blocked until CI passes and review is approved (your own — fine for the eval).
3. After merge: version auto-bumps, changelog generates, release tag pushed, Slack/Telegram notification lands.
4. Argo Rollouts kicks off a canary deploy.
5. Analysis template queries SLO metrics for 3+ min.
6. Auto-promote on success, or auto-rollback if you've intentionally elevated error rate.
7. Final state observable in Grafana + Argo Rollouts UI.

**Pass:** all seven steps complete in <15 min wall time, no manual `kubectl` or admin access. Branch protection blocks at least one disallowed action during the run (e.g., a direct-push attempt during the demo).

#### Bonus eval — Feature flag flip (target: 5 min)

1. From the feature flag service UI/CLI, flip a flag for a deployed service.
2. Observe the change in the service's behavior within seconds (no redeploy).
3. Audit log shows your action with timestamp + reason.

**Pass:** flag flip propagates without restart, audit log captures it.

#### Concept recall — deploy strategies (5 min, no notes)

Canary vs blue-green vs rolling vs recreate. Where each shines, where each breaks. When would you ever pick `recreate`? What's the cost of canary if you don't have an SLO defined? Why does blue-green need 2x the resources for the rollout window?

## Drill 1 — System design weekly (5 total during phase)

One per week, 45 min each, written up under `tasks/system-design/<topic>.md`. Suggested topics:
- Metrics pipeline for a 200-engineer org.
- Multi-region failover for a stateful service.
- Internal CI/CD platform from scratch.
- On-call rotation tool with PagerDuty integration.
- Feature-flag service with audit log.

For each: include a diagram, capacity math, failure modes, blast-radius analysis, what-you'd-build-first ordering.

**Pass per exercise:** a peer (or someone in role) reads it and either (a) gets the design without your explanation, or (b) finds at most one major gap.

## Drill 2 — Troubleshooting weekly (5 total during phase)

One per week, 45 min each. Sources: killercoda.com scenarios, "broken cluster" repos, or break your own lab. Document approach in `tasks/troubleshooting/<n>.md` — hypotheses tried, observations, time-to-resolve.

**Pass per exercise:** scenario resolved within the time limit, write-up reads as a clean diagnostic narrative.

## Drill 3 — Behavioral STAR stories (target: rehearsed by end of phase)

5 stories, written under `tasks/behavioral/`:
- Failure (with what was learnt + what changed).
- Conflict (and resolution path).
- Ambiguity (and how you reduced it).
- Leadership (formal or informal).
- Learning (something hard you picked up).

**Pass:** all 5 written + rehearsed aloud at least once. Time each to <2 min.

## External attestation

- **One mock interview** with someone in an SRE/Platform role. Get written feedback.

## Whiteboard

Pick 3 of your 5 system-design exercises. Be ready to deliver any of them cold to a whiteboard in ≤45 min. Practice once, on a real whiteboard if possible.

## Retention check

Not applicable — phase 7 immediately exercises the same skills.
