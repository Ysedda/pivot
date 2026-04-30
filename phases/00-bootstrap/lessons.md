# Phase 0 — Lab bootstrap — Lessons

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
- **`~/.ssh/config` Host entries — best QoL upgrade in this phase.** Every iteration command went from `ssh deploy@57.129.45.255 …` to `ssh lab-vps …`. Adds up over hundreds of invocations across the program. Pattern:
  ```
  Host lab-vps
      HostName 57.129.45.255
      User deploy
      IdentityFile ~/.ssh/id_ed25519
  ```
  When the IP changes (VPS reset / phase 4 TF rebuild), you update one line, not every script and shell history. Worth setting up on every laptop you work from.
