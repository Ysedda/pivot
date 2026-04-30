# Tips & tricks

Small, copy-pasteable operational patterns. Living document — append as discovered. Different from `lessons/` (which is chronological retrospective per phase); this is a flat topic-organised cheatsheet for "how do I X again?" moments.

Search-friendly. When in doubt: add it here, future-me will thank current-me.

---

## SSH

### `~/.ssh/config` Host entries — biggest QoL upgrade in the program

Stop typing `ssh deploy@ip_address …`. Add to `~/.ssh/config` on every laptop you work from:

```
Host lab-vps
    HostName 1.22.221.21
    User deploy
    IdentityFile ~/.ssh/keyfile
```

Then it's just `ssh lab-vps`. When the IP changes (VPS reset / phase 4 TF rebuild), update one line, not every script.

Common extras worth knowing:

```
Host *
    ServerAliveInterval 60       # keep idle connections alive
    ServerAliveCountMax 3
    ControlMaster auto           # multiplex (faster reconnects)
    ControlPath ~/.ssh/cm-%r@%h:%p
    ControlPersist 10m
```

### `ssh -o PubkeyAuthentication=no <host>`

Skips key auth on a single connection. Useful for verifying password auth is actually disabled — should fail with `Permission denied (publickey)` and *no password prompt*.

### `ssh-copy-id user@host`

Pushes your local public key into the remote `~/.ssh/authorized_keys` over SSH. The "first connection" pattern when bootstrapping a fresh box that has password auth enabled.

---

## Bash / shell scripting

### Strict mode preamble

Top of every Bash script:

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
```

`-e` exit on error, `-u` error on unset var, `-o pipefail` propagate pipe failures, `IFS` removes spaces from word-splitting (defensive, doesn't replace quoting).

### Root check (Pattern A — preferred)

```bash
if [[ $EUID -ne 0 ]]; then
    echo "must run as root" >&2
    exit 1
