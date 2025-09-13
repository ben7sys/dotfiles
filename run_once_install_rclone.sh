#!/usr/bin/env bash
set -Eeuo pipefail

# Opt-in installation to avoid chezmoi apply blocking/non-interactive failures
if [[ "${RCLONE_AUTO_INSTALL:-0}" != "1" ]]; then
  printf '[rclone-setup] Skipping install (set RCLONE_AUTO_INSTALL=1 to enable)\n' >&2
  exit 0
fi

# Optional: pin an exact version, e.g. 1.66.0
# export RCLONE_VERSION=""

# Optional: minimum acceptable version (skip if already >=)
# export RCLONE_MIN_VERSION=""

# Optional: installation method preference: auto|pkg|official
# export RCLONE_INSTALL_METHOD="auto"

log() { printf '[rclone-setup] %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# Return true if version $1 >= version $2
ver_ge() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" = "$1" ]; }

get_installed_version() {
  if have rclone; then
    local v
    v="$(rclone version 2>/dev/null | head -n1 | awk '{print $2}')" || return 1
    v="${v#v}"
    printf '%s' "$v"
  fi
}

detect_pkgmgr() {
  if have apt-get; then echo apt
  elif have dnf; then echo dnf
  elif have yum; then echo yum
  elif have pacman; then echo pacman
  elif have zypper; then echo zypper
  elif have apk; then echo apk
  elif [[ "$(uname -s)" == "Darwin" ]] && have brew; then echo brew
  else echo none
  fi
}

install_with_pkg() {
  local mgr="$1"
  case "$mgr" in
    apt) sudo apt-get update && sudo apt-get install -y rclone ;;
    dnf) sudo dnf install -y rclone ;;
    yum) sudo yum install -y epel-release || true; sudo yum install -y rclone ;;
    pacman) sudo pacman -Syu --noconfirm rclone ;;
    zypper) sudo zypper -n refresh && sudo zypper -n install rclone ;;
    apk) sudo apk add --no-cache rclone ;;
    brew) brew update && (brew install rclone || brew upgrade rclone) ;;
    *) return 1 ;;
  esac
}

install_with_official() {
  local ver="${1:-}"
  local fetch=
  if have curl; then
    fetch="curl -fsSL https://rclone.org/install.sh"
  elif have wget; then
    fetch="wget -qO- https://rclone.org/install.sh"
  else
    log "Please install curl or wget first."
    return 1
  fi
  if [[ -n "$ver" ]]; then
    log "Installing rclone ${ver} using the official script."
    sudo bash -s -- "v${ver}" <<<"$($fetch)"
  else
    log "Installing rclone (latest) using the official script."
    sudo bash -s <<<"$($fetch)"
  fi
}

main() {
  local desired="${RCLONE_VERSION:-}"
  local min="${RCLONE_MIN_VERSION:-}"
  local method="${RCLONE_INSTALL_METHOD:-auto}"

  local installed; installed="$(get_installed_version || true)"
  if [[ -n "$installed" ]]; then
    log "Found rclone v${installed}"
  else
    log "rclone not found."
  fi

  if [[ -n "$desired" ]]; then
    # Exact version requested
    if [[ -n "$installed" ]] && ver_ge "$installed" "$desired"; then
      log "Satisfied: installed version >= desired (${desired})."
      exit 0
    fi
    local mgr; mgr="$(detect_pkgmgr)"
    if [[ "$mgr" == "brew" ]]; then
      # Homebrew rarely pins exact versions. Use official installer for pinning.
      install_with_official "$desired"
    elif [[ "$method" == "pkg" ]]; then
      install_with_pkg "$mgr" || install_with_official "$desired"
    else
      install_with_official "$desired"
    fi
  else
    # No exact version requested
    if [[ -n "$installed" ]] && { [[ -z "$min" ]] || ver_ge "$installed" "$min"; }; then
      log "No action needed."
      exit 0
    fi
    local mgr; mgr="$(detect_pkgmgr)"
    if [[ "$method" == "official" || "$mgr" == "none" ]]; then
      install_with_official ""
    else
      install_with_pkg "$mgr" || install_with_official ""
    fi
  fi

  local after; after="$(get_installed_version || true)"
  if [[ -z "$after" ]]; then
    log "Installation failed."
    exit 1
  fi
  log "Installed rclone v${after}"
}
main "$@"
