# Phase 3 — Evals

**Passing bar:** Drills 1–3 pass + at least one break-fix passes + both whiteboards delivered. ~5 hours of eval time.

## Drill 1 — Idempotent role from blank (target: 30 min)

On a fresh shell, with empty `roles/foo/` directory, write a role that:

- Installs nginx.
- Templates a config file from a Jinja2 template using a `host_var`.
- Drops a systemd override.
- Notifies a handler that reloads nginx on config change.
- Runs cleanly twice (second run = zero `changed` tasks).

**Pass:** all five within 30 min, `ansible-lint` clean, second run shows 0 changed tasks.
**Partial:** 30–45 min, or one ansible-lint warning unfixed.
**Fail:** otherwise.

## Drill 2 — Bash → Ansible (target: 20 min)

Pick a 30-line Bash script you have not converted before. Rewrite as an Ansible playbook that produces the same end state.

**Pass:** playbook runs cleanly, second run is a no-op, all variables surfaced (no hard-coded paths).

## Drill 3 — Vault and CI (target: 15 min)

Encrypt a secret with `ansible-vault`. Reference it from a role. Run a playbook against a host using a vault password supplied via `--vault-password-file`. Demonstrate the same playbook running in a CI-like context (export the password via env var, no interactive prompt).

**Pass:** secret never logged in plaintext, playbook runs in both modes.

## Break-fix 1 — Non-idempotent role (target: 20 min)

Claude introduces a `command:` task with no `creates:`, `removes:`, or `changed_when:` guard. Running twice causes drift or duplicate work.

**Pass:** identify the offending task from `--diff` output, refactor to use a proper module or a `changed_when:` guard, retest.

## Break-fix 2 — Variable precedence trap (target: 20 min)

Claude sets the same variable in three places (defaults, group_vars, extra-vars) such that the wrong value wins for a target host.

**Pass:** trace the actual resolved value with `ansible -m debug -a 'var=foo'`, identify the precedence rule that bit you, fix.

## Whiteboard 1 — Execution model (target: 5 min, no notes)

Explain how Ansible runs a play: control node parses YAML, gathers facts, generates module code, pushes over SSH, executes remotely, returns JSON. Where does idempotency live? What's a handler vs a task? When does fact gathering happen, and how can you skip it?

## Whiteboard 2 — Roles vs collections vs playbooks (target: 5 min)

What lives where, why, and how do you import each? Where does Galaxy fit? When would you pin a collection version vs use a role directly from a Git ref?

## External attestation

None this phase, but the side-by-side `bootstrap.sh` ↔ `base-host` role diff is portfolio gold for phase 7.

## Retention check (schedule for 2026-09-22)

Redo Drill 2 cold against a different Bash script. Ansible's idempotency model atrophies fast if you stop using it daily.
