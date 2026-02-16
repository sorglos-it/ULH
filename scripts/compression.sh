#!/bin/bash

# Compression Tools Script
# Installs zip and unzip on all platforms

set -e

FULL_PARAMS="$1"
ACTION="${FULL_PARAMS%%,*}"
PARAMS_REST="${FULL_PARAMS#*,}"

if [[ -n "$PARAMS_REST" && "$PARAMS_REST" != "$FULL_PARAMS" ]]; then
    while IFS='=' read -r key val; do
        [[ -n "$key" ]] && export "$key=$val"
    done <<< "${PARAMS_REST//,/$'\n'}"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

log_warn() {
    printf "${YELLOW}⚠${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}✗${NC} %s\n" "$1"
    exit 1
}

detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v yum &>/dev/null; then
        echo "yum"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v apk &>/dev/null; then
        echo "apk"
    else
        log_error "Could not detect package manager"
    fi
}

install_package() {
    local pkg="$1"
    local pm=$(detect_package_manager)
    
    case "$pm" in
        apt)
            sudo apt-get update >/dev/null 2>&1
            sudo apt-get install -y "$pkg" || log_error "Failed to install $pkg with apt"
            ;;
        dnf)
            sudo dnf install -y "$pkg" || log_error "Failed to install $pkg with dnf"
            ;;
        yum)
            sudo yum install -y "$pkg" || log_error "Failed to install $pkg with yum"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg" || log_error "Failed to install $pkg with pacman"
            ;;
        zypper)
            sudo zypper install -y "$pkg" || log_error "Failed to install $pkg with zypper"
            ;;
        apk)
            sudo apk add "$pkg" || log_error "Failed to install $pkg with apk"
            ;;
        *)
            log_error "Unknown package manager: $pm"
            ;;
    esac
}

case "$ACTION" in
    zip)
        log_info "Installing zip..."
        if command -v zip &>/dev/null; then
            log_warn "zip is already installed"
        else
            install_package "zip"
            log_info "zip installed successfully!"
        fi
        ;;
    
    unzip)
        log_info "Installing unzip..."
        if command -v unzip &>/dev/null; then
            log_warn "unzip is already installed"
        else
            install_package "unzip"
            log_info "unzip installed successfully!"
        fi
        ;;
    
    both)
        log_info "Installing zip and unzip..."
        
        if ! command -v zip &>/dev/null; then
            install_package "zip"
            log_info "zip installed"
        else
            log_warn "zip is already installed"
        fi
        
        if ! command -v unzip &>/dev/null; then
            install_package "unzip"
            log_info "unzip installed"
        else
            log_warn "unzip is already installed"
        fi
        
        log_info "zip and unzip are ready to use!"
        ;;
    
    *)
        log_error "Unknown action: $ACTION"
        echo "Usage:"
        echo "  compression.sh zip      (install zip)"
        echo "  compression.sh unzip    (install unzip)"
        echo "  compression.sh both     (install both)"
        exit 1
        ;;
esac
