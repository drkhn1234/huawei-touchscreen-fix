#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing huawei-touchscreen-reset executable..."
install -m 0755 "${SCRIPT_DIR}/huawei-touchscreen-reset" /usr/local/sbin/huawei-touchscreen-reset

echo "==> Installing systemd service..."
install -m 0644 "${SCRIPT_DIR}/huawei-touchscreen-reset.service" /etc/systemd/system/huawei-touchscreen-reset.service

echo "==> Installing system-sleep resume hook..."
install -m 0755 "${SCRIPT_DIR}/huawei-touchscreen-reset.sleep" /usr/lib/systemd/system-sleep/huawei-touchscreen-reset

echo "==> Reloading systemd and enabling service..."
systemctl daemon-reload
systemctl enable --now huawei-touchscreen-reset.service

echo "==> Installation complete!"
