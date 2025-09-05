#!/bin/bash

set -ouex pipefail

SYSTEMD_ENABLE=(
    gdm.service
    flatpak-maintenance.timer
    bootc-upgrade.timer
    podman.socket
)

### From JianZcar/fedora-gnome, might fix the sudden reboot issue and the annoying remount-fs complaint.
SYSTEMD_MASK=(
    systemd-remount-fs.service                      # Was compalining about failure
    flatpak-add-fedora-repos.service                ## Might just remove this from the image.
    bootc-fetch-apply-updates.service               ### These two cause
    bootc-fetch-apply-updates.timer                 ### automatic reboot
)

for UNIT in "${SYSTEMD_ENABLE[@]}"; do
    systemctl enable "$UNIT"
done

for UNIT in "${SYSTEMD_MASK[@]}"; do
    systemctl mask "$UNIT"
done

systemctl set-default graphical.target