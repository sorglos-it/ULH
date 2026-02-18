#!/bin/bash

# openssh - Secure Shell remote access
# Install, update, uninstall, and configure OpenSSH on all Linux distributions

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

# Install OpenSSH server
install_openssh() {
    log_info "Installing openssh-server..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL openssh-server || log_error "Failed"
    
    # Enable SSH service (handle both 'ssh' and 'sshd' service names)
    sudo systemctl enable ssh || sudo systemctl enable sshd
    
    log_info "openssh-server installed and enabled!"
}

# Update OpenSSH server
update_openssh() {
    log_info "Updating openssh-server..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL openssh-server || log_error "Failed"
    
    log_info "openssh-server updated!"
}

# Uninstall OpenSSH server
uninstall_openssh() {
    log_info "Uninstalling openssh-server..."
    detect_os
    
    # Disable SSH service (handle both 'ssh' and 'sshd' service names)
    sudo systemctl disable sshd || sudo systemctl disable ssh
    sudo $PKG_UNINSTALL openssh-server || log_error "Failed"
    
    log_info "openssh-server uninstalled!"
}

# Configure OpenSSH server
configure_openssh() {
    log_info "openssh-server configuration"
    log_info "Edit /etc/ssh/sshd_config and run: sudo systemctl restart sshd"
}

# Route to appropriate action
case "$ACTION" in
    install)
        install_openssh
        ;;
    update)
        update_openssh
        ;;
    uninstall)
        uninstall_openssh
        ;;
    config)
        configure_openssh
        ;;
    *)
        log_error "Unknown action: $ACTION"
        ;;
esac
