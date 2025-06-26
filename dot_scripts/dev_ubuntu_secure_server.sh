#!/bin/bash
# ubuntu_quick_secure_server.sh
# Script to secure an Ubuntu system with firewall, SSH, and Fail2Ban configuration
# Includes user creation and public key setup

# === Configuration Variables ===
SSH_PORT=2222  # Custom SSH Port, ensure it is within the valid range
LOG_FILE="/var/log/security_setup.log"
FIREWALL_SERVICES=("http" "https") # SSH will be added automatically
FAIL2BAN_CONFIG_FILE="/etc/fail2ban/jail.local"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"
SSH_CUSTOM_CONFIG="/etc/ssh/sshd_config.d/99-custom.conf"

# New configuration variables - REPLACE WITH YOUR VALUES
NEW_USER="YOUR_USERNAME"
PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY"

# === Basic Setup & Error Handling ===
set -euo pipefail

# Show usage information
show_usage() {
    cat << EOF
Usage: sudo bash $0 -u USERNAME -k "SSH_PUBLIC_KEY"

Options:
    -u USERNAME       Username for the new admin user
    -k SSH_PUBLIC_KEY The SSH public key to add (in quotes)
    -h               Show this help message

Example:
    sudo bash $0 -u johndoe -k "ssh-rsa AAAA... user@host"

This script will:
1. Create a new user with sudo privileges
2. Configure SSH with key-based authentication
3. Set up UFW firewall
4. Install and configure Fail2Ban
5. Disable root login and password authentication
6. Set custom SSH port (${SSH_PORT})

Currently Preconfigured inside the script:
USERNAME:  $NEW_USER
PUBLICKEY: $PUBLIC_KEY

EOF
}

# Parse command line arguments
while getopts "u:k:h" opt; do
    case ${opt} in
        u )
            NEW_USER=$OPTARG
            ;;
        k )
            PUBLIC_KEY=$OPTARG
            ;;
        h )
            show_usage
            exit 0
            ;;
        \? )
            show_usage
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$NEW_USER" || -z "$PUBLIC_KEY" ]]; then
    echo "Error: Missing required parameters."
    show_usage
    exit 1
fi

# Ensure only root can execute this script
if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] This script must be run as root"
    exit 1
fi

# Show configuration summary and ask for confirmation
echo "=== Configuration Summary ==="
echo "New User: $NEW_USER"
echo "SSH Port: $SSH_PORT"
echo "Public Key: ${PUBLIC_KEY:0:40}..."
echo "Firewall Services: ${FIREWALL_SERVICES[*]}"
echo
echo "This script will secure your Ubuntu server with these settings."
read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Setup logging
exec 3>&1 1>>"${LOG_FILE}" 2>&1

# Log Function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&3
}

# Error Handling
trap 'log "[ERROR] An unexpected error occurred. Exiting."; rollback' ERR
trap 'log "[INFO] Script interrupted. Rollback initiated."; rollback' INT TERM

log "[INFO] Starting security configuration..."

# === System Packages ===
install_security_packages() {
    log "[INFO] Updating system packages..."
    apt update || { log "[ERROR] System update failed"; exit 1; }
    apt upgrade -y || { log "[ERROR] System upgrade failed"; exit 1; }
    log "[INFO] Installing security packages (fail2ban, ufw, openssh-server)..."
    apt install -y fail2ban ufw openssh-server || { log "[ERROR] Security package installation failed"; exit 1; }
    log "[INFO] Security packages installed successfully."
}

# === User Setup ===
setup_user() {
    log "[INFO] Setting up user ${NEW_USER}..."
    # Generate a random password
    TEMP_PASSWORD=$(openssl rand -base64 12)
    
    # Check if user exists
    if id "$NEW_USER" >/dev/null 2>&1; then
        log "[INFO] User ${NEW_USER} already exists. Updating configuration..."
    else
        log "[INFO] Creating new user ${NEW_USER}..."
        useradd -m -s /bin/bash "$NEW_USER" || { log "[ERROR] User creation failed"; exit 1; }
    fi

    # Set/update password
    echo "${NEW_USER}:${TEMP_PASSWORD}" | chpasswd || { log "[ERROR] Setting password failed"; exit 1; }
    
    # Ensure user is in sudo group
    if ! groups "$NEW_USER" | grep -q "\bsudo\b"; then
        usermod -aG sudo "$NEW_USER" || { log "[ERROR] Adding user to sudo group failed"; exit 1; }
    fi
    
    log "[INFO] Setting up SSH key for ${NEW_USER}..."
    # Create .ssh directory if it doesn't exist
    USER_HOME=$(eval echo ~${NEW_USER})
    mkdir -p "${USER_HOME}/.ssh"
    echo "$PUBLIC_KEY" > "${USER_HOME}/.ssh/authorized_keys"
    chmod 700 "${USER_HOME}/.ssh"
    chmod 600 "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${NEW_USER}:${NEW_USER}" "${USER_HOME}/.ssh"
    
    log "[INFO] User setup completed successfully."
    log "[INFO] Temporary password for ${NEW_USER}: ${TEMP_PASSWORD}"
    log "[INFO] Please change this password upon first login!"
}

