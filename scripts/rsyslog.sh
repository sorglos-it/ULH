#!/bin/bash

# rsyslog - Advanced system logging daemon
# Install, update, uninstall, and configure rsyslog on all Linux distributions

set -e

# Parse action from first parameter
ACTION="${1%%,*}"

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

# Install rsyslog
install_rsyslog() {
    log_info "Installing rsyslog..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL rsyslog || log_error "Failed"
    sudo systemctl enable rsyslog
    sudo systemctl start rsyslog
    
    log_info "rsyslog installed and started!"
}

# Update rsyslog
update_rsyslog() {
    log_info "Updating rsyslog..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL rsyslog || log_error "Failed"
    
    log_info "rsyslog updated!"
}

# Uninstall rsyslog
uninstall_rsyslog() {
    log_info "Uninstalling rsyslog..."
    detect_os
    
    sudo systemctl stop rsyslog
    sudo systemctl disable rsyslog
    sudo $PKG_UNINSTALL rsyslog || log_error "Failed"
    
    log_info "rsyslog uninstalled!"
}

# Configure rsyslog
configure_rsyslog() {
    log_info "rsyslog configuration"
    log_info "Edit /etc/rsyslog.conf and restart: sudo systemctl restart rsyslog"
}

# Route to appropriate action
case "$ACTION" in
    install)
        install_rsyslog
        ;;
    update)
        update_rsyslog
        ;;
    uninstall)
        uninstall_rsyslog
        ;;
    config)
        configure_rsyslog
        ;;
    *)
        log_error "Unknown action: $ACTION"
        ;;
esac
