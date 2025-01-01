#!/bin/bash

# Variables
DOTFILE="$HOME/.installed_packages"
REPO_DIR="$HOME/monitored_installs"
GITHUB_REMOTE="https://github.com/fazzy12/dotfiles.git"
BRANCH="main"

# Function to initialize the Git repository if not already done
initialize_repo() {
    if [[ ! -d $REPO_DIR ]]; then
        echo "Initializing Git repository..."
        mkdir -p "$REPO_DIR"
        cd "$REPO_DIR" || exit
        git init
        touch "$DOTFILE"
        git add "$DOTFILE"
        git commit -m "Initial commit: Added .installed_packages"
        git branch -M "$BRANCH"
        git remote add origin "$GITHUB_REMOTE"
        git push -u origin "$BRANCH"
    fi
}

# Function to log new installations manually
log_manual_installation() {
    echo "Please enter the name of the package, app, or file you installed:"
    read -r package_name
    if ! grep -Fxq "$package_name" "$DOTFILE"; then
        echo "$package_name" >> "$DOTFILE"
        sort -u -o "$DOTFILE" "$DOTFILE"
        echo "Logged: $package_name"
        push_to_github
    else
        echo "Package already logged."
    fi
}

# Function to monitor and log package installations
monitor_installations() {
    echo "Monitoring package installations..."

    while true; do
        # Detect new APT packages
        INSTALLED=$(comm -13 <(sort "$DOTFILE" 2>/dev/null || echo "") <(dpkg --get-selections | awk '{print $1}' | sort))
        if [[ -n "$INSTALLED" ]]; then
            echo "New APT packages detected: $INSTALLED"
            echo "$INSTALLED" >> "$DOTFILE"
            sort -u -o "$DOTFILE" "$DOTFILE"
            push_to_github
        fi

        # Detect new files in /usr/local/bin (example directory for manual installs)
        NEW_FILES=$(find /usr/local/bin -type f -newer "$DOTFILE")
        if [[ -n "$NEW_FILES" ]]; then
            echo "New manually installed binaries detected:"
            echo "$NEW_FILES"
            echo "$NEW_FILES" >> "$DOTFILE"
            sort -u -o "$DOTFILE" "$DOTFILE"
            push_to_github
        fi

        sleep 10
    done
}

# Function to push updates to GitHub
push_to_github() {
    echo "Pushing changes to GitHub..."
    cd "$REPO_DIR" || exit
    cp "$DOTFILE" "$REPO_DIR"
    git add "$DOTFILE"
    git commit -m "Update: Added new installed packages or files"
    git push
}

# Main Menu
initialize_repo
echo "Script initialized."
echo "Choose an option:"
echo "1) Monitor installations automatically"
echo "2) Log installation manually"
echo "3) Exit"

while true; do
    read -rp "Enter your choice (1/2/3): " choice
    case $choice in
        1)
            monitor_installations
            ;;
        2)
            log_manual_installation
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done

