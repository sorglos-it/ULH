#!/bin/bash

# proxmox - Guest agent and container management for Proxmox hosts
# Manages qemu-guest-agent (for guests) and VM/LXC container operations

set -e
source "$(dirname "$0")/../lib/bootstrap.sh"
# Script entscheidet selbst wann geparst werden soll:
parse_parameters "$1"

# Install qemu-guest-agent
install_guest_agent() {
    log_info "Installing qemu-guest-agent..."
    
    detect_distro
    
    case "${OS_ID}" in
        debian | ubuntu)
            apt-get update -qq
            apt-get install -y qemu-guest-agent
            ;;
        rhel | centos | rocky | fedora | alma)
            dnf install -y qemu-guest-agent
            ;;
        arch | manjaro)
            pacman -S --noconfirm qemu-guest-agent
            ;;
        suse | opensuse | opensuse-leap | opensuse-tumbleweed)
            zypper install -y qemu-guest-agent
            ;;
        alpine)
            apk add --no-cache qemu-guest-agent
            ;;
        *)
            log_error "Unsupported distribution: ${OS_ID}"
            ;;
    esac
    
    # Start and enable service
    log_info "Starting and enabling qemu-guest-agent service..."
    systemctl start qemu-guest-agent
    systemctl enable qemu-guest-agent
    
    log_info "qemu-guest-agent installed successfully"
}

# Update qemu-guest-agent
update_guest_agent() {
    log_info "Updating qemu-guest-agent..."
    
    detect_distro
    
    case "${OS_ID}" in
        debian | ubuntu)
            apt-get update -qq
            apt-get upgrade -y qemu-guest-agent
            ;;
        rhel | centos | rocky | fedora | alma)
            dnf upgrade -y qemu-guest-agent
            ;;
        arch | manjaro)
            pacman -Syu --noconfirm qemu-guest-agent
            ;;
        suse | opensuse | opensuse-leap | opensuse-tumbleweed)
            zypper update -y qemu-guest-agent
            ;;
        alpine)
            apk upgrade qemu-guest-agent
            ;;
        *)
            log_error "Unsupported distribution: ${OS_ID}"
            ;;
    esac
    
    # Restart service
    log_info "Restarting qemu-guest-agent service..."
    systemctl restart qemu-guest-agent
    
    log_info "qemu-guest-agent updated successfully"
}

# Uninstall qemu-guest-agent
uninstall_guest_agent() {
    log_warn "This will remove qemu-guest-agent from this guest VM."
    CONFIRM="${CONFIRM:-no}"
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Uninstall cancelled"
        return 0
    fi
    
    log_info "Uninstalling qemu-guest-agent..."
    
    detect_distro
    
    # Stop and disable service
    log_info "Stopping and disabling qemu-guest-agent service..."
    systemctl stop qemu-guest-agent || true
    systemctl disable qemu-guest-agent || true
    
    case "${OS_ID}" in
        debian | ubuntu)
            apt-get remove -y qemu-guest-agent
            apt-get autoremove -y
            ;;
        rhel | centos | rocky | fedora | alma)
            dnf remove -y qemu-guest-agent
            ;;
        arch | manjaro)
            pacman -R --noconfirm qemu-guest-agent
            ;;
        suse | opensuse | opensuse-leap | opensuse-tumbleweed)
            zypper remove -y qemu-guest-agent
            ;;
        alpine)
            apk del qemu-guest-agent
            ;;
        *)
            log_error "Unsupported distribution: ${OS_ID}"
            ;;
    esac
    
    log_info "qemu-guest-agent uninstalled successfully"
}

# Check if running on Proxmox host (has pct and qm commands)
check_proxmox_host() {
    if ! command -v pct &> /dev/null || ! command -v qm &> /dev/null; then
        log_error "This script must run on a Proxmox VE host (pct/qm commands not found)"
    fi
}

# Convert LXC container to template
make_lxc_to_template() {
    check_proxmox_host
    
    CTID="${CTID:-}"
    
    if [[ -z "$CTID" ]]; then
        log_error "Container ID cannot be empty"
    fi
    
    log_info "Converting LXC container $CTID to template..."
    
    if pct set "$CTID" -template 1; then
        log_info "Container $CTID is now a template"
    else
        log_error "Failed to convert container $CTID to template"
    fi
}

# Convert template LXC container back to normal
make_template_to_lxc() {
    check_proxmox_host
    
    CTID="${CTID:-}"
    
    if [[ -z "$CTID" ]]; then
        log_error "Container ID cannot be empty"
    fi
    
    log_info "Converting template $CTID back to normal container..."
    
    if pct set "$CTID" -template 0; then
        log_info "Container $CTID is now a normal container"
    else
        log_error "Failed to convert container $CTID back to normal"
    fi
}

# Unlock a locked VM/container
unlock_vm() {
    check_proxmox_host
    
    CTID="${CTID:-}"
    
    if [[ -z "$CTID" ]]; then
        log_error "Container/VM ID cannot be empty"
    fi
    
    log_info "Unlocking container/VM $CTID..."
    
    if pct unlock "$CTID"; then
        log_info "Container/VM $CTID is now unlocked"
    else
        log_error "Failed to unlock container/VM $CTID"
    fi
}

