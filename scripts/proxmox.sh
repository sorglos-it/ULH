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
        print_usage proxmox && exit 1
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
        print_usage proxmox && exit 1
esac