fi
```

Then no `sudo` inside the script. Caller invokes with `sudo`.

### Unified trap for cleanup

```bash
tmp_a=""
tmp_b=""
trap 'rm -f "$tmp_a" "$tmp_b"' EXIT
# ... later assign tmp_a=$(mktemp ...) etc.
```

`trap` *replaces*, doesn't append — one trap at the top, all temp vars listed. Initialise vars empty so the trap is safe even if it fires before any `mktemp` ran (matters under `set -u`).

### Atomic file install via mktemp

For files where partial writes would be catastrophic (sudoers, authorized_keys, sshd_config snippets):

```bash
tmp=$(mktemp "$target_dir/.tmp.XXXXXX")    # same FS as target → atomic mv
# ... write content + validate ...
mv "$tmp" "$target_dir/finalname"
```

The `XXXXXX` (≥3 capital X's) is required by mktemp. Putting the temp file in the same filesystem as the destination guarantees `mv` is atomic.

### Heredoc to file

```bash
cat > /path/to/file <<EOF
content
EOF
```

The redirect `>` goes on the **opening** line, not the closing. The closing `EOF` must be alone on its line, flush-left. Use `<<-EOF` if you need to indent the closing tag (allows leading tabs only, not spaces).

### Stderr redirect

```bash
echo "error message" >&2
```

Sends to stderr (fd 2) instead of stdout (fd 1). Use for error/diagnostic output so it doesn't pollute pipelines that consume the script's stdout.

### `shellcheck` — non-negotiable

```
apt install shellcheck
shellcheck script.sh
```

Catches unquoted variables, missing braces, syntax bugs, every common gotcha. Run before considering any script done.

---

## sudoers

### Safe sudoers install pattern

```bash
tmp=$(mktemp "/etc/sudoers.d/.tmp.XXXXXX")
cat > "$tmp" <<EOF
deploy ALL=(ALL) NOPASSWD:ALL
EOF
visudo -c -f "$tmp"           # validate before install — non-zero exits via set -e
mv "$tmp" "/etc/sudoers.d/deploy"
chown root:root "/etc/sudoers.d/deploy"
chmod 440 "/etc/sudoers.d/deploy"
```

Bad sudoers = sudo broken entirely → console rescue territory. **Always** `visudo -c -f` before installing.

Sudo skips files in `/etc/sudoers.d/` whose names start with `.` — that's why the temp file with `.tmp.` prefix doesn't activate prematurely.

---

## sshd / SSH config debugging

### Show effective config (truth oracle)

```
sudo sshd -T
sudo sshd -T | grep -iE 'password|permitroot|kbd|pubkey'
```

`-T` (capital T) shows the **effective** config after merging everything in `sshd_config` + `sshd_config.d/`. Different from `-t` (lowercase, validates syntax). When something seems "applied but not working", `sshd -T` is the truth.

### sshd_config is first-match-wins

Files in `/etc/ssh/sshd_config.d/` are read **alphabetically**, and **the first occurrence of each directive wins** (not the last). Cloud-init drops `50-cloud-init.conf` setting `PasswordAuthentication yes` — your hardening file must come first alphabetically (`00-hardening.conf`) to override.

### Reload, don't restart

```
systemctl reload ssh
```

Reload re-reads config without dropping existing connections (your safety-rope SSH session stays alive). Restart drops everything. Use reload unless you have a specific reason not to.

---

## GitHub `.keys` URL — public-key source-of-truth

```
curl -fsSL "https://github.com/<your-username>.keys" -o authorized_keys
```

Returns every public key on your GitHub account, one per line. Single source of truth across all your hosts: add a key to GitHub → re-run bootstrap → all hosts pick it up. Revoke a key from GitHub → next bootstrap removes it.

`-fsSL`: `f` fail on HTTP errors, `s` silent, `S` show errors anyway, `L` follow redirects. Forgetting `-f` is the classic curl footgun (silently writes the 404 page into authorized_keys).

---

## Git / workflow

_(append as discovered)_

---

## Kubernetes

_(append from phase 2)_

---

## Terraform / Ansible

_(append from phases 3–4)_

---

## Observability

_(append from phase 5)_

---

## Resources — for the things to improve on

Curated reading lists / tools per skill area. High-signal only. Add to this list as new alerts surface in `phases/0X-*/lessons.md`.

### Bash & shell scripting (current weak spot)

- **ShellCheck** — `apt install shellcheck`. Run on every script. Flags ~every bug from phase 0 (unquoted vars, syntax issues, missing `mv` destinations). Single highest-ROI tool in this list.
- **"Bash strict mode" — Aaron Maxwell.** The canonical article on `set -euo pipefail` + `IFS`. Read once, re-read when something behaves weird.
- **Greg's Wiki — BashFAQ** (`mywiki.wooledge.org/BashFAQ`). The community-maintained FAQ. Authoritative answers to "why is bash doing X?" for almost every X.
- **Google Shell Style Guide.** Industry-standard conventions. Defaults to "always quote".
- **Drill plan:** write 5 idempotent bootstrap-flavoured scripts from scratch in the next 2 weeks. Each <60 lines, ShellCheck-clean. Suggested topics: add a deploy user, install + harden Postgres, set up a backup cron, rotate logs, install + configure a reverse proxy.

### Linux / networking (phase 1 ramp)

- ***The Linux Programming Interface* (Kerrisk).** Reference, not cover-to-cover. Chapters on namespaces, cgroups, signals, processes are interview-grade — these are the primitives K8s abstracts.
- **`man sshd_config` and `man systemd.service`.** Read both end-to-end before phase 1. Surprisingly well-written.
- **nftables wiki** (`wiki.nftables.org`). Direct from the project — better than third-party tutorials.
- **WireGuard quickstart** (`wireguard.com/quickstart`). Short, official.

### Kubernetes (phase 2 deep dive)

- ***Kubernetes the Hard Way* (Kelsey Hightower).** Free on GitHub. The phase-2 backbone.
- **Kubernetes docs — Concepts section** (`kubernetes.io/docs/concepts/`). Better than every third-party tutorial.
- **killer.sh / killercoda.com.** CKA mock exams.
- **CKA exam objectives PDF** (linked from cncf.io's CKA program page). Print it, tick it off.

### Go (15% drip starting phase 2)

- **A Tour of Go** (`go.dev/tour`). Interactive, ~3 hours.
- **Go by Example** (`gobyexample.com`). Searchable cookbook.
- **Effective Go** (`go.dev/doc/effective_go`). Official idiomatic patterns. Re-read every couple of months.
- **The Kubebuilder Book** (`book.kubebuilder.io`). Phase 6 infra-flavor capstone reference.

### Python (10% drip from phase 3)

- ***Python for DevOps* (O'Reilly — Gift, Behrman, Deza, Gheorghiu).** Pragmatic, ops-focused.
- **`ansible.builtin` module docs.** The standard library you'll actually use in phase 3.
- **`ruamel.yaml` over `PyYAML` for hand-edited files.** Preserves comments + key order.

### IaC & config management (phases 3–4)

- ***Ansible for DevOps* (Jeff Geerling).** Chapters 4–7 are the practical core.
- ***Terraform: Up & Running* (Yevgeniy Brikman).** Modules, state, workspaces. Skim, don't grind.
- **Geerling's YouTube channel.** Concrete and current.

### Observability & SRE (phase 5)

- ***Site Reliability Engineering* — Google** (`sre.google/books`). Free. Chapters 1–6 first.
- ***The Site Reliability Workbook* — Google** (also at `sre.google/books`). Multi-window burn-rate alerting chapter is essential.
- **Charity Majors — anything she writes.** Practical observability, especially on cardinality and structured events.
- ***Systems Performance* (Brendan Gregg).** Reference for perf debugging; the USE method.

### Cross-cutting / interview prep (phases 6–7)

- ***Designing Data-Intensive Applications* (Martin Kleppmann).** System-design canon. Phase 6 prep.
- ***The Tech Resume Inside Out* (Gergely Orosz).** Phase 7 polish reference.
- ***The Manager's Path* (Camille Fournier).** IC framing on roles helps interviews.
- **"Awesome SRE" GitHub list.** Curated reading list per topic.
