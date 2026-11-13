# Huawei MateBook Touchscreen Fix (FocalTech FTSC1000 / Intel LPSS)

Fixes the non-functioning touchscreen on Huawei MateBook laptops (such as MateBook 14 2024 / Meteor Lake FLMH-XX) running Linux.

## Problem Description

Huawei MateBook laptops equipped with the **FocalTech FTSC1000** I2C digitizer on an Intel Serial IO LPSS controller (PCI ID `0000:00:15.1`) often fail their initial probe during boot or after waking up from system suspend (sleep) due to I2C bus arbitration loss and desynchronized HID handshake states (`i2c_hid_acpi: failed to fetch HID descriptor: -121`, `device returned incorrect report`, or `lost arbitration`).

## Solution

This repository provides:
1. **`huawei-touchscreen-reset`**: A reset script that keeps the controller awake, safely rebinds the dedicated Intel LPSS I2C controller (`0000:00:15.1`) without touching the touchpad controller (`0000:00:15.0`), validates probe health by checking dmesg timestamps for I2C arbitration loss or device errors, and includes multi-tier hardware escalation (PCI rescan and module fallback).
2. **`huawei-touchscreen-reset.service`**: A systemd unit that runs on system boot after `display-manager.service` and `graphical.target` to ensure the display power rails and backlight have settled.
3. **`huawei-touchscreen-reset.sleep`**: A systemd-sleep hook in `/usr/lib/systemd/system-sleep/` that automatically reinitializes the digitizer when resuming from sleep or hibernation.

## Installation

```bash
git clone https://github.com/drkhn1234/huawei-touchscreen-fix.git
cd huawei-touchscreen-fix
chmod +x install.sh
sudo ./install.sh
```

## Uninstallation

```bash
sudo ./uninstall.sh
```

## Verification

Check the status of the service:
```bash
systemctl status huawei-touchscreen-reset.service
```

Verify the input device in libinput:
```bash
sudo libinput list-devices | grep -A 8 "FTSC1000"
```
