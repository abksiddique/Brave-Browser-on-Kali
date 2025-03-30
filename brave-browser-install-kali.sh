#!/bin/sh
# Developed by Siddique Abubakr Muntaka | PhD Candidate University of Cincinnati | Advisor: Dr. Jacques Buo Abdo
# GitHub: https://github.com/abksiddique/Brave-Browser-on-Kali/
# This script installs or launches the Brave browser on Kali Linux, addressing potential GPG key issues.

set -eu

# Function to display messages with a prefix
message() {
  echo "[Brave Installer] $1"
}

# Function to execute commands and handle errors
execute() {
  message "Executing: $1"
  if ! eval "$1"; then
    message "Error: Command '$1' failed."
    exit 1
  fi
}

# Function to check if brave-browser is installed
is_brave_installed() {
  command -v brave-browser >/dev/null 2>&1
}

main() {
  message "Starting Brave Browser installation/launch on Kali Linux..."

  if is_brave_installed; then
    message "Brave Browser is already installed. Launching..."
    brave-browser --no-sandbox
    message "Brave Browser launched."
    message "Thank you for using this script! Developed by Siddique Abubakr Muntaka."
    exit 0
  fi

  # 1. Remove Existing Key (if it exists)
  if [ -f /usr/share/keyrings/brave-browser-archive-keyring.gpg ]; then
    execute "sudo rm /usr/share/keyrings/brave-browser-archive-keyring.gpg"
  fi

  # 2. Download the Key and Import It
  execute "curl -fsS https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg"

  # 3. Add the Repository
  execute 'echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64,arm64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list'

  # 4. Update the Package List
  execute "sudo apt update"

  # 5. Check for GPG error and attempt to add the key via apt-key
  if apt-get update 2>&1 | grep -q 'NO_PUBKEY'; then
    message "GPG key error detected. Attempting to add key via apt-key..."
    execute "sudo apt-key add /usr/share/keyrings/brave-browser-archive-keyring.gpg"

    # 6. Update again after adding the key
    execute "sudo apt update"
  fi

  # 7. Install Brave Browser
  execute "sudo apt install -y brave-browser"

  message "Brave Browser installation complete! Launching..."
  brave-browser --no-sandbox
  message "Brave Browser launched."

  message "Thank you for using this script! Developed by Siddique Abubakr Muntaka."
}

main
