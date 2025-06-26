#!/bin/bash
# alma_quick_secure_server.sh
# Script to secure an AlmaLinux system with firewall, SSH, and Fail2Ban configuration
# Usage: chmod +x alma_quick_secure_server.sh && ./alma_quick_secure_server.sh

# === Configuration Variables ===
SSH_PORT=2222  # Custom SSH Port, ensure it is within the valid range
LOG_FILE="/var/log/security_setup.log"
FIREWALL_SERVICES=("http" "https") # SSH will be added automatically
FAIL2BAN_CONFIG_FILE="/etc/fail2ban/jail.local"
SSH_CONFIG_FILE="/etc/ssh/sshd_config"

# === Basic Setup & Error Handling ===
set -euo pipefail  # Strict error handling
exec 3>&1 1>>"${LOG_FILE}" 2>&1  # Log all output

# Ensure only root can execute this script
if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] This script must be run as root" >&3
    exit 1
fi

# Log Function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&3
}

# Error Handling
trap 'log "[ERROR] An unexpected error occurred. Exiting."; rollback' ERR
trap 'log "[INFO] Script interrupted. Rollback initiated."; rollback' INT TERM

log "[INFO] Starting security configuration..."

# === System Packages & Repositories ===
install_epel() {
    if ! rpm -q epel-release &>/dev/null; then
        log "[INFO] Installing EPEL repository..."
        dnf install -y epel-release || { log "[ERROR] EPEL installation failed"; exit 1; }
        log "[INFO] EPEL repository installed."
    else
        log "[INFO] EPEL repository is already installed."
    fi
}

install_security_packages() {
    log "[INFO] Updating system packages..."
    dnf update -y || { log "[ERROR] System update failed"; exit 1; }
    log "[INFO] Installing security packages (fail2ban, firewalld)..."
    dnf install -y fail2ban firewalld || { log "[ERROR] Security package installation failed"; exit 1; }
    log "[INFO] Security packages installed successfully."
}

# === Firewall Configuration ===
configure_firewall() {
    log "[INFO] Configuring firewalld..."
    systemctl enable --now firewalld || { log "[ERROR] Failed to start firewalld"; exit 1; }

    # Ensure SSH port is valid before applying it to the firewall
    if [[ $SSH_PORT -lt 1024 || $SSH_PORT -gt 65535 ]]; then
        log "[ERROR] Invalid SSH port: ${SSH_PORT}. Port must be between 1024 and 65535."
        exit 1
    fi

    firewall-cmd --zone=public --permanent --add-port=${SSH_PORT}/tcp
    for service in "${FIREWALL_SERVICES[@]}"; do
        firewall-cmd --zone=public --permanent --add-service="$service" || { log "[WARN] Failed to add $service to the firewall."; }
    done
    firewall-cmd --zone=public --permanent --remove-service=ssh
    firewall-cmd --reload || { log "[ERROR] Firewall reload failed"; exit 1; }
    log "[INFO] Firewall configured. SSH allowed on port ${SSH_PORT}, HTTP/HTTPS open."
}

# === SSH Hardening ===
harden_ssh() {
    log "[INFO] Hardening SSH configuration..."
    cp "$SSH_CONFIG_FILE" "${SSH_CONFIG_FILE}.bak" || { log "[ERROR] Backup of SSH configuration failed"; exit 1; }
    
    sed -i "s/^#Port .*/Port ${SSH_PORT}/" "$SSH_CONFIG_FILE"
    sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' "$SSH_CONFIG_FILE"
    sed -i 's/^#PasswordAuthentication .*/PasswordAuthentication no/' "$SSH_CONFIG_FILE"
    sed -i 's/^#ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/' "$SSH_CONFIG_FILE"
    sed -i 's/^#X11Forwarding .*/X11Forwarding no/' "$SSH_CONFIG_FILE"
    sed -i 's/^#UseDNS .*/UseDNS no/' "$SSH_CONFIG_FILE"
    sed -i 's/^#Protocol .*/Protocol 2/' "$SSH_CONFIG_FILE"

    log "[INFO] SSH configuration hardened. Verifying..."
    sshd -t || { log "[ERROR] SSH configuration syntax error"; rollback; exit 1; }
    systemctl restart sshd || { log "[ERROR] Failed to restart SSH"; rollback; exit 1; }
    log "[INFO] SSH is now running on port ${SSH_PORT} with key-based authentication only."
}

# === Fail2Ban Setup ===
setup_fail2ban() {
    log "[INFO] Configuring Fail2Ban..."
    cp "$FAIL2BAN_CONFIG_FILE" "${FAIL2BAN_CONFIG_FILE}.bak" || true

    cat <<EOF >"$FAIL2BAN_CONFIG_FILE"
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ${SSH_PORT}
logpath = %(sshd_log)s
EOF
    log "[INFO] Fail2Ban configuration complete. Starting Fail2Ban..."
    systemctl enable --now fail2ban || { log "[ERROR] Fail2Ban start failed"; rollback; exit 1; }
    fail2ban-client status sshd
    log "[INFO] Fail2Ban is now monitoring SSH port ${SSH_PORT}."
}

# === Validation & Safety Checks ===
verify_services() {
    log "[INFO] Verifying service status..."
    systemctl is-active --quiet firewalld && log "[INFO] Firewalld is active." || log "[ERROR] Firewalld is inactive."
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
    [ -f "${SSH_CONFIG_FILE}.bak" ] && mv "${SSH_CONFIG_FILE}.bak" "$SSH_CONFIG_FILE" && systemctl restart sshd || log "[WARN] Failed to restore SSH config backup."
    [ -f "${FAIL2BAN_CONFIG_FILE}.bak" ] && mv "${FAIL2BAN_CONFIG_FILE}.bak" "$FAIL2BAN_CONFIG_FILE" && systemctl restart fail2ban || log "[WARN] Failed to restore Fail2Ban config backup."
    log "[INFO] Rollback complete. Exiting script."
}

# === Execution ===
install_epel
install_security_packages
configure_firewall
harden_ssh
setup_fail2ban
verify_services
validate_ports

log "[INFO] Security configuration completed successfully."
log "=== SECURITY CONFIGURATION SUMMARY ==="
log "SSH Port: ${SSH_PORT} (Modified)"
log "Root Login: Disabled"
log "Password Auth: Disabled"
log "Firewall: Configured"
log "Fail2Ban: Active on port ${SSH_PORT}"
