#!/bin/bash

# docker-compose - Multi-container orchestration with Docker Compose
# Install, update, uninstall, and configure Docker Compose for all Linux distributions

set -e
source "$(dirname "$0")/../lib/bootstrap.sh"
# Script entscheidet selbst wann geparst werden soll:
parse_parameters "$1"

# Check if Docker is installed (required dependency)
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first before installing Docker Compose."
    fi
    log_info "Docker found: $(docker --version)"
}

# Get the latest docker-compose version from GitHub
get_latest_version() {
    # Try to get the latest release tag from GitHub API
    local latest=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
    
    if [[ -z "$latest" ]]; then
        # Fallback to a recent stable version if API fails
        latest="2.24.0"
    fi
    
    echo "$latest"
}

# Get system architecture
get_arch() {
    case "$(uname -m)" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64)
            echo "aarch64"
            ;;
        armv7l)
            echo "armv7"
            ;;
        *)
        print_usage docker-compose && exit 1
    update)
        update_docker_compose
        ;;
    uninstall)
        uninstall_docker_compose
        ;;
    config)
        configure_docker_compose
        ;;
    *)
        print_usage docker-compose && exit 1
esac
