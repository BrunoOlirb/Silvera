#!/bin/bash

set -ouex pipefail

### It's present in all other images by people who know much better than me, so i'm adding it here

# make root's home
mkdir -p /var/roothome

########## DNF ##########

echo 'fastestmirror=1' | tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf

dnf5 -y in dnf5-plugins

dnf config-manager setopt fedora-cisco-openh264.enabled=1

dnf5 -y in distribution-gpg-keys && \
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora) && \
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora) && \
dnf5 -y --setopt=localpkg_gpgcheck=1 in https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

dnf5 copr enable scottames/ghostty -y

########## PACKAGES ##########


PKGS=(
    # Hardware support
    @hardware-support

    # Swap on ZRAM
    zram-generator-defaults

    # Graphical Interface
    gdm
    gnome-session-wayland-session
    adw-gtk3-theme
    @fonts

    # Audio support
    pipewire
    wireplumber

    # Multimedia, hardware acceleration and codecs
    ffmpeg
    libva-intel-driver
    @multimedia

    # Needed for homebrew, git and some more
    @development-tools 
    
    # CLI tools
    distrobox 
    micro

    # Graphical tools
    nautilus
    gnome-tweaks
    ghostty
    code
    chromium

    # Flatpaks
    flatpak
    gnome-software
)

dnf5 -y in --setopt="install_weak_deps=False" "${PKGS[@]}"

### From ublue main:

# mitigate upstream packaging bug: https://bugzilla.redhat.com/show_bug.cgi?id=2332429
# swap the incorrectly installed OpenCL-ICD-Loader for ocl-icd, the expected package
dnf5 -y swap --repo='fedora' \
    OpenCL-ICD-Loader ocl-icd

########## Flatpak ##########

flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

########## Systemd ##########

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

########## Cleanup Repos ##########

dnf5 copr disable scottames/ghostty

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +