# Huawei MateBook Touchscreen Fix (FocalTech FTSC1000 / Intel LPSS)

Fixes the non-functioning touchscreen on Huawei MateBook laptops (such as MateBook 14 2024 / Meteor Lake FLMH-XX) running Linux.

## Problem Description

Huawei MateBook laptops equipped with the **FocalTech FTSC1000** I2C digitizer on an Intel Serial IO LPSS controller (PCI ID `0000:00:15.1`) often fail their initial probe during boot due to I2C bus arbitration loss and uninitialized power states (`i2c_hid_acpi: failed to fetch HID descriptor: -121` or `lost arbitration`). Furthermore, the digitizer commonly loses sync after waking up from system suspend (sleep).

## Solution

This repository provides:
1. **`huawei-touchscreen-reset`**: A reset script that disables the problematic optional ambient-light sensor, keeps both the parent PCI device and the actual touchscreen I2C bus (`i2c_designware.1`) runtime-active, rebinds only the FTSC1000 display touchscreen, verifies that libinput identifies a touchscreen event node, and retries automatically if needed. It never unloads the shared I2C-HID stack or disconnects the BLTP7853 touchpad.
2. **`huawei-touchscreen-reset.service`**: A systemd unit that runs on system boot.
3. **`huawei-touchscreen-reset.sleep`**: A systemd-sleep hook in `/usr/lib/systemd/system-sleep/` that detaches only the FTSC1000 before sleep and reattaches it after a short post-resume settling delay. This avoids racing the kernel's own I2C resume path.

The ambient-light sensor (`ACPI0008:00`) is intentionally unbound because this Huawei firmware can race the touchscreen during I2C initialization. Automatic-brightness support may therefore be unavailable while the workaround is active.

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

For Niri, map the touchscreen to the built-in panel in `~/.config/niri/config.kdl`:

```kdl
input {
    touch {
        map-to-output "eDP-1"
    }
}
```
