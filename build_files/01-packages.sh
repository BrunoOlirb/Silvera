#!/bin/bash

set -ouex pipefail

# For chrome and other packages that may install to /opt
ln -s /var/opt /opt

PKGS=(
    # Hardware support
    @hardware-support

    # Swap on ZRAM
    zram-generator-defaults

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
    ddcutil

    # Graphical Interface
    gdm
    gnome-session-wayland-session
    @fonts

    # Themes and extension
    adw-gtk3-theme
    gnome-shell-theme-yaru
    yaru-icon-theme
    gnome-shell-extension-user-theme
    gnome-shell-extension-dash-to-dock
    
    # Graphical tools
    nautilus
    gnome-tweaks
    ghostty
    code
    emacs
    chromium
    google-chrome-stable

    # Flatpaks
    flatpak
    gnome-software
)

dnf5 -y in --setopt="install_weak_deps=False" "${PKGS[@]}"

### From ublue main:
# mitigate upstream packaging bug: https://bugzilla.redhat.com/show_bug.cgi?id=2332429
# swap the incorrectly installed OpenCL-ICD-Loader for ocl-icd, the expected package

dnf5 -y swap --repo='fedora' OpenCL-ICD-Loader ocl-icd