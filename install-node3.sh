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

# Check if lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "❌ lsof is not installed. Installing lsof..."
    sudo apt update
    sudo apt install -y lsof
else
    echo "✅ lsof is already installed."
fi

while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET NODE-3 INSTALLER Tool-Kit 🚀🚀\e[0m"
    echo "==============================================================="

    # Menu Options
    echo -e "\n\e[1mSelect an action for NODE-3:\e[0m\n"
    echo -e "1) Install Gaia-Node-3 (Non-GPU/VPS)"
    echo -e "2) Start Auto Chat With AI-Agent (Node-3)"
    echo -e "3) Stop Auto Chat (Node-3)"
    echo -e "4) Restart GaiaNet Node-3"
    echo -e "5) Stop GaiaNet Node-3"
    echo -e "6) Check GaiaNet Node-3 Status (Node ID & Device ID)"
    echo -e "7) Uninstall GaiaNet Node-3 (Danger Zone)"
    echo -e "0) Exit Installer"
    echo "==============================================================="

    read -rp "Enter your choice: " choice

    case $choice in
        1)
            echo "Installing Gaia-Node-3..."
            curl -sSfL 'https://raw.githubusercontent.com/GaiaNet-AI/gaianet-node/main/install.sh' | bash -s -- --base /root/node3
            ;;

        2)
            echo "🔴 Stopping any existing 'gaiabot-node3' screen sessions..."
            screen -ls | awk '/[0-9]+\.gaiabot-node3/ {print $1}' | xargs -r -I{} screen -X -S {} quit

            # Function to check if port 8087 is active
            check_port() {
                if sudo lsof -i :8087 > /dev/null 2>&1; then
                    echo -e "\e[1;32m✅ Port 8087 is active. GaiaNet Node-3 is running.\e[0m"
                    return 0
                else
                    return 1
                fi
            }

            # Check if GaiaNet Node-3 is installed properly
            gaianet_info=$( /root/node3/bin/gaianet info 2>/dev/null )
            if [[ -z "$gaianet_info" ]]; then
                echo -e "\e[1;31m❌ GaiaNet Node-3 is installed but not configured properly. Please reinstall.\e[0m"
                read -r -p "Press Enter to return to the main menu..."
                continue
            fi

            # Start Auto Chat if GaiaNet Node-3 is detected
            if [[ "$gaianet_info" == *"Node ID"* || "$gaianet_info" == *"Device ID"* ]]; then
                echo -e "\e[1;32m✅ GaiaNet Node-3 detected. Starting chatbot...\e[0m"

                # Start the chatbot in a detached screen session
                screen -dmS gaiabot-node3 bash -c '
                curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/gaiachat.sh && chmod +x gaiachat.sh;
                if [ -f "gaiachat.sh" ]; then
                    ./gaiachat.sh --base /root/node3
                else
                    echo "❌ Error: Failed to download gaiachat.sh"
                    sleep 10
                    exit 1
                fi'

                sleep 5
                screen -r gaiabot-node3
            fi
            ;;

        3)
            echo "🔴 Stopping Auto Chat on Node-3..."
            screen -ls | awk '/[0-9]+\.gaiabot-node3/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            echo -e "\e[32m✅ Auto Chat for Node-3 stopped.\e[0m"
            ;;

        4)
            echo "Restarting GaiaNet Node-3..."
            sudo netstat -tulnp | grep :8087
            /root/node3/bin/gaianet stop --base /root/node3
            /root/node3/bin/gaianet start --base /root/node3
            /root/node3/bin/gaianet info --base /root/node3
            ;;

        5)
            echo "Stopping GaiaNet Node-3..."
            sudo netstat -tulnp | grep :8087
            /root/node3/bin/gaianet stop --base /root/node3
            ;;

        6)
            echo "Checking GaiaNet Node-3 ID & Device ID..."
            gaianet_info=$( /root/node3/bin/gaianet info --base /root/node3 2>/dev/null)
            if [[ -n "$gaianet_info" ]]; then
                echo "$gaianet_info"
            else
                echo "❌ GaiaNet Node-3 is not installed or configured properly."
            fi
            ;;

        7)
            echo "⚠️ WARNING: This will completely remove GaiaNet Node-3 from your system!"
            read -rp "Are you sure you want to proceed? (y/n) " confirm
            if [[ "$confirm" == "y" ]]; then
                echo "🗑️ Uninstalling GaiaNet Node-3..."
                curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/uninstall.sh' | bash -s -- --base /root/node3
                source ~/.bashrc
            else
                echo "Uninstallation aborted."
            fi
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
