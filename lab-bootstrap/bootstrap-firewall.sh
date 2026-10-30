#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ $EUID -ne 0 ]]; then
    echo "must run as root" >&2
    exit 1
fi

# nftables, default-deny inbound, allow port 22.

if [ -f /etc/nftables.conf ]; then
    cp /etc/nftables.conf /etc/nftables.conf.bak."$(date +%s)"
fi

cat > /etc/nftables.conf <<EOF
flush ruleset
table inet filter {
    chain input {
        type filter hook input priority filter; policy drop
        iif lo accept
        ct state established,related counter accept
        tcp dport 22 counter accept
    }

    chain output {
        type filter hook output priority filter; policy accept
        ct state invalid drop
    }
}
EOF

nft -c -f /etc/nftables.conf

systemctl restart nftables.service
systemctl enable nftables.service
