# Phase 0 — Evals

**Passing bar:** Drills 1–3 all pass + whiteboard answered cold. Total eval time ~2 hours.

## Drill 1 — Bootstrap from clean image (target: 15 min)

1. Take a snapshot of the phase-0 VPS (provider console).
2. Rebuild the VPS from a fresh OS image (provider console "rebuild" option).
3. `ssh-copy-id` and run your bootstrap scripts.
4. Verify post-conditions:
   - SSH key-only auth (password login disabled).
   - Firewall active, only allowed ports open.
   - fail2ban running.
   - `wg-quick@wg0` service installed and configured (mesh activation deferred — no Pi peer yet).

**Pass:** all four post-conditions within 15 min wall time, zero script edits after `ssh-copy-id`.
**Partial:** 15–25 min, or one post-condition needed hand-holding.
**Fail:** >25 min, or scripts edited mid-run.

> **When the Pi returns:** re-run this drill with the mesh activation as a fifth post-condition (`ping` over wg IP succeeds, `wg show` shows handshake).

## Drill 2 — Idempotency (target: 5 min)

Run `bootstrap-host.sh` twice on the same host, capture both runs.

**Pass:** second run produces no diffs (or only re-applies expected drift), no errors, no duplicate user/group/rule creation.
**Fail:** any of the above wrong, or non-zero exit.

## Drill 3 — Lockout recovery — break-fix (target: 15 min)

Have Claude (or a colleague) revoke your SSH key on the VPS. Don't peek at what they did.

**Pass:** regain SSH access via the **provider's console rescue mode** and restore key auth in <15 min, no snapshot restore.
**Fail:** snapshot restore needed, or >15 min.

> **Variants Claude may pick from:** delete `~/.ssh/authorized_keys`, set `PasswordAuthentication no` *and* remove keys, modify `/etc/ssh/sshd_config` and HUP sshd, change AllowUsers.

> **When the Pi returns:** repeat this drill with wg-mediated recovery as the only allowed path (no console rescue). Tests a different recovery muscle.

## Whiteboard — explain cold, no notes (target: 5 min)

1. `set -euo pipefail` — what does each flag do, what's the failure mode each prevents?
2. How does the wg tunnel come up at boot? Which systemd unit? Where does the key exchange happen?
3. What's the threat model your firewall protects against? Be specific — "hackers" doesn't pass.

Write answers in `tasks/whiteboards/00/answers.md` if no human is around to grade.

## External attestation

None this phase.

## Retention check (schedule for 2026-06-17)

Redo Drill 2 cold. Should still pass — if not, the bootstrap scripts have rotted or you've forgotten basic Bash discipline.
