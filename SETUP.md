# Setup Guide for Dotfiles

This repository contains dotfiles that have been sanitized for public use. Before using these dotfiles, you need to replace the placeholders with your actual values.

## Required Replacements

### 1. Network Configuration
Replace the following placeholders in your files:

- `STORAGE-IP` → Your actual NAS/Storage IP address (e.g., `192.168.1.100`)
- `STORAGE` → Your storage mount name (e.g., `syno`, `nas`, etc.)

### 2. User Information
- `USERNAME` → Your actual username
- `DOMAIN-TLD` → Your actual domain (e.g., `example.com`)
- `COMPUTERNAME` → Your computer hostname

### 3. Email Configuration
- `your-email@example.com` → Your actual email address
- `your-username` → Your actual Git username

## Files that need configuration:

### Scripts (dot_scripts/)
- `executable_syno-mount.sh`: Set environment variables at the top:
  ```bash
  export STORAGE_IP="192.168.1.100"  # Your NAS IP
  export STORAGE_NAME="syno"         # Your storage name
  ```
- `dev_ubuntu_secure_server.sh`: Replace placeholders at the top:
  ```bash
  NEW_USER="YOUR_USERNAME"           # Replace with your username
  PUBLIC_KEY="YOUR_SSH_PUBLIC_KEY"   # Replace with your SSH public key
  ```

### Configuration Files
- `dot_gitconfig`: Update user section with your email and name
- `dot_env_common`: Update GitHub username:
  ```bash
  export GITHUB_USERNAME=ben7sys  # Replace with your GitHub username
  ```
- `commands.md`: Replace placeholders in mount commands

## Environment Variables

You can set these environment variables in your shell profile to avoid hardcoding values:

```bash
export STORAGE_IP="192.168.1.100"
export STORAGE_NAME="storage"
```

## Installation

1. Clone this repository
2. Replace all placeholders with your actual values
3. Run `chezmoi init` and `chezmoi apply` as described in README.md
