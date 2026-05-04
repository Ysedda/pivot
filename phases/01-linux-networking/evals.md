# Phase 1 — Evals

**Passing bar:** Drills 1–3 pass + at least one break-fix passes + both whiteboards delivered. ~5 hours of eval time.

## Drill 1 — Container from scratch (target: 45 min)

On a fresh shell, no Docker/Podman, no notes:

1. Build a minimal rootfs with `debootstrap` (or `pacstrap`).
2. Use `unshare` to create new pid + mount + uts + net namespaces.
3. Mount `/proc` inside.
4. Create a memory cgroup capped at 100 MB; place the process inside.
5. Run `bash` in the isolated env. Verify:
   - `ps aux` shows the new bash as PID 1.
   - `hostname` differs from the host.
   - Allocating >100 MB triggers OOM kill (use a memory hog like `tail /dev/zero`).

**Pass:** all five verifications within 45 min.
**Partial:** ≥3 verifications, or completed in 45–75 min.
**Fail:** otherwise.

## Drill 2 — Packet trace end-to-end (target: 30 min)

Make a request from your laptop to `https://<service>.<your-domain>`. Capture and identify the packet at each hop:

1. DNS query on your laptop — `dig` output showing the resolved IP.
2. TLS handshake at the VPS — `tcpdump -i eth0 'port 443'` showing ClientHello with SNI.
3. Reverse proxy decision — proxy logs showing the route match, upstream selected.
4. Backend request — `tcpdump` on the loopback or service interface showing the proxy → service hop.
5. Response leaving the VPS — TLS records flowing back over `eth0`.

**Pass:** all five captures saved + a short README explaining what each shows.

## Drill 3 — Certificate forensics (target: 20 min)

For one of your services:

1. Use `openssl s_client -connect host:443 -servername host` to print the chain.
2. Identify: leaf cert SANs, issuer CA, root CA, expiry date, signature algorithm.
3. Verify chain validity manually with `openssl verify -CAfile`.
4. Bonus: extract the public key and compute its fingerprint.

**Pass:** all four answered in writing in `tasks/whiteboards/01/cert-forensics.md`.

## Break-fix 1 — Cert renewal failure (target: 30 min)

Claude (or you) breaks one of:
- DNS API token revoked → DNS-01 challenge fails.
- Cert expired and renewal task disabled.
- ACME directory URL pointed at staging in production.
- Caddy/Traefik unable to write to its cert volume.

**Pass:** root cause identified and fix applied in <30 min. Postmortem in `tasks/postmortems/`.

## Break-fix 2 — Service unreachable (target: 30 min)

Claude breaks one of:
- nftables rule dropping inbound traffic to HTTPS.
- Reverse proxy backend pointing at wrong upstream port.
- Service crashed (systemd failed); reverse proxy returns 502.
- DNS A record pointed at old IP.
- Reverse proxy config has a typo causing it to fail-load with the previous config still serving (silent stale state).

**Pass:** service restored in <30 min using `dig` / `curl -v` / `tcpdump` / `journalctl` / `systemctl status` only.

## Whiteboard 1 — Full packet path (target: 10 min, no notes)

Trace a request from your laptop to `https://gitea.<domain>`:
- DNS resolution path (recursive resolvers, root, TLD, your authoritative).
- TCP three-way handshake target.
- TLS handshake — what does the VPS present, why does the laptop trust it?
- Reverse proxy decision — how does it route by hostname (SNI / Host header)?
- Backend service — what's the proxy → service hop look like, and why doesn't it use TLS internally (or, if it does, what changes)?

## Whiteboard 2 — Namespace isolation (target: 5 min, no notes)

Explain the difference between net, mount, pid, user, uts, ipc namespaces. Which does Docker use? Which does `nsenter` operate on?

## External attestation

None — phase 4 is where the first big external (CKA) lands.

## Retention check (schedule for 2026-07-14)

Redo Drill 3 cold against any current TLS service. Cert literacy is the part most likely to atrophy.
