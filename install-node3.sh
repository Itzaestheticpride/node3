#!/bin/bash

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is not installed. Installing sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo is already installed."
fi

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "❌ screen is not installed. Installing screen..."
    sudo apt update
    sudo apt install -y screen
else
    echo "✅ screen is already installed."
fi

# Check if net-tools is installed
if ! command -v ifconfig &> /dev/null; then
    echo "❌ net-tools is not installed. Installing net-tools..."
    sudo apt install -y net-tools
else
    echo "✅ net-tools is already installed."
fi

# Check if lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "❌ lsof is not installed. Installing lsof..."
    sudo apt update
    sudo apt install -y lsof
    sudo apt upgrade -y
else
    echo "✅ lsof is already installed."
fi

# Create node3 directory if not exists
NODE_DIR="/home/node3"
mkdir -p "$NODE_DIR"

# Set GaiaNet base directory to /home/node3
export GAIANET_BASE="$NODE_DIR"

while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET NODE3 INSTALLER 🚀🚀\e[0m"
    echo "==============================================================="
    
    echo -e "\e[1mSelect an action:\e[0m\n"
    echo -e "1) Install Gaia-Node in $NODE_DIR"
    echo -e "2) Start Gaia-Node"
    echo -e "3) Stop Gaia-Node"
    echo -e "4) Start Auto Chat With AI-Agent"
    echo -e "5) Stop Auto Chatting"
    echo -e "6) Restart GaiaNet Node"
    echo -e "7) Check Node ID & Device ID"
    echo -e "8) Uninstall GaiaNet Node"
    echo -e "0) Exit"
    echo "==============================================================="
    read -rp "Enter your choice: " choice

    case $choice in
        1)
            echo "Installing Gaia-Node in $NODE_DIR..."
            curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base "$NODE_DIR"
            sed -i 's/8080/8087/g' "$NODE_DIR/gaianet/config.toml"
            ;;

        2)
            echo "Starting GaiaNet Node..."
            "$NODE_DIR/bin/gaianet" start --base "$NODE_DIR"
            ;;

        3)
            echo "Stopping GaiaNet Node..."
            "$NODE_DIR/bin/gaianet" stop --base "$NODE_DIR"
            ;;

        4)
            echo "Starting Auto Chat..."
            screen -dmS gaiachat bash -c "cd $NODE_DIR && ./gaiachat.sh"
            ;;

        5)
            echo "Stopping Auto Chat..."
            screen -X -S gaiachat quit
            ;;

        6)
            echo "Restarting GaiaNet Node..."
            "$NODE_DIR/bin/gaianet" stop --base "$NODE_DIR"
            sleep 5
            "$NODE_DIR/bin/gaianet" start --base "$NODE_DIR"
            ;;

        7)
            echo "Checking Node ID & Device ID..."
            "$NODE_DIR/bin/gaianet" info --base "$NODE_DIR"
            ;;

        8)
            echo "Uninstalling GaiaNet Node..."
            rm -rf "$NODE_DIR"
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -rp "Press Enter to return to the main menu..."
done
