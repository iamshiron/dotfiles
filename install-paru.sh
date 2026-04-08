#!/bin/bash
set -e 

echo ">>> Installing base-devel and git..."
sudo pacman -S --needed base-devel git

echo ">>> Building paru from source..."
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

cd "$TEMP_DIR"
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm

echo ">>> Paru installed successfully."