# Stop all VMs and LXC containers
stop_all_containers() {
    check_proxmox_host
    
    log_info "Stopping all VMs and LXC containers..."
    
    # Stop all QEMU VMs
    log_info "Stopping all QEMU VMs..."
    for vmid in $(qm list | awk 'NR>1 {print $1}'); do
        if [[ -n "$vmid" ]]; then
            log_info "Stopping VM $vmid..."
            qm stop "$vmid" || log_warn "Failed to stop VM $vmid"
        fi
    done
    
    # Stop all LXC containers
    log_info "Stopping all LXC containers..."
    for ctid in $(pct list | awk 'NR>1 {print $1}'); do
        if [[ -n "$ctid" ]]; then
            log_info "Stopping container $ctid..."
            pct stop "$ctid" || log_warn "Failed to stop container $ctid"
        fi
    done
    
    log_info "Stop-all operation completed"
}

# List all LXC containers (running and offline)
list_all_lxc() {
    check_proxmox_host
    
    log_info "Listing all LXC containers..."
    printf "%-8s %-20s %-20s %-10s\n" "VMID" "Hostname" "IP" "Status"
    echo "============================================================"
    for id in $(pct list | awk 'NR>1 {print $1}'); do
        name=$(pct config "$id" | grep hostname | awk '{print $2}')
        ip=$(pct config "$id" | grep -oP 'ip=\K[^,]+' | head -1)
        status=$(pct status "$id" | awk '{print $2}')
        printf "%-8s %-20s %-20s %-10s\n" "$id" "$name" "$ip" "$status"
    done
    echo "============================================================"
}

# List only running LXC containers with live IP
list_running_lxc() {
    check_proxmox_host
    
    log_info "Listing running LXC containers..."
    printf "%-8s %-20s %-20s\n" "VMID" "Hostname" "IP"
    echo "-------------------------------------------"
    for id in $(pct list | grep running | awk '{print $1}'); do
        name=$(pct config "$id" | grep hostname | awk '{print $2}')
        ip=$(pct exec "$id" -- ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        printf "%-8s %-20s %-20s\n" "$id" "$name" "$ip"
    done
    echo "-------------------------------------------"
}

# Start a specific VM by VMID
start_vm() {
    check_proxmox_host
    
    VMID="${VMID:-}"
    
    if [[ -z "$VMID" ]]; then
        log_error "VM ID cannot be empty"
    fi
    
    log_info "Starting VM $VMID..."
    
    if qm start "$VMID"; then
        log_info "VM $VMID started successfully"
    else
        log_error "Failed to start VM $VMID"
    fi
}

# Stop a specific VM by VMID
stop_vm() {
    check_proxmox_host
    
    VMID="${VMID:-}"
    
    if [[ -z "$VMID" ]]; then
        log_error "VM ID cannot be empty"
    fi
    
    log_info "Stopping VM $VMID..."
    
    if qm stop "$VMID"; then
        log_info "VM $VMID stopped successfully"
    else
        log_error "Failed to stop VM $VMID"
    fi
}

# Start a specific LXC container by CTID
start_lxc() {
    check_proxmox_host
    
    CTID="${CTID:-}"
    
    if [[ -z "$CTID" ]]; then
        log_error "Container ID cannot be empty"
    fi
    
    log_info "Starting LXC container $CTID..."
    
    if pct start "$CTID"; then
        log_info "LXC container $CTID started successfully"
    else
        log_error "Failed to start LXC container $CTID"
    fi
}

# Stop a specific LXC container by CTID
stop_lxc() {
    check_proxmox_host
    
    CTID="${CTID:-}"
    
    if [[ -z "$CTID" ]]; then
        log_error "Container ID cannot be empty"
    fi
    
    log_info "Stopping LXC container $CTID..."
    
    if pct stop "$CTID"; then
        log_info "LXC container $CTID stopped successfully"
    else
        log_error "Failed to stop LXC container $CTID"
    fi
}

# Route to appropriate action
case "$ACTION" in
    install)
        install_guest_agent
        ;;
    update)
        update_guest_agent
        ;;
    uninstall)
        uninstall_guest_agent
        ;;
    make-lxc-to-template)
        make_lxc_to_template
        ;;
    make-template-to-lxc)
        make_template_to_lxc
        ;;
    unlock-vm)
        unlock_vm
        ;;
    stop-all)
        stop_all_containers
        ;;
    list-lxc)
        list_all_lxc
        ;;
    list-lxc-running)
        list_running_lxc
        ;;
    start-vm)
        start_vm
        ;;
    stop-vm)
        stop_vm
        ;;
    start-lxc)
        start_lxc
        ;;
    stop-lxc)
        stop_lxc
        ;;
    *)
        log_error "Unknown action: $ACTION"
        ;;
esac
