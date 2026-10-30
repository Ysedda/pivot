# Phase 0 — Lab bootstrap — Lessons

> Carried over from the first attempt (May 2026). Phase numbers here refer to that plan; the scripts now map to unit 1.6.

**2026-05-05 — Phase 0 — SSH port: kept it on 22**
Port-changing is security-by-obscurity — reduces drive-by scanner noise but doesn't replace key-only auth + fail2ban. Avoided the open-new-port → swap → test → close-22 dance (real mid-run lockout risk on a fresh box). Default fail2ban jails work out of the box. Interview line: *"Kept port 22. Real protection is key-only auth + fail2ban; port change is debatable security and the operational tradeoff wasn't worth it for this lab."*

**2026-05-05 — Phase 0 — Bash syntax: the basics bit me**
Spaces around `=` (`x=foo`, never `x = foo`). `[ -s "$f" ]` needs spaces inside brackets. `mktemp` template needs literal `XXXXXX`. Heredoc redirect on the opening line (`cat > file <<EOF`). `mv file dir/` keeps source filename — use `dir/finalname` for explicit destination. Quote variable expansions. → Drill: 5 idempotent scripts from blank in 2 weeks; `shellcheck` on every save.

**2026-05-05 — Phase 0 — Continue (what worked)**
- "I write, ask when stuck" mode actually held — no copy-paste of AI output.
- Pushed back on wrong info; the "PasswordAuthentication still on" callout surfaced the first-match-wins gotcha I'd missed.
- Architectural instinct on script split — asked unprompted whether user/SSH setup should be separate from firewall. That's the SRP boundary that scales to Ansible roles / Terraform modules / CI jobs. Carries over from backend; trust it.
- ~7 review cycles on the script without shortcutting to "just write it for me".
- Drill 1 (clean bootstrap): **3:04**, target <15 min. Drill 2 (idempotency): silent re-run.

**2026-05-05 — Phase 0 — Alerts (drill these)**
- Bash syntax fundamentals (see entry above). `shellcheck` on every script — would have caught most of these without me asking.
- Variable-name typos silently no-op'd the unified trap. Disciplined renames + shellcheck.

**2026-05-05 — Phase 0 — Tech worth keeping**
- sshd_config is **first-match-wins**, not last-wins. `sshd -T` shows effective config; `sshd -t` only validates syntax. Cloud-init's `50-cloud-init.conf` silently overrode my `99-hardening.conf`. Renamed mine to `00-` to win.
- `trap` *replaces*, doesn't append. One top-of-file trap with all temp vars (declared empty for `set -u` safety).
- Sudoers: 0440 + root:root + `visudo -c -f` before install. Bad sudoers = sudo broken entirely → console rescue territory.
- gh.keys install pattern: temp file → validate non-empty → grep for key signature → atomic mv → chmod/chown last.
- **`~/.ssh/config` Host entries — best QoL upgrade in this phase.** Every iteration command went from `ssh <user>@<ip-address> …` to `ssh lab-vps …`. Adds up over hundreds of invocations across the program. Pattern:
  ```
  Host <name>
      HostName <ip-address>
      User <user>
      IdentityFile ~/.ssh/<key_file>
  ```
  When the IP changes (VPS reset / phase 4 TF rebuild), you update one line, not every script and shell history. Worth setting up on every laptop you work from.

**2026-05-05 — Phase 0 — nftables: atomic ruleset load**
Don't run `nft flush ruleset` as a separate command before writing the new config. That opens a window with NO firewall between the flush and `systemctl restart nftables`. If `nft -c -f` rejects the new config, or the restart fails, the box stays exposed.

Put `flush ruleset` as the **first line inside** `/etc/nftables.conf` instead. systemd's `nftables.service` then loads-and-flushes in one kernel transaction — the kernel never sees a half-state. Atomic ruleset replacement is one of nftables' main advantages over iptables; using a separate `nft flush` throws it away.

**2026-05-05 — Phase 0 — Default verdicts belong in chain headers**
First version had `policy accept;` + a trailing `drop` rule. Functionally equivalent to `policy drop;` with no trailing rule, but **fragile**: if the trailing rule gets deleted/mistyped/truncated, the firewall silently inverts to default-allow. `policy drop;` in the chain header fails *closed* on any partial config.

Generalizes well beyond nftables — AWS Security Groups, K8s NetworkPolicies, sudoers all encode their defaults declaratively, not via "the last rule." **Fail-closed beats fail-open.** Interview line: *"Defaults belong in chain headers, not trailing rules — the policy line is harder to delete by accident than the last rule in a list."*

**2026-05-05 — Phase 0 — Stateful firewalling: SYNs vs established, proven empirically**
Counters made the model concrete. With `tcp dport 22 counter accept` and `ct state established,related counter accept` in the input chain, a snapshot showed:

```
ct state established,related counter packets 4150 bytes 16691397 accept
tcp dport 22                  counter packets 11   bytes 664      accept
```

`664 / 11 = 60.4 bytes/packet` — exactly the wire size of a bare TCP SYN (no payload). Empirical proof: dport-22 only ever sees SYNs; once a connection is established, every subsequent packet matches the est/rel rule higher in the chain and never reaches dport-22.

`apt update` working without any explicit `tcp dport 80 accept` proves the firewall is genuinely stateful (not just permissive-by-default): replies have src port 80 / dst port = ephemeral, don't match any specific rule, only get through via `ct state established,related accept`. Drop conntrack tracking or the est/rel rule and apt update hangs forever.

Mental model to keep:
| Direction | Rule that does the work |
|---|---|
| Inbound new connection (e.g. ssh from laptop) | per-port accept (`tcp dport 22`) — only matches the SYN |
| Inbound reply to my outbound (apt, DNS, curl) | `ct state established,related accept` |
| Inbound everything else | trailing drop / `policy drop` |
| Outbound new connection | output `policy accept` |

