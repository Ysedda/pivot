# Tips & tricks

Small, copy-pasteable operational patterns. Living document — append as discovered. Different from `lessons/` (which is chronological retrospective per phase); this is a flat topic-organised cheatsheet for "how do I X again?" moments.

Search-friendly. When in doubt: add it here, future-me will thank current-me.

---

## SSH

### `~/.ssh/config` Host entries — biggest QoL upgrade in the program

Stop typing `ssh <user>@<ip-address> …`. Add to `~/.ssh/config` on every laptop you work from:

```
Host <name>
    HostName <ip-address>
    User <user>
    IdentityFile ~/.ssh/<key_file>
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

### Stop the `LC_CTYPE = "UTF-8"` warning storm (Mac → Linux)

When SSHing from macOS to Linux, every perl/locale-aware tool on the remote spews:

```
perl: warning: Setting locale failed.
LC_CTYPE = "UTF-8", LANG = "C.UTF-8"
locale: Cannot set LC_CTYPE to default locale
```

Cause: Mac sends `LC_CTYPE=UTF-8` (Mac-only locale name) over SSH via `SendEnv LC_*` in `/etc/ssh/ssh_config`. Linux has no locale literally named `UTF-8` (real names: `C.UTF-8`, `en_US.UTF-8`, etc.) → locale init falls back loudly.

Fix once on the Mac, applies to every server you SSH into. In `~/.ssh/config`:

```
Host *
    SendEnv LANG       # don't send LC_*
```

Or per-host with an explicit override:

```
Host lab-vps
    SendEnv LANG
    SetEnv LC_ALL=C.UTF-8
