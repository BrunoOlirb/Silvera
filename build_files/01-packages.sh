#!/bin/bash

set -ouex pipefail

PKGS=(
    # Hardware support
    @hardware-support

    # Swap on ZRAM
    zram-generator-defaults

    # Audio support
    pipewire
    wireplumber

    # Graphical Interface
    gdm
    gnome-session-wayland-session
    adw-gtk3-theme
    @fonts

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

dnf5 -y swap --repo='fedora' OpenCL-ICD-Loader ocl-icd