#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

tmp_conf=""
trap 'rm -f "$tmp_conf"' EXIT

if [[ $EUID -ne 0 ]]; then
    echo "must run as root" >&2
    exit 1
fi

apt-get install -y fail2ban

tmp_conf=$(mktemp "/tmp/sshd.local.tmp.XXXXXX")

cat > "$tmp_conf" <<EOF
[sshd]
enabled = true
EOF

mv "$tmp_conf" /etc/fail2ban/jail.d/sshd.local

if ! fail2ban-client -t; then
    rm -f /etc/fail2ban/jail.d/sshd.local
    echo "Invalid fail2ban config file" >&2
    exit 1
fi

systemctl enable --now fail2ban
systemctl reload fail2ban
