#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "==> Disabling and stopping systemd service..."
systemctl disable --now huawei-touchscreen-reset.service 2>/dev/null || true

echo "==> Removing installed files..."
rm -f /etc/systemd/system/huawei-touchscreen-reset.service
rm -f /usr/local/sbin/huawei-touchscreen-reset
rm -f /usr/lib/systemd/system-sleep/huawei-touchscreen-reset

echo "==> Restoring the ambient-light sensor when available..."
als_driver=/sys/bus/acpi/drivers/acpi_als
if [ -w "$als_driver/bind" ] && [ ! -e "$als_driver/ACPI0008:00" ]; then
    printf '%s' ACPI0008:00 > "$als_driver/bind" || true
fi

echo "==> Reloading systemd daemon..."
systemctl daemon-reload

echo "==> Uninstallation complete!"
