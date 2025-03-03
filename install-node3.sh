#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Fix Google Chrome GPG key issue
if ! test -f /etc/apt/trusted.gpg.d/google-chrome.asc; then
    echo "Adding Google Chrome GPG key..."
    wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc
else
    echo "Google Chrome GPG key already exists, skipping."
fi

# Update package lists
echo "Updating package list..."
apt update -q

# Install required packages only if not already installed
REQUIRED_PACKAGES=(nvtop sudo curl htop systemd fonts-noto-color-emoji)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! is_installed "$pkg"; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "$pkg is already installed, skipping."
    fi
done

# Set up the installation directory
NODE_DIR="/home/node3"
mkdir -p "$NODE_DIR"
cd "$NODE_DIR"

# Download and install GaiaNet for Node3
echo "Downloading and installing GaiaNet in $NODE_DIR..."
curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base "$NODE_DIR"

# Modify config to use port 8087
CONFIG_FILE="$NODE_DIR/gaianet-config.toml"
echo "Updating GaiaNet configuration for port 8087..."
sed -i 's/8080/8087/g' "$CONFIG_FILE"

# Initialize and start Node3
echo "Initializing GaiaNet Node3..."
$NODE_DIR/bin/gaianet init --base "$NODE_DIR"

echo "Starting GaiaNet Node3..."
$NODE_DIR/bin/gaianet start --base "$NODE_DIR"

# Display Node3 status
echo "Fetching GaiaNet Node3 status..."
$NODE_DIR/bin/gaianet info --base "$NODE_DIR"

# Auto Chat functionality
start_autochat() {
    echo "Starting Auto Chat for Node3..."
    screen -dmS gaiachat3 bash -c '
    curl -O https://raw.githubusercontent.com/Itzaestheticpride/node3/main/gaiachat.sh && chmod +x gaiachat.sh
    ./gaiachat.sh --base /home/node3'
    sleep 5
    screen -r gaiachat3
}

# Menu Options
echo "1) Start Auto Chat with AI Agent (Node3)"
echo "2) Restart GaiaNet Node3"
echo "3) Stop GaiaNet Node3"
echo "4) Check Node3 Status"
echo "5) Exit"
read -p "Choose an option: " choice

case $choice in
    1) start_autochat ;;
    2) $NODE_DIR/bin/gaianet stop --base "$NODE_DIR" && $NODE_DIR/bin/gaianet start --base "$NODE_DIR" ;;
    3) $NODE_DIR/bin/gaianet stop --base "$NODE_DIR" ;;
    4) $NODE_DIR/bin/gaianet info --base "$NODE_DIR" ;;
    5) exit 0 ;;
    *) echo "Invalid option" ;;
esac
