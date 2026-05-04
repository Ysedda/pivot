# Phase 2 — Ansible + lab bring-up + storage

**Duration:** 4 weeks  
**Target end:** 2026-06-30  
**Hours budget:** ~50

## Goal

Stand up the real multi-host lab on Proxmox, accessible from anywhere via Wireguard, then manage everything declaratively via Ansible. Storage primitives (LVM, partitions, df/du, inodes) are woven through Proxmox install + Ansible storage modules — not a separate side-quest. By the end you should be writing idempotent roles fluently, debugging convergence with `--check` and `--diff`, and testing roles with Molecule.

## Why this phase

Three skills, one phase, all load-bearing for the rest of the program:

- **Ansible** — appears in the majority of French DevOps job ads. Encodes a different mental model from Terraform (convergent imperative vs declarative state), itself worth carrying. Most directly portable to the French market: even shops that don't use Kubernetes use Ansible.
- **Proxmox + Wireguard** — the lab grows from "single VPS" to "real multi-host with remote access from work." Proxmox is common in French shops (and homelabs); the WG hub-and-spoke topology is interview-grade home-lab kit.
- **Storage primitives** — LVM, partitions, inodes, df/du. Bread-and-butter Linux admin that K8s abstracts but doesn't replace. Production-relevant via Ansible automation, not memorised in isolation.

> **Lab transition at start of this phase.** Proxmox VE installed on the spare 16GB PC; the OVH sacrificial VPS becomes the WG hub. Phase-1 services migrate from the VPS to Proxmox VMs declaratively — that migration *is* the motivation for the Ansible phase. Heads-up: OVH VPSes expire ~2026-07; before then, plan a successor cloud VPS for the WG hub role only.

## Deliverable

An `ansible/` directory in this repo containing:

- An inventory describing the lab (3-4 Proxmox VMs + the OVH WG hub).
- Roles that fully bring up: `base-host` (replacing phase-0 Bash), `wireguard` (peer config), `storage` (LVM provisioning), reverse proxy + cert-manager, the phase-1 services migrated to Proxmox.
- `ansible-vault` for any secret material (deploy keys, API tokens, peer keys).
- `molecule/` config testing at least one role in isolation.
- A README with the commands to bring up the lab from blank.

**Definition of done:** wipe one Proxmox VM back to a fresh OS image. Run `ansible-playbook -i inventory site.yml`. Within 30 minutes the VM is fully operational — base-host hardened, Wireguarded, storage provisioned, services running, reachable from work-laptop over WG.

## Checklist

### Lab kickoff (week 1)

