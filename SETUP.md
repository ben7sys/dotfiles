# Setup Guide

This repo is sanitized for public use. Before applying, set a few values so commands and scripts work for you.

## Quick Start

1) Initialize with chezmoi

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
```

2) Set your values (simple & central)

- Use one central file: edit `~/.env_common` and keep your variables there.
- Alternatively export ad‑hoc in the shell or edit the top of specific scripts.

3) Dry‑run, then apply

```bash
chezmoi -vn apply   # preview
chezmoi -v apply    # apply
```

4) Verify

- `git config --global user.name` shows your name
- `echo "$STORAGE_IP" "$STORAGE_NAME"` show values (if you use env vars)
- Run relevant script(s), e.g. `syno-mount` alias or `dot_scripts/executable_syno-mount.sh`

## What You Must Customize

- Identity: Git user name and email.
- Storage: NAS IP and storage name used by mount helpers.
- Optional script inputs: values used by provisioning scripts.

## Where To Set Values

- Central env file (preferred): `~/.env_common` — loaded for Bash and POSIX shells.
  - Example:
    ```bash
    export STORAGE_IP="192.168.1.100"
    export STORAGE_NAME="syno"
    ```
- Edit files directly (if you prefer static values).
- Keep secrets out of the repo:
  
  - Session‑wide env: systemd user `~/.config/environment.d/*.conf`, KDE `~/.config/plasma-workspace/env/*.sh`

## File‑by‑File Checklist

- dot_gitconfig:1
  - Set `[user] name` and `[user] email` to your identity.

- dot_profile:1
  - Loads `~/.env_common` and `~/.exports`, sets locale/PATH, and (for Bash) sources `~/.bashrc`.

- dot_bash_profile:1
  - Sources `~/.profile` (preferred) or falls back to `~/.bashrc` for login shells.

- dot_env_common:1
  - Central place for environment. Defines PATH additions, LANG/LC_ALL, SSH_AUTH_SOCK.
  - Add your values like `STORAGE_IP`, `STORAGE_NAME`, `GITHUB_USERNAME` here.

- dot_scripts/executable_syno-mount.sh:1
  - Uses `STORAGE_IP`, `STORAGE_NAME`, and your `$USER`. You can export these in your env instead of editing the file.

- dot_scripts/dev_ubuntu_secure_server.sh:1
  - Set `NEW_USER` and `PUBLIC_KEY` at the top, or pass via flags per its usage help.

- commands.md:1
  - Replace placeholders in example mount commands: `STORAGE-IP`, `STORAGE`, `USERNAME` (or rely on your env and adapt the examples).

## Cross‑Distro and Host Notes

- Works on Arch and Debian; prefer feature detection over distro checks.
 
- Desktop/session specific: optionally use `~/.env_kde` and/or systemd user env, if you need session‑wide variables beyond the shell.

## Shell Startup Order (Bash)

- Login Bash: `~/.bash_profile` → `~/.profile` → `~/.bashrc`
- Interactive non‑login Bash: `~/.bashrc`
- POSIX sh/dash: `~/.profile`

## Chezmoi Basics

For chezmoi commands and workflow, see README.md.
