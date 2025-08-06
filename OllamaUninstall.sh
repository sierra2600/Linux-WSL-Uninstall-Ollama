#!/bin/sh
# This script uninstalls Ollama on Linux.
# It detects the current CPU architecture, operating system and uninstalls the inappropriate verson of Ollama.

set -eu

# defining colors for text
red="$( (/usr/bin/tput bold || :; /usr/bin/tput setaf 1 || :) 2>&-)"
plain="$( (/usr/bin/tput sgr0 || :) 2>&-)"

# defining text levels of urgency
status() { echo -e ">>> $*" >&2; }
error() { echo -e "${red}ERROR:${plain} $*"; exit 1; }
warning() { echo -e "${red}WARNING:${plain} $*"; }

status "Checking compatibility with your CPU\n    architecture"
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

status "Checking compatibility with your\n    operating system"
[ "$(uname -s)" = "Linux" ] || error 'This script is intended to run on Linux only.'

# Is this Microshaft Windblows
IS_WSL2=false

KERN=$(uname -r)
case "$KERN" in
    *icrosoft*WSL2 | *icrosoft*wsl2) IS_WSL2=true;;
    *icrosoft) error "Microsoft WSL1 is not currently supported. Please use WSL2 with 'wsl --set-version <distro> 2'... and stop using Microshaft products! You're being ripped off and stalked and that info is being sold under your nose!" ;;
    *) ;;
esac

status "Checking if we're running this\n    script as the root user"
SUDO=
if [ "$(id -u)" -ne 0 ]; then
    # Running as root, no need for sudo
    if ! available sudo; then
        error "This script requires superuser\npermissions. Please re-run as root."
    fi

    SUDO="sudo"
fi

status "Notice: ollama may have installed\nthese programs but they're usually\nalready part of your install:\ncurl, awk, grep, sed, tee, xargs, lspci,\nkernel-headers-*, kernel-devel-* and\nnVidia drivers including CUDA"

status "Stopping the ollama service"
$SUDO systemctl stop ollama || true

status "Disabling the ollama service"
$SUDO systemctl disable ollama || true

status "Removing the ollama service"
$SUDO rm /etc/systemd/system/ollama.service || true

status "Removing ollama from all the common\n    install locations"
$SUDO rm $(which ollama) || true

status "Removing the ollama Models"
$SUDO rm -r /usr/share/ollama || true

status "Removing the ollama user"
$SUDO userdel ollama || true

status "Removing the ollama user group"
$SUDO groupdel ollama || true

status "Ollama has been removed from your\nsystem, aside from SYMLINKs for any GPU\ndrivers, we won't tamper with those.\nHave a nice day! 'Thank you!'"
