#!/bin/bash

set -ouex pipefail

SYSTEMD_ENABLE=(
    gdm.service
    flatpak-maintenance.timer
    podman.socket
)

### From JianZcar/fedora-gnome, might fix the sudden reboot issue and the annoying remount-fs complaint.
SYSTEMD_MASK=(
    systemd-remount-fs.service
    flatpak-add-fedora-repos.service ### Might just remove this from the image.
    bootc-fetch-apply-updates.service
    bootc-fetch-apply-updates.timer
    rpm-ostree-countme.service
    rpm-ostree-countme.timer
)

for UNIT in "${SYSTEMD_ENABLE[@]}"; do
    systemctl enable "$UNIT"
done

for UNIT in "${SYSTEMD_MASK[@]}"; do
    systemctl mask "$UNIT"
done

systemctl set-default graphical.target