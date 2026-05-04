# Release flow + versioning — lab reference

Compact reference for the release pipeline used in phase 4 (K8s + GitOps) and built upon in phase 6 (Platform-flavor capstone). Read before tackling phase 4 § Release flow.

## Image tagging strategy

Three layers of tags, each with a different purpose:

- **Immutable SHA tag** — `:sha-abc1234` (short commit SHA). Every build pushes this. Never overwritten. The tag any Argo CD `Application` should *actually pin to* in production-grade setups.
- **Branch tag** — `:main` (or `:dev`, `:feature-foo`). Floating, mutable. Useful for dev environments that auto-track latest. Don't pin prod here.
- **Semver tag** — `:v1.2.0`, `:v1.2.0-rc.1`. Pushed when a git tag is cut. Immutable by convention.

**Avoid `:latest`.** It's ambiguous, breaks rollback, confuses caching. Don't even publish it.

## Semver + versioning

`MAJOR.MINOR.PATCH`. The spec is short — read it once: https://semver.org

Three signals you encode in a version bump:
- **PATCH** — bug fixes, no behaviour change. Safe by default.
- **MINOR** — new functionality, backward-compatible. Safe for consumers that don't depend on absent behaviour.
- **MAJOR** — breaking change. Consumers must adapt code.

For services (vs libraries):
- Services are usually deployed as a single artifact with a single version. Semver still applies but the "consumer" is your environment topology — staging then prod.
- For HTTP APIs, semver doesn't replace API versioning. A `v2.0.0` service may still expose `/api/v1/` and `/api/v2/` simultaneously.

For Helm charts:
- Two version fields per chart: `version` (the chart itself) and `appVersion` (the app it deploys). They don't have to move together.
- Bump `version` on any chart change (new template, default change, dependency bump). Bump `appVersion` only when the app image changes.

**Conventional Commits → automatic semver:**
- `fix:` → patch bump.
- `feat:` → minor bump.
- `feat!:` (or `BREAKING CHANGE:` footer) → major bump.

Tools that read commits and bump for you: `release-please`, `semantic-release`. Phase 6 (Platform flavor) explores writing your own in Go as a stretch.

**API versioning, briefly:**
- URL-based (`/v1/users`, `/v2/users`) — most explicit, easiest to operate, fattest URLs. Default for services.
- Header-based (`Accept: application/vnd.api+json; version=2`) — cleaner URLs, harder to debug from a curl. Use when you have many clients with sticky cache concerns.
- Content negotiation — niche, mostly hypermedia APIs.

**Pre-release labels:**
- `1.2.0-rc.1`, `1.2.0-beta.3`, `1.2.0-alpha.1`. They sort lower than the final `1.2.0`.
- Use **RC** for "we think this is final, validate in staging." Use beta/alpha for opt-in exposure to early users.
- **Don't reuse pre-release numbers.** `rc.1` failed → next is `rc.2`, never re-cut `rc.1` from a different SHA. Reusing breaks immutability.

**Schema/data versioning** (separate concern, often missed):
- Database migrations should be idempotent (running twice = no-op) and ideally reversible (down migration).
- Tools: `dbmate`, `goose`, `flyway`, `golang-migrate`. Run at deploy time or as a one-shot K8s `Job`.
- Backward-compat dance for online schema changes (zero-downtime): **expand → migrate → contract.** Add new column → backfill + dual-write → cut over → remove old column. Never just `ALTER TABLE` in a live deploy.

## Release candidate pattern

Why RCs:
- You want to test a build in staging before promoting to prod.
- You want to surface release-blocking bugs before the version-bump press release.
- You want a stable artifact reference that doesn't change between staging and prod (the same image is promoted, not rebuilt).

Flow:
1. Cut tag `v1.2.0-rc.1` from `main`.
2. CI builds image, pushes `:v1.2.0-rc.1` (and `:sha-...` for immutability).
3. Staging Argo CD Application's `targetRevision: v1.2.0-rc.1` → staging deploys.
4. If RC fails: cut `v1.2.0-rc.2`, repeat. Don't reuse RC numbers.
5. If RC passes: cut tag `v1.2.0` (same SHA as the passing RC).
6. CI re-tags the existing image (don't rebuild — bit-for-bit identical) as `:v1.2.0`.
7. Prod Argo CD Application's `targetRevision: v1.2.0` → prod deploys.

**Re-tagging instead of rebuilding** matters: the bytes that ran in staging are the bytes that run in prod. A rebuild can introduce variance (different base image SHA, different build context, transient dependency churn). For lab work this matters less; for prod work it's a hard rule.

## GitOps promotion

Don't mutate environment tags (`:prod`, `:staging`). Promotion = a Pull Request that updates the Argo CD `Application`'s `targetRevision`:

```diff
- targetRevision: v1.1.0
+ targetRevision: v1.2.0
```

Benefits:
- Promotion is **auditable** (PR + reviewer + merge timestamp).
- Rollback is `git revert` of that PR.
- No human ever runs `kubectl apply` against prod.

## Environment separation

In a small lab, two clean options:

- **Namespaces in one cluster** — `apps-dev`, `apps-staging`, `apps-prod`. Cheap, one cluster to operate. RBAC + NetworkPolicies enforce isolation. Fine for lab.
- **Separate clusters per env** — production-grade, expensive. Skip for lab.

Argo CD `ApplicationSet` can template a single config across the three namespaces, each pointing at a different `targetRevision` — one config drives all three envs.

## Tools

- **Build + push:** GitHub Actions (`docker/build-push-action`) or GitLab CI (`docker:dind` or `kaniko`).
- **Tag automation:** `release-please` or `semantic-release`. Automatic semver bump from conventional commits + auto-changelog. Phase 6 explores writing your own in Go as a stretch.
- **Image signing:** `cosign` — phase 6 capstone (Platform flavor).
- **Promotion:** Argo CD `Application`'s `targetRevision`, updated via PR.
- **Schema migrations:** `dbmate` / `goose` / `golang-migrate` (Go-flavored), `flyway` / `liquibase` (Java-flavored), Alembic (Python).

## Anti-patterns (push back when you see them)

- **Rebuilding for each environment.** Variance risk — the bytes change between staging and prod. Rebuild once, re-tag many.
- **Mutating `:latest` or `:prod`.** No rollback path, no audit trail. Don't do it.
- **Manual `kubectl set image` to deploy.** Skips Argo, drift will follow. Banned in phase 4.
- **Pinning prod to a branch tag (`:main`).** First risky merge breaks prod. Pin to immutable tags only.
- **Cutting a final tag from a different commit than the RC.** You've thrown away the RC validation. The final must be the *same SHA* as the passing RC.
- **Skipping `expand → migrate → contract` for online schema changes.** `ALTER TABLE ADD COLUMN NOT NULL` on a live table = downtime. Always expand first, migrate data, contract last.
- **Conflating chart `version` and `appVersion`.** They serve different purposes; bumping them together hides chart-only changes.
