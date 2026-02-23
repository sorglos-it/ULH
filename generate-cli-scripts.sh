#!/bin/bash
# Generate scripts from app_cli.txt

set -e

SCRIPTS_DIR="/root/workspace/ulh/scripts"
APPS_FILE="/root/workspace/app_cli.txt"

# Kategorisierung
categorize() {
    local app="$1"
    case "$app" in
        # Development
        CMake|Git\ LFS|OpenJDK|Rust|Bun|Deno|Helix|LazyGit) echo "Development Tools" ;;
        # Shells
        Fish|Zsh|Oh\ My\ Zsh) echo "Shells" ;;
        # Editors
        Vim|Neovim|Emacs|Micro) echo "Text Editors" ;;
        # System
        Firejail|GameMode|Starship|Superfile|Zellij) echo "System Tools" ;;
        # Backup
        BorgBackup|Restic) echo "Backup Tools" ;;
        # Container
        Flatpak|Podman|Vagrant) echo "Container Tools" ;;
        # Monitor/Find
        btop|eza|fd|fzf|ncdu|fastfetch|ripgrep|yazi) echo "System Tools" ;;
        # Package Manager
        npm|pnpm|yarn|uv) echo "Package Managers" ;;
        # Network/Server
        Nmap|ImHex) echo "System Tools" ;;
        # Misc
        *) echo "Development Tools" ;;
    esac
}

# Package name per distro
get_pkg_name() {
    local app="$1"
    local pkg_name="${app,,}"  # Lowercase
    pkg_name="${pkg_name// /-}"  # Spaces to dashes
    
    case "$app" in
        "Git LFS") echo "git-lfs" ;;
        "Oh My Zsh") echo "zsh" ;;  # Installed via curl
        "OpenJDK") echo "openjdk-bin" ;;
        *) echo "$pkg_name" ;;
    esac
}

# Create script
create_script() {
    local app="$1"
    local script_name="${app,,}"
    script_name="${script_name// /-}"
    script_file="${SCRIPTS_DIR}/${script_name}.sh"
    local pkg=$(get_pkg_name "$app")
    
    cat > "$script_file" << 'SCRIPT_EOF'
#!/bin/bash

set -e

FULL_PARAMS="$1"
ACTION="${FULL_PARAMS%%,*}"
PARAMS_REST="${FULL_PARAMS#*,}"

if [[ -n "$PARAMS_REST" && "$PARAMS_REST" != "$FULL_PARAMS" ]]; then
    while IFS='=' read -r key val; do
        [[ -n "$key" ]] && export "$key=$val"
    done <<< "${PARAMS_REST//,/$'\n'}"
fi

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/colors.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" && pwd)/bootstrap.sh"

detect_os() {
    source /etc/os-release 2>/dev/null || { msg_err "Cannot detect OS"; exit 1; }
    OS_DISTRO="${ID,,}"
    
    case "$OS_DISTRO" in
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
        arch|archarm|manjaro|endeavouros)
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
            msg_err "Unsupported distribution: $OS_DISTRO"
            exit 1
            ;;
    esac
}

install_pkg() {
    msg_info "Installing PKG_PLACEHOLDER..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL PKG_PLACEHOLDER || { msg_err "Installation failed"; exit 1; }
    
    msg_ok "PKG_PLACEHOLDER installed successfully!"
}

update_pkg() {
    msg_info "Updating PKG_PLACEHOLDER..."
    detect_os
    
    sudo $PKG_UPDATE || true
    sudo $PKG_INSTALL PKG_PLACEHOLDER || { msg_err "Update failed"; exit 1; }
    
    msg_ok "PKG_PLACEHOLDER updated successfully!"
}

uninstall_pkg() {
    msg_info "Uninstalling PKG_PLACEHOLDER..."
    detect_os
    
    sudo $PKG_UNINSTALL PKG_PLACEHOLDER || { msg_err "Uninstallation failed"; exit 1; }
    
    msg_ok "PKG_PLACEHOLDER uninstalled successfully!"
}

case "$ACTION" in
    install) install_pkg ;;
    update) update_pkg ;;
    uninstall) uninstall_pkg ;;
    *) msg_err "Unknown action: $ACTION"; exit 1 ;;
esac
SCRIPT_EOF

    chmod +x "$script_file"
    
    # Replace placeholders
    sed -i "s/PKG_PLACEHOLDER/$pkg/g" "$script_file"
    sed -i "s/APP_PLACEHOLDER/$app/g" "$script_file"
    
    echo "$script_name"
}

echo "Generating scripts from app_cli.txt..."
echo ""

while IFS=',' read -r app rest; do
    app=$(echo "$app" | xargs)  # Trim whitespace
    [[ -z "$app" ]] && continue
    
    script_name=$(create_script "$app")
    echo "✓ Created: $script_name"
done < "$APPS_FILE"

echo ""
echo "Done! Run: cd /root/workspace/ulh && bash scripts/*.sh"
