#!/bin/bash

# Ensure the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root. Try: sudo $0"
    exit 1
fi

# Define the installation path
INSTALL_DIR="/home/node3"

# Ensure required packages are installed
REQUIRED_PACKAGES=(curl sudo htop screen net-tools lsof)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -l | grep -qw "$pkg"; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# Create the node3 directory if it doesn’t exist
mkdir -p "$INSTALL_DIR"

# Download and install GaiaNet into node3 directory
echo "Downloading GaiaNet installer..."
curl -o "$INSTALL_DIR/gaiainstaller.sh" https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh
chmod +x "$INSTALL_DIR/gaiainstaller.sh"

echo "Installing GaiaNet into $INSTALL_DIR..."
cd "$INSTALL_DIR"
./gaiainstaller.sh --base "$INSTALL_DIR"

# Initialize GaiaNet with the custom node3 directory
echo "Initializing GaiaNet in $INSTALL_DIR..."
"$INSTALL_DIR/bin/gaianet" init --base "$INSTALL_DIR"

# Modify the GaiaNet config to use port 8087
echo "Updating GaiaNet configuration to use port 8087..."
sed -i 's/"socket-addr": "0.0.0.0:8080"/"socket-addr": "0.0.0.0:8087"/g' "$INSTALL_DIR/config.json"

# Start the GaiaNet node
echo "Starting GaiaNet node on port 8087..."
"$INSTALL_DIR/bin/gaianet" start --base "$INSTALL_DIR"

# Confirm the node is running
echo "✅ GaiaNet node3 is now running on port 8087!"