# === Firewall Configuration ===
configure_firewall() {
    log "[INFO] Configuring UFW..."
    ufw default deny incoming
    ufw default allow outgoing
    
    # Ensure SSH port is valid
    if [[ $SSH_PORT -lt 1024 || $SSH_PORT -gt 65535 ]]; then
        log "[ERROR] Invalid SSH port: ${SSH_PORT}. Port must be between 1024 and 65535."
        exit 1
    fi

    ufw allow "$SSH_PORT/tcp" comment 'SSH'
    for service in "${FIREWALL_SERVICES[@]}"; do
        ufw allow "$service" || { log "[WARN] Failed to add $service to the firewall."; }
    done
    
    ufw --force enable
    log "[INFO] Firewall configured. SSH allowed on port ${SSH_PORT}, HTTP/HTTPS open."
}

# === SSH Hardening ===
harden_ssh() {
    log "[INFO] Hardening SSH configuration..."
    
    # Create backup of original sshd_config
    cp -f "$SSH_CONFIG_FILE" "${SSH_CONFIG_FILE}.bak" || { log "[ERROR] Backup of SSH configuration failed"; exit 1; }
    
    # Create privilege separation directory
    if [ ! -d "/run/sshd" ]; then
        mkdir -p /run/sshd
        chmod 0755 /run/sshd
    fi
    
    # Create minimal sshd_config that only enables key authentication
    cat > "$SSH_CONFIG_FILE" << EOF
# Minimal sshd_config with key authentication enabled
Include /etc/ssh/sshd_config.d/*.conf
PubkeyAuthentication yes
PasswordAuthentication no
EOF

    # Create custom SSH configuration
    mkdir -p /etc/ssh/sshd_config.d/
    cat > "$SSH_CUSTOM_CONFIG" << EOF
# Custom SSH configuration
Port ${SSH_PORT}
Protocol 2

# Authentication
PermitRootLogin no
ChallengeResponseAuthentication no
UsePAM yes

# Security
X11Forwarding no
UseDNS no
PermitEmptyPasswords no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2

# Logging
SyslogFacility AUTH
LogLevel INFO

# Allow only specific users
AllowUsers ${NEW_USER}
EOF

    # Set proper permissions
    chmod 600 "$SSH_CONFIG_FILE" "$SSH_CUSTOM_CONFIG"
    
    # Test the configuration
    if ! sshd -t; then
        log "[ERROR] SSH configuration syntax error"
        rollback
        exit 1
    fi

    systemctl restart sshd || { log "[ERROR] Failed to restart SSH"; rollback; exit 1; }
    log "[INFO] SSH is now running on port ${SSH_PORT} with key-based authentication only."
}

# === Fail2Ban Setup ===
setup_fail2ban() {
    log "[INFO] Configuring Fail2Ban..."
    mkdir -p "$(dirname "$FAIL2BAN_CONFIG_FILE")"
    
    cat > "$FAIL2BAN_CONFIG_FILE" << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ${SSH_PORT}
logpath = %(sshd_log)s
maxretry = 3
EOF

    log "[INFO] Fail2Ban configuration complete. Starting Fail2Ban..."
    systemctl enable fail2ban || { log "[ERROR] Failed to enable Fail2Ban"; exit 1; }
    systemctl restart fail2ban || { log "[ERROR] Failed to restart Fail2Ban"; exit 1; }
    log "[INFO] Fail2Ban is now monitoring SSH port ${SSH_PORT}."
}

# === Validation & Safety Checks ===
verify_services() {
    log "[INFO] Verifying service status..."
    systemctl is-active --quiet ufw && log "[INFO] UFW is active." || log "[ERROR] UFW is inactive."
    systemctl is-active --quiet sshd && log "[INFO] SSHD is active on port ${SSH_PORT}." || log "[ERROR] SSHD is inactive."
    systemctl is-active --quiet fail2ban && log "[INFO] Fail2Ban is active and monitoring SSH." || log "[ERROR] Fail2Ban is inactive."
}

validate_ports() {
    log "[INFO] Checking port accessibility..."
    if nc -zv 127.0.0.1 "$SSH_PORT" &>/dev/null; then
        log "[INFO] SSH is accessible on port ${SSH_PORT}."
    else
        log "[ERROR] SSH port ${SSH_PORT} is not accessible. Check firewall settings."
    fi
}

# === Rollback on Failure ===
rollback() {
    log "[INFO] Rollback in progress..."
    if [ -f "${SSH_CONFIG_FILE}.bak" ]; then
        mv "${SSH_CONFIG_FILE}.bak" "$SSH_CONFIG_FILE"
        rm -f "$SSH_CUSTOM_CONFIG"
        systemctl restart sshd
    fi
    if [ -f "${FAIL2BAN_CONFIG_FILE}.bak" ]; then
        mv "${FAIL2BAN_CONFIG_FILE}.bak" "$FAIL2BAN_CONFIG_FILE"
        systemctl restart fail2ban
    fi
    log "[INFO] Rollback complete. Exiting script."
}

# === Execution ===
install_security_packages
setup_user
configure_firewall
harden_ssh
setup_fail2ban
verify_services
validate_ports

log "[INFO] Security configuration completed successfully."
log "=== SECURITY CONFIGURATION SUMMARY ==="
log "New User: ${NEW_USER} (with sudo privileges)"
log "SSH Port: ${SSH_PORT} (Modified)"
log "Root Login: Disabled"
log "Password Auth: Disabled"
log "Firewall: Configured with UFW"
log "Fail2Ban: Active on port ${SSH_PORT}"
log "Public Key: Installed for ${NEW_USER}"
log "SSH Config: Split into minimal sshd_config and custom config in sshd_config.d/"
