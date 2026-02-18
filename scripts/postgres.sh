#!/bin/bash

# postgres - PostgreSQL relational database
# Install, update, uninstall, and configure PostgreSQL for all distributions

set -e

FULL_PARAMS="$1"
ACTION="${FULL_PARAMS%%,*}"
PARAMS_REST="${FULL_PARAMS#*,}"

if [[ -n "$PARAMS_REST" && "$PARAMS_REST" != "$FULL_PARAMS" ]]; then
    while IFS='=' read -r key val; do
        [[ -n "$key" ]] && export "$key=$val"
    done <<< "${PARAMS_REST//,/$'\n'}"
fi

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

detect_os() {
    source /etc/os-release || log_error "Cannot detect OS"
    OS_DISTRO="${ID,,}"
    
    case "$OS_DISTRO" in
        ubuntu|debian|raspbian|linuxmint|pop)
            PKG_UPDATE="apt-get update"
            PKG_INSTALL="apt-get install -y"
            PKG_UNINSTALL="apt-get remove -y"
            PKG="postgresql"
            CONF_FILE="/etc/postgresql/*/main/postgresql.conf"
            SERVICE="postgresql"
            ;;
        fedora|rhel|centos|rocky|alma)
            PKG_UPDATE="dnf check-update || true"
            PKG_INSTALL="dnf install -y"
            PKG_UNINSTALL="dnf remove -y"
            PKG="postgresql-server"
            CONF_FILE="/var/lib/pgsql/data/postgresql.conf"
            SERVICE="postgresql"
            ;;
        arch|manjaro|endeavouros)
            PKG_UPDATE="pacman -Sy"
            PKG_INSTALL="pacman -S --noconfirm"
            PKG_UNINSTALL="pacman -R --noconfirm"
            PKG="postgresql"
            CONF_FILE="/var/lib/postgres/data/postgresql.conf"
            SERVICE="postgresql"
            ;;
        opensuse*|sles)
            PKG_UPDATE="zypper refresh"
            PKG_INSTALL="zypper install -y"
            PKG_UNINSTALL="zypper remove -y"
            PKG="postgresql-server"
            CONF_FILE="/var/lib/pgsql/data/postgresql.conf"
            SERVICE="postgresql"
            ;;
        alpine)
            PKG_UPDATE="apk update"
            PKG_INSTALL="apk add"
            PKG_UNINSTALL="apk del"
            PKG="postgresql"
            CONF_FILE="/var/lib/postgresql/data/postgresql.conf"
            SERVICE="postgresql"
            ;;
        *)
            log_error "Unsupported distribution: $OS_DISTRO"
            ;;
    esac
}

install_postgres() {
    log_info "Installing PostgreSQL..."
    detect_os
    
    # Update package manager
    sudo $PKG_UPDATE || true
    
    # Install PostgreSQL
    sudo $PKG_INSTALL $PKG || log_error "Failed to install PostgreSQL"
    
    # Enable and start service
    sudo systemctl enable $SERVICE
    sudo systemctl start $SERVICE
    
    log_info "PostgreSQL installed and started!"
    psql --version || true
}

update_postgres() {
    log_info "Updating PostgreSQL..."
    detect_os
    
    # Update package manager
    sudo $PKG_UPDATE || true
    
    # Update PostgreSQL
    sudo $PKG_INSTALL $PKG || log_error "Failed to update PostgreSQL"
    
    # Restart service
    sudo systemctl restart $SERVICE
    
    log_info "PostgreSQL updated!"
}

uninstall_postgres() {
    log_warn "Uninstalling PostgreSQL..."
    detect_os
    
    # Stop and disable service
    sudo systemctl stop $SERVICE || true
    sudo systemctl disable $SERVICE || true
    
    # Uninstall PostgreSQL
    sudo $PKG_UNINSTALL $PKG || log_error "Failed to uninstall PostgreSQL"
    
    # Remove data if requested
    [[ "$DELETE_DATA" == "yes" ]] && sudo rm -rf /var/lib/pgsql* || true
    [[ "$DELETE_CONFIG" == "yes" ]] && sudo rm -rf /etc/postgresql* || true
    
    log_info "PostgreSQL uninstalled!"
}

config_postgres() {
    log_info "Configuring PostgreSQL..."
    detect_os
    
    # Display connection information
    log_info "PostgreSQL Configuration:"
    log_info "Default user: postgres"
    log_info "Default port: 5432"
    log_info "Socket location: /var/run/postgresql"
    
    # Ensure service is enabled and running
    sudo systemctl enable $SERVICE
    sudo systemctl start $SERVICE
    
    log_info "PostgreSQL configured and running!"
}

case "$ACTION" in
    install)
        install_postgres
        ;;
    update)
        update_postgres
        ;;
    uninstall)
        uninstall_postgres
        ;;
    config)
        config_postgres
        ;;
    *)
        log_error "Unknown action: $ACTION"
        exit 1
        ;;
esac
