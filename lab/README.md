# Lab

## Hardware

| | |
| --- | --- |
| Machine | ASUS Vivobook Pro 15 (K6500ZC), laptop |
| CPU | Intel i7-12650H: 6 performance + 4 efficiency cores, 16 threads, VT-x |
| RAM | 15 GB usable |
| Disk | 1 TB NVMe |
| GPU | Intel UHD (screen) + NVIDIA RTX 3050 Laptop 4 GB (unused for now) |
| Network | **Wi-Fi only**, no ethernet port |
| Benchmark | 7-Zip: 42 107 MIPS all threads, 7 582 single thread (idle, on AC) |

## Network design

```
home LAN 192.168.1.0/24 ── router .254 ── internet
   │
   └─ Proxmox host  wlo1 192.168.1.50 (Wi-Fi, static)
         │
         └─ vmbr0 10.10.10.1/24  (bridge with no physical port)
               └─ guests 10.10.10.x  → NAT (masquerade) out of wlo1
```

- Bridging guests straight onto the LAN doesn't work over Wi-Fi: an access point only accepts frames from the MAC address that associated with it, so guests' own MACs get dropped.
- So guests get a private network and leave through NAT on the host. Outbound works; inbound from the LAN needs a route via `192.168.1.50` (or port forwards).

## Status

The current install was set up quickly, with help, on 2026-10-24 to get a working box. **It doesn't count**: unit 1.1 is to wipe it and redo it myself, writing each decision below.

## Decisions

_To fill in during unit 1.1._

- Storage: LVM-thin vs ZFS:
- Wi-Fi setup (`wpa_supplicant`, interfaces file):
- NAT bridge (`ip_forward`, masquerade rule):
- Repositories (no-subscription):
- Laptop specifics (lid, screen, power key):