- [ ] Install Proxmox VE 8.x on the spare 16GB PC. Static IP on home LAN, admin user + API token (you'll use the token from Ansible and again in phase 3 from Terraform).
- [ ] **Storage decisions** — LVM-thin (Proxmox default) vs ZFS for the VM storage pool. One paragraph in `lessons.md` on rationale + tradeoffs.
- [ ] **Storage primer** — read & summarise: inodes (`df -i`), partitions (`lsblk`, `parted`), `df` vs `du`, LVM (PV / VG / LV). Notes in `lessons.md`.
- [ ] Provision 3-4 Ubuntu Server 24.04 VMs in Proxmox. Cloud-init template + clones recommended (idempotent VM creation pays back in phase 3).
- [ ] **Wireguard hub-and-spoke** via the OVH VPS:
  - [ ] Keypair on hub (OVH VPS), Proxmox host, work-laptop.
  - [ ] Hub config: peers + AllowedIPs + IP forwarding + nftables forward rules between peers.
  - [ ] Peer configs with `PersistentKeepalive` (NAT traversal — your home router will drop the UDP flow without it).
  - [ ] Verify SSH from work-laptop to a Proxmox VM via WG (`ssh user@vm-wg-ip` over the tunnel).
- [ ] **Plan WG hub successor** for post-July OVH expiry — short writeup in `lessons.md` (cheapest cloud VPS, single role: WG hub + maybe a TLS-termination reverse proxy).

### Ansible foundations (week 2)

- [ ] Read & summarise Ansible's execution model (control node → SSH → modules pushed and run on remote, fact gathering, idempotency contract). Notes in `lessons.md`.
- [ ] Ad-hoc commands fluent: `ansible all -m ping`, `-a "uptime"`, `-m apt -a "name=htop state=present" -b`. Use them daily during the phase.
- [ ] Inventory: static `hosts.yml` of Proxmox VMs + group_vars / host_vars precedence test. Test that overrides resolve as you expect.
- [ ] First playbook: install + configure one tool on multiple VMs. Tag tasks. Run with `--tags`, `--check`, `--diff`. Internalise what each shows.
- [ ] Refactor that playbook into a `role` under `roles/<name>/`. Defaults, tasks, templates, handlers, meta.
- [ ] Galaxy / collections: pull in `community.general`, `ansible.posix`, `community.docker`. Pin versions in `requirements.yml`.

### Real conversions (week 3)

- [ ] Convert `lab-bootstrap/bootstrap-host.sh` (phase 0) to a `base-host` role. Side-by-side with the Bash version; **do not delete the Bash one**. The diff is the learning artifact.
- [ ] **`storage` role** — provisions a `/data` LV on each VM via `community.general.lvg` + `lvol`, formats with ext4 or xfs, mounts via `ansible.posix.mount` + fstab. Idempotent (re-running on an already-provisioned host is a no-op).
- [ ] `wireguard` role for VM peers (Jinja2-templated `wg0.conf`, peer keys held in `ansible-vault`).
- [ ] Convert phase-1 reverse-proxy + service deployment to roles. Migrate to Proxmox VMs (Gitea + Vaultwarden + status page on `/data`-backed Compose stacks via `community.docker`).
- [ ] DNS records updated to point at the new Proxmox-VM-backed services (via WG hub for ingress, or directly if you publish a public IP).

### Variables, templates, vault (week 4)

- [ ] Templates with Jinja2: `wg0.conf`, reverse-proxy dynamic config, service env files. Loops, conditionals, filters (`default()`, `mandatory`, `regex_replace`).
- [ ] `ansible-vault create secrets.yml`, `ansible-vault edit`, encrypted vars in CI via `--vault-password-file`. Document the rotation story in the role README.
- [ ] Variable precedence: write a 5-line cheat-sheet in `lessons.md`. Don't memorise the 22-level list — understand the broad order.

### Quality & testing

- [ ] `ansible-lint` clean on every role.
- [ ] `yamllint` clean across `ansible/`.
- [ ] **Molecule** scenario for the `base-host` role: spin up a Docker container, converge, verify idempotency (second run must show 0 changed), destroy. CI-friendly.
- [ ] Run with `--check --diff` and explain in `lessons.md` what each shows you that the actual apply doesn't.

### Dynamic inventory (preview of phase 3)

- [ ] Write a small dynamic inventory script in **Python** (Python drip — this is the canonical Ansible+Python interface) that returns hosts based on a static JSON file. Run a real playbook against it. Phase 3 will plug Terraform outputs into this slot.

### Drill

- [ ] **Storage incident drill:** exhaust inodes on a service VM (`mkdir /data/junk && for i in $(seq 1 500000); do touch /data/junk/.f$i; done`) — `df` shows free space, writes fail with `No space left on device`. Diagnose with `df -i`, recover. Or alternative: fill a `/data` LV to 100% and extend live with `lvextend` + `resize2fs` via Ansible. Postmortem in `tasks/postmortems/`.

## Resources

- Proxmox VE admin guide — https://pve.proxmox.com/pve-docs/
- WireGuard quickstart — https://www.wireguard.com/quickstart/
- LVM HOWTO — https://tldp.org/HOWTO/LVM-HOWTO/
- Ansible official docs — User Guide. Focus: Playbook Keywords, Variable Precedence, Roles directory structure.
- *Ansible for DevOps* (Geerling) — chapters 4–7. The canonical book.
- Jeff Geerling's YouTube series — concrete and current.
- Molecule docs — molecule.readthedocs.io.
- `ansible-lint` rules — read at least the "production" profile.

## Stretch

- AWX (Ansible Tower OSS) on a Proxmox VM. Schedule a playbook from a UI. Useful exposure for SSII / consulting roles.
- Convert your nftables config (phase 1) to a templated role that generates rules from a list-of-services variable.
- Read one real-world role from a major company on Galaxy (e.g., `geerlingguy.docker`). Note the patterns that surprised you in `lessons.md`.
- **Go drip stretch:** write a small custom Ansible module *in Go* (modules just need to read JSON args from stdin and emit JSON). Bonus: compare to writing the same module in Python. Heavy Go-day exercise.
- Proxmox API exploration — your Proxmox host has a REST API. Browse via `curl` + token. Sets you up for the phase-3 TF Proxmox provider.

## Lessons

End of phase: ensure `lessons.md` captures, especially: the Bash-vs-Ansible diff for the bootstrap role, where `--check` / `--diff` lied to you, the storage layout choice rationale, and the WG hub-and-spoke quirks (NAT traversal, AllowedIPs CIDR planning, IP forwarding gotchas).
