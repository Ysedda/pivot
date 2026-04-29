# Phase 3 — Configuration management with Ansible

**Duration:** 4 weeks
**Target end:** 2026-08-11
**Hours budget:** ~50

## Goal

Manage the entire lab declaratively via Ansible: hosts, services, users, certs, k3s nodes. By the end you should be writing idempotent roles fluently, debugging convergence with `--check` and `--diff`, and testing roles with Molecule.

## Why this phase

Ansible appears in the majority of French DevOps job ads — far more than the US cloud-native bubble suggests. It also encodes a different mental model from Terraform (convergent imperative vs declarative state) which is itself worth carrying. This phase is the most directly portable to the French market: even shops that don't use Kubernetes use Ansible.

> **Note on the lab:** the temporary VPS expired around 2026-07-14 (start of this phase). Manually rent a small Hetzner CX22 (~€5/mo) — exactly the kind of click-ops you'll feel the pain of, then automate away in phase 4. Don't Terraform yet; that's the next phase's job.

## Deliverable

An `ansible/` directory in this repo containing:

- An inventory describing your lab (Pi + new VPS).
- Roles that fully bring up: a `base-host` (replacing phase-0 Bash), Wireguard, k3s nodes, Traefik + cert-manager, your phase-1 services.
- `ansible-vault` for any secret material (deploy keys, API tokens, peer keys).
- `molecule/` configs to test at least one role in isolation.
- A README with the commands to bring up the lab from blank.

**Definition of done:** wipe both hosts back to a fresh OS image. Run `ansible-playbook -i inventory site.yml`. Within 30 minutes the lab is fully operational — same end state as the close of phase 1, produced declaratively rather than imperatively.

## Checklist

### Foundations
- [ ] Read & summarize Ansible's execution model (control node → SSH → modules pushed and run on remote, fact gathering, idempotency contract). Notes in `tasks/lessons.md`.
- [ ] Ad-hoc commands fluent: `ansible all -m ping`, `-a "uptime"`, `-m apt -a "name=htop state=present" -b`. Use them daily during the phase.
- [ ] Inventory: static `hosts.yml` + group_vars / host_vars precedence. Test that overrides resolve as you expect.

### Playbooks & roles
- [ ] First playbook: install + configure one tool on both hosts. Tag tasks. Run with `--tags`, `--check`, `--diff`. Internalize what each shows.
- [ ] Refactor that playbook into a `role` under `roles/<name>/`. Defaults, tasks, templates, handlers, meta.
- [ ] Galaxy / collections: pull in `community.general`, `ansible.posix`. Pin versions in `requirements.yml`.

### Real conversions
- [ ] Convert `lab-bootstrap/bootstrap-host.sh` (phase 0) to a `base-host` role. Side-by-side with the Bash version; **do not delete the Bash one**. The diff is the learning artifact.
- [ ] Convert your phase-1 reverse-proxy + service deployment to roles.
- [ ] `wireguard` role with a Jinja2-templated `wg0.conf`, peer keys held in `ansible-vault`.
- [ ] `k3s` install role. Idempotent — re-running on an existing k3s host is a no-op.

### Variables, templates, vault
- [ ] Templates with Jinja2: `wg0.conf`, Traefik dynamic config, service env files. Loops, conditionals, filters (`default()`, `mandatory`, `regex_replace`).
- [ ] `ansible-vault create secrets.yml`, `ansible-vault edit`, encrypted vars in CI via `--vault-password-file`. Document the rotation story in the role README.
- [ ] Variable precedence: write a 5-line cheat-sheet in `tasks/lessons.md`. Don't memorize the 22-level list — understand the broad order.

### Quality & testing
- [ ] `ansible-lint` clean on every role. CI step in your existing pipeline.
- [ ] `yamllint` clean across `ansible/`.
- [ ] **Molecule** scenario for the `base-host` role: spin up a Docker container, converge, verify idempotency (second run must show 0 changed), destroy. CI-friendly.
- [ ] Run with `--check --diff` and explain in `tasks/lessons.md` what each shows you that the actual apply doesn't.

### Dynamic inventory (preview of phase 4)
- [ ] Write a small dynamic inventory script in **Python** (use the Python drip — this is the canonical Ansible+Python interface) that returns hosts based on a static JSON file. Run a real playbook against it. Phase 4 will plug Terraform outputs into this slot.

### Drill
- [ ] **Incident drill:** introduce a non-idempotent task (e.g., `command:` with no `creates:`/`removes:`/`changed_when:` guard). Run twice. Observe drift / unexpected state. Refactor to a real module. Postmortem in `tasks/postmortems/`.

## Resources

- Ansible official docs — User Guide. Focus: Playbook Keywords, Variable Precedence, Roles directory structure.
- *Ansible for DevOps* (Geerling) — chapters 4–7. The canonical book.
- Jeff Geerling's YouTube series — concrete and current.
- Molecule docs — molecule.readthedocs.io.
- `ansible-lint` rules — read at least the "production" profile.

## Stretch

- AWX (Ansible Tower OSS) on the cluster. Schedule a playbook from a UI. Useful exposure for SSII / consulting roles.
- Convert your nftables config (phase 1) to a templated role that generates rules from a list-of-services variable.
- Read one real-world role from a major company on Galaxy (e.g., `geerlingguy.docker`). Note the patterns that surprised you in `tasks/lessons.md`.
- **Go drip stretch:** write a small custom Ansible module *in Go* (yes, it's possible — modules just need to read JSON args from stdin and emit JSON). Bonus: compare to writing the same module in Python. Heavy Go-day exercise.

## Lessons

End of phase: append § Phase 3 to `tasks/lessons.md`. Especially: the Bash-vs-Ansible diff for the bootstrap role, and where `--check` / `--diff` lied to you (it does, sometimes — that's worth writing down).
