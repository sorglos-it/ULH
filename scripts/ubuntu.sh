#!/bin/bash

# ubuntu - Ubuntu system management
# Update system packages and manage Ubuntu Pro subscription

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

# Verify this is running on Ubuntu
detect_os() {
    source /etc/os-release || log_error "Cannot detect OS"
    [[ "${ID,,}" == "ubuntu" ]] || log_error "This script is for Ubuntu only"
}

# Update system packages
update_ubuntu() {
    log_info "Updating Ubuntu..."
    detect_os
    
    sudo apt-get update || true
    sudo apt-get upgrade -y || log_error "Failed"
    sudo apt-get autoremove -y || true
    
    log_info "Ubuntu updated!"
}

# Attach Ubuntu Pro subscription
attach_pro() {
    log_info "Attaching Ubuntu Pro..."
    
    # Verify Pro key is provided
    [[ -z "$KEY" ]] && log_error "Pro key not set"
    
    sudo pro attach "$KEY" || log_error "Failed"
    
    log_info "Ubuntu Pro attached!"
}

# Detach Ubuntu Pro subscription
detach_pro() {
    log_info "Detaching Ubuntu Pro..."
    detect_os
    
    sudo pro detach --assume-yes || log_error "Failed"
    
    log_info "Ubuntu Pro detached!"
}

# Route to appropriate action
case "$ACTION" in
    update)
        update_ubuntu
        ;;
    pro)
        attach_pro
        ;;
    detach)
        detach_pro
        ;;
    *)
        log_error "Unknown action: $ACTION"
        ;;
esac