```

Server-side fix (`locale-gen en_US.UTF-8`) works too but you'd repeat it on every box.

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

### Execute script without copying on remote host

```
ssh host 'sudo bash -s' < script.sh
```

Opens a single ssh connection, runs `sudo bash` on the remote, pipes the local script as stdin. `bash -s` reads commands from stdin. No file lands on the box; stdout/stderr stream back live. Beats `scp + ssh + rm` in every dimension. Requires NOPASSWD sudo on the remote (else the password prompt hangs — no TTY for the non-interactive remote command).

---

## GitHub `.keys` URL — public-key source-of-truth

```
curl -fsSL "https://github.com/<your-username>.keys" -o authorized_keys
```

Returns every public key on your GitHub account, one per line. Single source of truth across all your hosts: add a key to GitHub → re-run bootstrap → all hosts pick it up. Revoke a key from GitHub → next bootstrap removes it.

`-fsSL`: `f` fail on HTTP errors, `s` silent, `S` show errors anyway, `L` follow redirects. Forgetting `-f` is the classic curl footgun (silently writes the 404 page into authorized_keys).

---

## nftables

### Atomic ruleset load

Put `flush ruleset` as the **first line inside** `/etc/nftables.conf`, not as a separate `nft flush ruleset` command before writing the file:

```nft
flush ruleset
table inet filter {
    ...
}
```

`systemctl restart nftables.service` then loads-and-flushes in one kernel transaction — no window with no firewall. Atomic ruleset replacement is the main advantage over iptables; using a separate `nft flush` throws it away.

### Validate before applying

```bash
nft -c -f /etc/nftables.conf       # syntax check, no apply
```

Returns non-zero on syntax errors. Combined with `set -e`, the script aborts before `systemctl restart` runs and you don't load broken rules.

### Canonical stateful input chain

```nft
chain input {
    type filter hook input priority filter; policy drop
    iif lo accept
    ct state established,related counter accept
    tcp dport 22 counter accept
}
```

Order matters — rules are top-to-bottom, first match wins:

1. `policy drop` — declared default-deny in the chain header. Fail-closed on partial config.
2. `iif lo accept` — loopback first, or local services break (postgres on 127.0.0.1, systemd-resolved DNS, healthchecks).
3. `ct state established,related accept` — fastpath for return traffic of outbound connections AND ongoing inbound sessions. Matches ~99% of packets.
4. `tcp dport <service> accept` — per-service gates. These only match the SYN of new inbound connections; subsequent packets ride est/rel above.
5. (no trailing `drop` needed — `policy drop` handles unmatched traffic).

### Default verdict in chain header, not as trailing rule

Prefer:

```
type filter hook input priority filter; policy drop
... explicit accepts ...
```

Over:

```
type filter hook input priority filter; policy accept
... explicit accepts ...
drop                                    # fragile — delete by accident → wide open
```

Same principle as AWS Security Groups, K8s NetworkPolicies, sudoers: declare the default, don't encode it as the last rule.

### Counters as live debugging

Add `counter` to any rule:

```nft
tcp dport 22 counter accept
```

Then `nft list ruleset` shows packet/byte counts:

```
tcp dport 22 counter packets 11 bytes 664 accept
```

`664 / 11 = 60.4 bytes/packet` is the wire size of a bare TCP SYN — confirms the rule only sees SYNs (subsequent packets match est/rel above and never reach this rule). The byte/packet ratio tells you what's actually matching. Cheap, leave them on during phase-0 review for self-documenting rules.

### Inspect the live ruleset

```bash
sudo nft list ruleset                  # full
sudo nft list ruleset | grep -i counter # see what's matching
sudo conntrack -L                       # active connections in the kernel state table
```

`nft list ruleset` is the truth oracle — diff it against `/etc/nftables.conf` if you suspect drift.

### Enable persistence

```bash
sudo systemctl enable nftables.service     # survives reboot
sudo systemctl is-enabled nftables          # → "enabled"
```

`restart` loads the current `/etc/nftables.conf`. `enable` makes systemd reload it on every boot. Both needed.

---

## apt

### `apt` vs `apt-get` — interactive vs scripted

`apt` is the user-facing CLI (colours, progress bar, friendlier defaults). `apt-get` is the stable scripting interface. From `apt(8)`:

> Scripts should continue to use apt-get(8) for stability of output and behaviour.

`apt`'s flags and output format aren't promised stable across releases — some versions literally print `WARNING: apt does not have a stable CLI interface. Use with caution in scripts.` to stderr in non-interactive mode. Use `apt-get install -y` in bootstrap scripts; reserve `apt` for the shell.

### `DEBIAN_FRONTEND=noninteractive` for non-TTY runs

Running scripts over SSH with `bash -s` has no controlling TTY. debconf falls through Dialog → Readline → Teletype trying to find an interactive prompt and prints noisy warnings. For packages that *would* prompt (`iptables-persistent`, `postfix`, etc.) the install can hang. Silence + non-hang in one:

```bash
export DEBIAN_FRONTEND=noninteractive
apt-get install -y <pkg>
```

Add to the top of bootstrap scripts that run over SSH.

---

## fail2ban

### Minimal override — never edit `jail.conf`

`/etc/fail2ban/jail.conf` is package-managed. Override via `/etc/fail2ban/jail.d/<jail>.local` (or `jail.local`):

```ini
# /etc/fail2ban/jail.d/sshd.local
[sshd]
enabled = true
```

Three lines. `port`, `logpath`, `backend`, `mode` all inherit from upstream `[DEFAULT]` and `[sshd]` — including modern decisions like `backend = systemd` (journald) on systemd distros. Never copy `jail.conf` into `jail.local` — freezes you on today's defaults.

### Validate post-write (the tool forces this)

`fail2ban-client -t` validates the **currently-loaded tree**, not a file argument. So:

```bash
mv "$tmp" /etc/fail2ban/jail.d/sshd.local
if ! fail2ban-client -t; then
    rm -f /etc/fail2ban/jail.d/sshd.local
    echo "fail2ban rejected the config" >&2
    exit 1
fi
```

Different shape from `visudo -c -f tmp` / `nft -c -f tmp` (validate-then-install).

### Confirm jail is alive

```
sudo fail2ban-client status sshd
```

The `Journal matches:` (or `File list:`) line is the truth — shows what the jail is actually watching. If you broke `%(sshd_log)s` interpolation by clobbering `[DEFAULT]`, this line is empty.

Banned IPs:

```
sudo fail2ban-client set sshd unbanip <ip>
```

Locked yourself out? `unbanip` from console.

---

## Git / workflow

_(append as discovered)_

---

## Kubernetes

_(append from phase 4)_

---

## Terraform / Ansible

_(append from phases 2–3)_

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

### Kubernetes (phase 4 deep dive)

- ***Kubernetes the Hard Way* (Kelsey Hightower).** Free on GitHub. The phase-2 backbone.
- **Kubernetes docs — Concepts section** (`kubernetes.io/docs/concepts/`). Better than every third-party tutorial.
- **killer.sh / killercoda.com.** CKA mock exams.
- **CKA exam objectives PDF** (linked from cncf.io's CKA program page). Print it, tick it off.

### Go (15% drip starting phase 2)

- **A Tour of Go** (`go.dev/tour`). Interactive, ~3 hours.
- **Go by Example** (`gobyexample.com`). Searchable cookbook.
- **Effective Go** (`go.dev/doc/effective_go`). Official idiomatic patterns. Re-read every couple of months.
- **The Kubebuilder Book** (`book.kubebuilder.io`). Phase 6 infra-flavor capstone reference.

### Python (10% drip from phase 2)

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
