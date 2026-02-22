#!/bin/bash

# adguard-home - DNS ad-blocking with advanced filtering
# Install, update, uninstall, and configure AdGuard Home for all Linux distributions

set -e
source "$(dirname "$0")/../lib/bootstrap.sh"
# Script entscheidet selbst wann geparst werden soll:
parse_parameters "$1"

install_adguard() {
    log_info "Installing AdGuard Home..."
    detect_os
    
    # Install dependencies
    $PKG_UPDATE || true
    $PKG_INSTALL curl wget || true
    
    # Download and run official installer
    log_info "Downloading official AdGuard Home installer..."
    if command -v curl &> /dev/null; then
        curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v || log_error "Installation failed"
    elif command -v wget &> /dev/null; then
        wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v || log_error "Installation failed"
    else
        log_error "curl or wget required for installation"
    fi
    
    log_info "AdGuard Home installed successfully!"
    log_info "Access web interface: http://localhost:3000/"
    log_info "Default username: admin"
}

update_adguard() {
    log_info "Updating AdGuard Home..."
    detect_os
    
    # Run installer script for update
    log_info "Checking for updates..."
    if command -v curl &> /dev/null; then
        curl -s -S -L https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v || log_error "Update failed"
    elif command -v wget &> /dev/null; then
        wget --no-verbose -O - https://raw.githubusercontent.com/AdguardTeam/AdGuardHome/master/scripts/install.sh | sh -s -- -v || log_error "Update failed"
    else
        log_error "curl or wget required for update"
    fi
    
    # Restart service
    if systemctl is-active --quiet AdGuardHome; then
        systemctl restart AdGuardHome || log_error "Failed to restart AdGuard Home"
    fi
    
    log_info "AdGuard Home updated successfully!"
}

uninstall_adguard() {
    log_warn "Uninstalling AdGuard Home..."
    
    # Confirmation prompt (from CONFIRM parameter or default "no")
    CONFIRM="${CONFIRM:-no}"
    if [[ "$CONFIRM" != "yes" ]]; then
        log_info "Uninstall cancelled"
        return 0
    fi
    
    # Stop service
    if systemctl is-active --quiet AdGuardHome; then
        systemctl stop AdGuardHome || log_warn "Could not stop service"
    fi
    
    # Keep config (from KEEP_CONFIG parameter or default "yes")
    KEEP_CONFIG="${KEEP_CONFIG:-yes}"
    if [[ "$KEEP_CONFIG" != "no" ]]; then
        log_info "Configuration will be preserved"
    fi
    
    # Run official uninstall if available
    if [[ -f "/opt/AdGuardHome/AdGuardHome" ]]; then
        /opt/AdGuardHome/AdGuardHome -s uninstall || log_warn "Uninstall script had issues"
    fi
    
    log_info "AdGuard Home uninstalled successfully!"
}

configure_adguard() {
    log_info "AdGuard Home configuration"
    log_info ""
    log_info "Web Interface: http://localhost:3000/"
    log_info "API: http://localhost:3000/api/"
    log_info "Default username: admin"
    log_info ""
    
    if systemctl is-active --quiet AdGuardHome; then
        log_info "Service status: RUNNING"
    else
        log_info "Service status: STOPPED"
    fi
    
    log_info ""
    log_info "To access AdGuard Home:"
    log_info "  1. Open http://localhost:3000/ in your browser"
    log_info "  2. Complete initial setup wizard"
    log_info "  3. Set as DNS server (usually on router or client)"
    log_info ""
}

case "$ACTION" in
    install)
        install_adguard
        ;;
    update)
        update_adguard
        ;;
    uninstall)
        uninstall_adguard
        ;;
    config)
        configure_adguard
        ;;
    *)
        print_usage adguard-home && exit 1
esac
