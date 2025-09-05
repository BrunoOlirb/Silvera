#!/bin/bash

set -ouex pipefail

dnf5 -y rm fedora-workstation-repositories rpmfusion*
dnf5 copr disable scottames/ghostty

dnf5 clean all

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' -exec rm -f {} +