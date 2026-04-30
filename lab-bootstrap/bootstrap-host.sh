#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ $EUID -ne 0 ]]; then
    echo "must run as root" >&2
    exit 1
fi

tmp_sudoers=""
tmp_keys=""
trap 'rm -f "$tmp_sudoers" "$tmp_keys"' EXIT

username="deploy"
gh_username="Ysedda"

if id "$username" >/dev/null 2>&1; then
    echo "User exists, skipping creation."
else
    echo "User does not exist"
    useradd -m -s /bin/bash "$username"
fi

usermod -aG sudo "$username"
tmp_sudoers=$(mktemp "/etc/sudoers.d/.tmp.XXXXXX")
cat > "$tmp_sudoers" <<EOF
deploy ALL=(ALL) NOPASSWD:ALL
EOF
visudo -c -f "$tmp_sudoers"

mv "$tmp_sudoers" "/etc/sudoers.d/deploy"
chown root:root "/etc/sudoers.d/deploy"
chmod 440 "/etc/sudoers.d/deploy"

ssh_folder="/home/$username/.ssh"

mkdir -p "$ssh_folder"

tmp_keys=$(mktemp "$ssh_folder/authorized_keys.XXXXXX")

curl -fsSL "https://github.com/$gh_username.keys" -o "$tmp_keys"

if [ ! -s "$tmp_keys" ]; then
    echo "empty response from github" >&2
    exit 1
fi

if ! grep -qE '^(ssh-|ecdsa-|sk-)' "$tmp_keys"; then
    echo "response doesn't look like SSH keys" >&2
    exit 1
fi

mv "$tmp_keys" "$ssh_folder/authorized_keys"
chmod 700 "$ssh_folder"
chown -R "$username:$username" "$ssh_folder"
chmod 600 "$ssh_folder/authorized_keys"

cat > /etc/ssh/sshd_config.d/00-hardening.conf << EOF
PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
EOF

sshd -t
systemctl reload ssh