**2026-05-05 — Phase 0 — `iif lo accept` is non-negotiable**
Loopback traffic still traverses netfilter — without an explicit allow, default-deny blocks it. Things that break: anything binding to 127.0.0.1 (postgres, redis, dev servers), systemd-resolved (DNS resolution dies), localhost healthchecks. Rule #1 in any input chain.

**2026-05-05 — Phase 0 — Heredoc gotcha: unquoted EOF still treats `"` as literal**
Inside `<<EOF` (unquoted), only `$var` and `\` get special treatment. Quotes are literal. Wrote `"$username" ALL=(ALL) NOPASSWD:ALL` thinking the quotes would be stripped post-expansion — got `"deploy" ALL=...` in the actual sudoers file, which sudo silently doesn't match against the runtime user `deploy`. Loss of NOPASSWD with no error. Caught only via review (and `shellcheck` doesn't flag it — heredoc internals are valid bash).

Rules:
- Inside `<<EOF`: `$var` expands, `\` escapes, everything else is literal — including `"`.
- To disable expansion entirely: `<<'EOF'` (single-quoted EOF).

**2026-05-05 — Phase 0 — Existence check ≠ installation check**
First version of the firewall script had `if [ ! -f /etc/nftables.conf ]; then exit 1; fi` framed as "check that nftables is installed." Wrong: file existence is a *proxy* for installation, conflating two concerns. Final version inverts: backup-if-exists, otherwise no-op, and let `systemctl restart nftables.service` fail naturally with a clear "Unit not found" error if the package is genuinely missing.

General principle: tests should mean what they say. `command -v nft` checks installation. `[ -f /etc/nftables.conf ]` checks file existence. Don't conflate.

**2026-05-12 — Phase 0 — Drop-in directories: pattern beats backups**
Editing package-shipped config (`jail.conf`, `sshd_config`, `sudoers`) loses on every `apt upgrade`: dpkg detects local edits to a *conffile* and forces a three-way reconcile — keep-old (miss upstream improvements), take-new (lose customisation), or `.dpkg-dist`/`.dpkg-old` files to merge by hand forever. Backups don't fix this; **separating immutable from mutable** does. Find the drop-in directory and write a sparse override:

- `/etc/ssh/sshd_config.d/00-hardening.conf`
- `/etc/fail2ban/jail.d/sshd.local`
- `/etc/sudoers.d/deploy`
- `/etc/sysctl.d/`, `/etc/systemd/system/<unit>.d/`, `/etc/apt/apt.conf.d/`, `/etc/logrotate.d/`, `/etc/cron.d/`, `/etc/profile.d/`

If a tool has no drop-in mechanism, that's a usability bug worth filing. Carries to Ansible (`copy` vs drop-in `template`), Terraform (managed vs unmanaged resources), K8s (server-side apply field ownership). Interview line: *"Drop-in dirs separate package state from local state — same pattern across sshd, fail2ban, sudoers, sysctl, systemd. Editing the main file is a code smell."*

**2026-05-12 — Phase 0 — `set -e` + `$?` is dead code, and the exemption table that fixes it**
Wrote `cmd; rc=$?; if [ "$rc" -ne 0 ]; then …; fi` under `set -euo pipefail`. The `if` is unreachable: `cmd` returning non-zero aborts the script on its own line; `rc=$?` and the `if` never run.

`set -e` has **exempt positions** where it steps aside (because in those positions you're explicitly checking exit status):

| Position | `set -e` aborts? |
|---|---|
| Top-level command | yes |
| `if cmd; then …` (cmd part) | no |
| `while cmd; do …` (cmd part) | no |
| `cmd1 && cmd2` (left side) | no |
| `cmd1 \|\| cmd2` (left side) | no |
| `! cmd` | no |

Two idiomatic capture patterns:
- **`if ! cmd; then …`** — when you only need success/failure
- **`rc=0; cmd || rc=$?; if (( rc != 0 )); then …`** — when different exit codes mean different things (e.g., `grep` 0=match, 1=no-match, 2=error)

Re-applies in Ansible (`failed_when`, `register`), CI scripts, any strict-mode context. Interview line: *"Under set -e, exit codes are inspectable only in exempt positions — `if`, `while`, `&&`, `||`, `!`. Outside those, `$?` is dead — script's already gone."*

**2026-05-12 — Phase 0 — fail2ban: `.conf`/`.local` overlay + tree-level validation forces post-write rollback**
`jail.conf` is a dpkg conffile — never edit. Override goes in `jail.d/sshd.local` as a *sparse* file, only keys that change from the upstream `[sshd]` defaults:

```ini
[sshd]
enabled = true
```

That's the minimal valid jail. Copying the whole `jail.conf` into `jail.local` freezes you on today's defaults forever — defeats the layering.

`fail2ban-client -t` validates the **currently-loaded tree**, not a file argument. Unlike `visudo -c -f tmp` / `nft -c -f tmp` (file-level → validate-then-install), the only working shape is:

1. `mv` the new file into place
2. `fail2ban-client -t`
3. on failure: `rm` the bad file + exit non-zero

The tool dictates the validation pattern. General principle: **before reaching for "validate then commit", check what the validator can actually do** — file-level validators allow staged installs; tree-level validators force the rollback shape.

Bonus observation from `fail2ban-client status sshd`: the `Journal matches:` line (vs `File list:`) confirms upstream defaults resolve `backend` to `systemd` on Ubuntu 24.04 — minimal overrides inherit modern decisions for free. Over-specifying `backend = auto` or `logpath = /var/log/auth.log` would have fought a perfectly-good default.
