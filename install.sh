#! /bin/bash
sudo dnf install $(echo $(cat ./install-packages.txt))
current=`$(pwd)`
cd $HOME/.config/

sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org

FONTS_DIR="$(dirname "$0")/configs/quickshell/fonts"
mkdir -p "$FONTS_DIR"
curl -fLo "$FONTS_DIR/MaterialIcons-Regular.ttf" \
  "https://github.com/google/material-design-icons/raw/master/font/MaterialIcons-Regular.ttf"

mkdir -p "$HOME/.local/bin"
(cd ./cli && go build -o "$HOME/.local/bin/qs-sysmon" .)
