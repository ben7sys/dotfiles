#!/bin/bash

# Title: Podman Installation Script for AlmaLinux
# Description: Installs Podman, Python3, and Podman-compose with security measures
# Usage: ./alma_install_podman.sh
# Author: sieben

# Exit on error, undefined vars, and prevent pipe errors
set -euo pipefail

# Function to check command success
check_command() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# System aktualisieren
echo "Updating system packages..."
if [ "$(id -u)" -eq 0 ]; then
    dnf -y update
else
    sudo dnf -y update
fi
check_command "System update"

# Enable CodeReady Builder repository
echo "Enabling CodeReady Builder repository..."
if [ "$(id -u)" -eq 0 ]; then
    dnf -y config-manager --set-enabled crb
else
    sudo dnf -y config-manager --set-enabled crb
fi
check_command "Enable CodeReady Builder repository"

# Podman installieren
echo "Installing Podman..."
if [ "$(id -u)" -eq 0 ]; then
    dnf -y install podman
else
    sudo dnf -y install podman
fi
check_command "Podman installation"

# Python3, pip und venv installieren
echo "Installing Python3, pip, and venv..."
if [ "$(id -u)" -eq 0 ]; then
    dnf -y install python3 python3-pip python3-venv
else
    sudo dnf -y install python3 python3-pip python3-venv
fi
check_command "Python installation"

# Create virtual environment for podman-compose
echo "Setting up virtual environment..."
VENV_PATH="/opt/podman-compose-venv"
if [ "$(id -u)" -eq 0 ]; then
    python3 -m venv "$VENV_PATH"
    # Ensure proper permissions for the venv
    chown -R root:root "$VENV_PATH"
    chmod -R 755 "$VENV_PATH"
else
    sudo python3 -m venv "$VENV_PATH"
    sudo chown -R root:root "$VENV_PATH"
    sudo chmod -R 755 "$VENV_PATH"
fi
check_command "Virtual environment setup"

# Install podman-compose in virtual environment
echo "Installing Podman-compose in virtual environment..."
"$VENV_PATH/bin/pip" install --upgrade pip
"$VENV_PATH/bin/pip" install podman-compose
check_command "Podman-compose installation"

# Create symlink for podman-compose
if [ "$(id -u)" -eq 0 ]; then
    ln -sf "$VENV_PATH/bin/podman-compose" /usr/local/bin/podman-compose
else
    sudo ln -sf "$VENV_PATH/bin/podman-compose" /usr/local/bin/podman-compose
fi
check_command "Podman-compose symlink creation"

echo "Installation completed successfully"
echo "You can now use 'podman-compose' command directly"
