# Setup Guide

This repo is sanitized for public use. Before applying, set a few values so commands and scripts work for you.

## Quick Start

1) Initialize with chezmoi

```bash
chezmoi init https://github.com/ben7sys/dotfiles.git
```

2) Set your values (choose one style)

- Use the central settings file (recommended): edit `~/.env_settings` (managed here as `dot_env_settings`).
- Environment variables in your shell: add to `~/.env_common` or export in your shell.
- Edit headers in specific scripts/files (one‑off).

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

- Env variables (preferred): avoid hardcoding.
  - Example:
    ```bash
    export STORAGE_IP="192.168.1.100"
    export STORAGE_NAME="syno"
    ```
- Edit files directly (if you prefer static values).
- Keep private/host‑specific values out of the repo:
  
  - Session‑wide env: systemd user `~/.config/environment.d/*.conf`, KDE `~/.config/plasma-workspace/env/*.sh`

## File‑by‑File Checklist

- dot_gitconfig:1
  - Set `[user] name` and `[user] email` to your identity.

- dot_env_settings:1
  - Central place to set `STORAGE_IP`, `STORAGE_NAME`, and `GITHUB_USERNAME`.
  - Loaded automatically by `dot_env_common` if present.

- dot_env_common:1
  - Kept generic; it sources `~/.env_settings` when available.

- dot_scripts/executable_syno-mount.sh:1
  - Uses `STORAGE_IP`, `STORAGE_NAME`, and your `$USER`. You can export these in your env instead of editing the file.

- dot_scripts/dev_ubuntu_secure_server.sh:1
  - Set `NEW_USER` and `PUBLIC_KEY` at the top, or pass via flags per its usage help.

- commands.md:1
  - Replace placeholders in example mount commands: `STORAGE-IP`, `STORAGE`, `USERNAME` (or rely on your env and adapt the examples).

## Cross‑Distro and Host Notes

- Works on Arch and Debian; prefer feature detection over distro checks.
 
- Desktop/session specific: optionally use `~/.env_kde` and/or systemd user env, if you need session‑wide variables beyond the shell.

## Chezmoi Basics

For chezmoi commands and workflow, see README.md.
