#!/bin/bash

set -ouex pipefail

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

    # Graphical Interface
    gdm
    gnome-session-wayland-session
    adw-gtk3
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
    ghostty
    code
    chromium

    # Flatpaks
    flatpak
    gnome-software
)

dnf5 -y in --setopt="install_weak_deps=False" "${PKGS[@]}"

########## Flatpak ##########

flatpak remote-delete --all
flatpak remote-add flathub https://dl.flathub.org/repo/flathub.flatpakrepo

########## GNOME ##########

gsettings set org.gnome.desktop.peripherals.mouse middle-click-emulation true
gsettings set org.gnome.desktop.interface font-hinting 'full'

########## Systemd ##########

SYSTEMD=(
    gdm.service
    flatpak-maintenance.timer
    podman.socket
)

for UNIT in "${SYSTEMD[@]}"; do
    systemctl enable "$UNIT"
done

systemctl set-default graphical.target

########## Cleanup Repos ##########

dnf5 copr disable scottames/ghostty

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +