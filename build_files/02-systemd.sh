#!/bin/bash

set -ouex pipefail

SYSTEMD_ENABLE=(
    gdm.service
    flatpak-maintenance.timer
    bootc-upgrade.timer
    podman.socket
)

SYSTEMD_DISABLE=(
    flatpak-add-fedora-repos.service
    bootc-fetch-apply-updates.service
    bootc-fetch-apply-updates.timer
)

for UNIT in "${SYSTEMD_ENABLE[@]}"; do
    systemctl enable "$UNIT"
done

systemctl set-default graphical.target

for UNIT in "${SYSTEMD_DISABLE[@]}"; do
    systemctl disable "$UNIT"
    rm /usr/lib/systemd/system/"$UNIT"
done

# "Fixes" it compalining about failure
systemctl mask systemd-remount-fs.service
