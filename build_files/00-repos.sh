#!/bin/bash

set -ouex pipefail

# Make root's home (it's in all other images, so i'm adding it here)
mkdir -p /var/roothome

# Speed dnf up
echo 'fastestmirror=1' | tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf

# Packages needed to setup repos
dnf5 -y in dnf5-plugins fedora-workstation-repositories distribution-gpg-keys

# RPMFusion
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-free-fedora-$(rpm -E %fedora) && \
rpmkeys --import /usr/share/distribution-gpg-keys/rpmfusion/RPM-GPG-KEY-rpmfusion-nonfree-fedora-$(rpm -E %fedora) && \
dnf5 -y --setopt=localpkg_gpgcheck=1 in https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                                        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/vscode.repo > /dev/null

# Enabled for chrome and RPMFusion respectively
dnf config-manager setopt google-chrome.enabled=1
dnf config-manager setopt fedora-cisco-openh264.enabled=1

# COPR
COPRS=(
    trixieua/morewaita-icon-theme
    scottames/ghostty
)

dnf5 copr enable "$COPRS" -y