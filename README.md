# Huawei MateBook Touchscreen Fix (FocalTech FTSC1000 / Intel LPSS)

Fixes the non-functioning touchscreen on Huawei MateBook laptops (such as MateBook 14 2024 / Meteor Lake FLMH-XX) running Linux.

## Problem Description

Huawei MateBook laptops equipped with the **FocalTech FTSC1000** I2C digitizer on an Intel Serial IO LPSS controller (PCI ID `0000:00:15.1`) often fail their initial probe during boot due to I2C bus arbitration loss and uninitialized power states (`i2c_hid_acpi: failed to fetch HID descriptor: -121` or `lost arbitration`). Furthermore, the digitizer commonly loses sync after waking up from system suspend (sleep).

## Solution

This repository provides:
1. **`huawei-touchscreen-reset`**: A reset script that safely unbinds and rebinds the dedicated Intel LPSS I2C controller (`0000:00:15.1`) without interfering with the touchpad controller (`0000:00:15.0`), verifies successful I2C input attachment, and retries automatically if needed.
2. **`huawei-touchscreen-reset.service`**: A systemd unit that runs on system boot.
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

Verify the input device in libinput or evtest:
```bash
sudo libinput list-devices | grep -A 8 "FTSC1000"
```
