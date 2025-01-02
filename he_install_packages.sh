#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Starting package installation..."

# Update and upgrade the system
echo "Updating and upgrading the system..."
apt update && apt upgrade -y

# Install APT packages
echo "Installing APT packages..."
apt install -y \
alien anydesk apt-transport-https automake base-passwd bf \
build-essential ca-certificates cargo cmake code curl dash diffutils \
dos2unix efibootmgr fd-find ffmpeg file findutils fonts-indic gcc gettext \
gimp git gnupg gparted grep grub-common grub-efi-amd64-bin grub-efi-amd64-signed \
grub-gfxpayload-lists grub-pc grub-pc-bin grub2-common gzip hostname hyphen-en-us \
i3 init jenkins language-pack-en language-pack-en-base \
language-pack-gnome-en language-pack-gnome-en-base libarchive-tools libcairo2-dev \
libdebconfclient0 libffi-dev libfuse2 libgif-dev libjpeg-dev libluajit-5.1-2 \
libluajit-5.1-common libluajit-5.1-dev libpango1.0-dev libpq-dev libpython3-dev \
libreoffice-help-common libreoffice-help-en-us librsvg2-dev libssl-dev libtool \
libtool-bin libvips-dev libvirt-daemon-system libvirt-dev libxcb-icccm4 \
libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xinerama0 libxrender1 \
lighttpd linux-generic-hwe-22.04 login luajit m4 make mokutil mongodb-org \
mysql-server mythes-en-us nasm ncurses-base ncurses-bin neovim net-tools \
nginx nmap nodejs npm obs-studio openjdk-11-jdk openssh-server os-prober \
pgadmin4-desktop pkg-config postgresql preload python3 python3-dev python3-lxml \
python3-pip python3-tk python3-venv python3.10-dev python3.10-venv redis-server \
remmina remmina-plugin-rdp ripgrep ruby ruby-augeas ruby-shadow shellcheck \
shim-signed snapd software-properties-common sshpass synaptic tesseract-ocr \
tigervnc-viewer tightvncserver timeshift ubuntu-desktop ubuntu-desktop-minimal \
ubuntu-minimal ubuntu-restricted-extras ubuntu-standard vim zlib1g-dev zsh

# Install Snap packages
echo "Installing Snap packages..."
snap install \
brave \
discord \
google-chrome \
slack --classic \
tableplus \
telegram-desktop \
termite \
warp-terminal

# Install external dependencies
echo "Installing Docker..."
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

echo "Installing MongoDB Compass..."
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update && apt install -y mongodb-compass

echo "Installing Jenkins..."
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt update && apt install -y jenkins

echo "Installing additional tools..."
# Brave browser
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
apt update && apt install -y brave-browser

# Slack
snap install slack --classic

# Zoom
wget https://zoom.us/client/latest/zoom_amd64.deb
apt install -y ./zoom_amd64.deb && rm ./zoom_amd64.deb

# Cleanup
echo "Cleaning up..."
apt autoremove -y && apt clean

echo "All packages installed successfully!"


