#!/bin/bash

# ufw - Uncomplicated Firewall
# Install, update, uninstall, and configure UFW on all Linux distributions

set -e

# Parse action and parameters
FULL_PARAMS="$1"
ACTION="${FULL_PARAMS%%,*}"
PARAMS_REST="${FULL_PARAMS#*,}"

# Export any additional parameters
if [[ -n "$PARAMS_REST" && "$PARAMS_REST" != "$FULL_PARAMS" ]]; then
    while IFS='=' read -r key val; do
        [[ -n "$key" ]] && export "$key=$val"
    done <<< "${PARAMS_REST//,/$'\n'}"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Log informational messages with green checkmark
log_info() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

# Log error messages with red X and exit
log_error() {
    printf "${RED}✗${NC} %s\n" "$1"
    exit 1
}

# Detect operating system and set appropriate package manager commands
detect_os() {
    source /etc/os-release || log_error "Cannot detect OS"
    
    case "${ID,,}" in
        ubuntu|debian|raspbian|linuxmint|pop)
            PKG_UPDATE="apt-get update"
            PKG_INSTALL="apt-get install -y"
            PKG_UNINSTALL="apt-get remove -y"
            ;;
        fedora|rhel|centos|rocky|alma)
            PKG_UPDATE="dnf check-update || true"
            PKG_INSTALL="dnf install -y"
            PKG_UNINSTALL="dnf remove -y"
            ;;
        arch|manjaro|endeavouros)
            PKG_UPDATE="pacman -Sy"
            PKG_INSTALL="pacman -S --noconfirm"
            PKG_UNINSTALL="pacman -R --noconfirm"
            ;;
        opensuse*|sles)
            PKG_UPDATE="zypper refresh"
            PKG_INSTALL="zypper install -y"
            PKG_UNINSTALL="zypper remove -y"
            ;;
        alpine)
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add"
            PKG_UNINSTALL="apk del"
            ;;
        *)
            log_error "Unsupported distribution"
            ;;
    esac
}

# Install UFW
install_ufw() {
    log_info "Installing ufw..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL ufw || log_error "Failed"
    
    log_info "ufw installed!"
}

# Update UFW
update_ufw() {
    log_info "Updating ufw..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL ufw || log_error "Failed"
    
    log_info "ufw updated!"
}

# Uninstall UFW
uninstall_ufw() {
    log_info "Uninstalling ufw..."
    detect_os
    
    sudo ufw disable || true
    sudo $PKG_UNINSTALL ufw || log_error "Failed"
    
    log_info "ufw uninstalled!"
}

# Configure UFW with port rules
configure_ufw() {
    log_info "ufw configuration"
    
    # Verify PORT parameter is provided
    [[ -z "$PORT" ]] && log_error "PORT not set"
    
    sudo ufw allow $PORT || log_error "Failed"
    
    log_info "Port $PORT allowed!"
}

# Enable UFW firewall
enable_ufw() {
    log_info "Enabling ufw..."
    
    sudo ufw enable || log_error "Failed"
    
    log_info "ufw enabled!"
}

# Disable UFW firewall
disable_ufw() {
    log_info "Disabling ufw..."
    
    sudo ufw disable || log_error "Failed"
    
    log_info "ufw disabled!"
}

# Route to appropriate action
case "$ACTION" in
    install)
        install_ufw
        ;;
    update)
        update_ufw
        ;;
    uninstall)
        uninstall_ufw
        ;;
    config)
        configure_ufw
        ;;
    enable)
        enable_ufw
        ;;
    disable)
        disable_ufw
        ;;
    *)
        log_error "Unknown action: $ACTION"
        ;;
esac
