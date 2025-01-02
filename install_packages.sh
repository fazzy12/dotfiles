#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

PACKAGE_FILE=".installed_packages"

if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo "Package list file ($PACKAGE_FILE) not found."
    exit 1
fi

echo "Starting package installation from $PACKAGE_FILE..."

# Update and upgrade the system
echo "Updating and upgrading the system..."
command -v apt >/dev/null 2>&1 || { echo "Error: 'apt' command not found. Exiting."; exit 1; }
apt update && apt upgrade -y

# Prepare logs
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"
SUCCESS_LOG="$LOG_DIR/success.log"
FAILURE_LOG="$LOG_DIR/failure.log"
> "$SUCCESS_LOG"
> "$FAILURE_LOG"

# Process the package file
while IFS= read -r line; do
    # Skip empty lines or comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Parse the package type and name
    PACKAGE_TYPE=$(echo "$line" | awk '{print $1}')
    PACKAGE_NAME=$(echo "$line" | awk '{print $2}')

    case "$PACKAGE_TYPE" in
        apt)
            echo "Installing APT package: $PACKAGE_NAME"
            if apt install -y "$PACKAGE_NAME"; then
                echo "$PACKAGE_TYPE $PACKAGE_NAME" >> "$SUCCESS_LOG"
            else
                echo "$PACKAGE_TYPE $PACKAGE_NAME" >> "$FAILURE_LOG"
            fi
            ;;
        snap)
            echo "Installing Snap package: $PACKAGE_NAME"
            command -v snap >/dev/null 2>&1 || { echo "Error: 'snap' command not found. Skipping."; exit 1; }
            if snap install "$PACKAGE_NAME"; then
                echo "$PACKAGE_TYPE $PACKAGE_NAME" >> "$SUCCESS_LOG"
            else
                echo "$PACKAGE_TYPE $PACKAGE_NAME" >> "$FAILURE_LOG"
            fi
            ;;
        custom)
            echo "Installing custom package: $PACKAGE_NAME"
            case "$PACKAGE_NAME" in
                docker)
                    echo "Installing Docker..."
                    apt install -y docker-ce docker-ce-cli containerd.io
                    ;;
                mongodb)
                    echo "Installing MongoDB Compass..."
                    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
                    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
                    apt update && apt install -y mongodb-compass
                    ;;
                *)
                    echo "Unknown custom package: $PACKAGE_NAME" >> "$FAILURE_LOG"
                    ;;
            esac
            ;;
        *)
            echo "Unknown package type: $PACKAGE_TYPE" >> "$FAILURE_LOG"
            ;;
    esac
done < "$PACKAGE_FILE"

echo "All packages processed. Logs available in $LOG_DIR."
echo "Success log: $SUCCESS_LOG"
echo "Failure log: $FAILURE_LOG"


