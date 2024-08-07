#!/bin/bash

# install_packages.sh: Install packages from YAML config for multiple package managers

## Enable debug mode if needed
# set -x

## Enable strict mode
set -eo pipefail

# Source the config file
#source "$(dirname "$0")/scripts/config.sh"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Ensure the script is in the coreect location
ensure_correct_location() {
    local current_dir=$(pwd)

    if [[ "$current_dir" != "$DOTFILES_DIR" ]]; then
        log_message "Error: This script must be run from the correct dotfiles directory: $DOTFILES_DIR" "red"
        log_message "Current location: $current_dir" "yellow"
        log_message "You have four options:" "cyan"
        
        echo ""
        log_message "1. Clone the repository to the correct location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$DOTFILES_DIR\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "2. (Optional) Delete the existing one:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   rm -rf \"$current_dir\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "3. Update 'DOTFILES_DIR' in config.sh to match your current location:" "cyan"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   sed -i 's|^DOTFILES_DIR=.*|DOTFILES_DIR=\"$current_dir\"|' \"$SCRIPT_DIR/config.sh\""
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "Recommended: Clone to the correct location, delete the existing one, and navigate to it:" "green"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo "   git clone $repository_url \"$DOTFILES_DIR\" && rm -rf \"$current_dir\" && cd \"$DOTFILES_DIR\" && pwd && ls"
        echo "   ──────────────────────────────────────────────────────────────────────────────"
        echo ""
        
        log_message "After taking one of these actions, navigate to $DOTFILES_DIR and re-run this script." "green"
        exit 1
    fi
}

# Function to log messages
log_message() {
    local message="$1"
    local color="${2:-normal}"
    local level="${3:-INFO}"
    color_text "$color" "[$level] $message"
    echo "$(date): [$level] $message" >> "dotfiles_setup.log"
}

# Function for color formatting
color_text() {
  local color_code=""
  case $1 in
    green) color_code="\e[32m";;
    yellow) color_code="\e[33m";;
    red) color_code="\e[31m";;
    blue) color_code="\e[34m";;
    cyan) color_code="\e[36m";;
    magenta) color_code="\e[35m";;
    *) color_code="";;
  esac
  echo -e "${color_code}$2\e[0m"
}

# Function to check system requirements
check_requirements() {
    log_message "Checking system requirements..." "yellow"
    local required_commands=(git stow jq python)
    local missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done

    if [ ${#missing_commands[@]} -ne 0 ]; then
        log_message "The following required commands are missing: ${missing_commands[*]}" "red"
        log_message "Installing missing packages..." "yellow"
        sudo pacman -S --needed --noconfirm "${missing_commands[@]}"
    fi

    # Check for PyYAML
    if ! python -c "import yaml" &> /dev/null; then
        log_message "PyYAML is not installed. Installing..." "yellow"
        sudo pacman -S --needed --noconfirm python-yaml
    fi

    log_message "All system requirements are met." "green"
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if not running as root
check_not_root() {
    if [ "$EUID" -ne 0 ]; then
        return 0
    else
        log_message "This script should not be run as root" "red"
        return 1
    fi
}

# Main function to orchestrate the setup
main() {
    log_message "Checking requirements for $os..." "yellow"
    
    #ensure_correct_location
    check_not_root
    check_requirements
    
    log_message "Asking the user to backup the existing dotfiles" "yellow"
    # ask the user to backup existing dotfiles before proceeding
    if ! ask_question "Do you want to backup your existing dotfiles?"; then
        log_message "Skipping backup of existing dotfiles..." "yellow"
    else
        backup_dotfiles
        log_message "Your original dotfiles have been backed up to $dotfiles_backup_dir" "cyan"
    fi
        
    # Run Timeshift setup
    log_message "Starting $DOTFILES_DIR/scripts/ultimate_system.sh" "yellow"
    "$DOTFILES_DIR/scripts/setup.sh"
}

# Run the main function if the script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi