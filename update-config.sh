#!/bin/bash
# Generate config.yaml entries for all CLI tools

set -e

APPS_FILE="/root/workspace/app_cli.txt"
CONFIG_FILE="/root/workspace/ulh/config.yaml"

categorize() {
    case "$1" in
        BorgBackup|Restic) echo "Backup Tools" ;;
        Flatpak|Podman|Vagrant) echo "Container Tools" ;;
        CMake|Git\ LFS|OpenJDK|Rust|Bun|Deno) echo "Development Tools" ;;
        Fish|Zsh|Oh\ My\ Zsh) echo "Shells" ;;
        Neovim|Emacs|Micro|Helix) echo "Text Editors" ;;
        btop|eza|fd|fzf|ncdu|fastfetch|ripgrep|yazi|bat|aria2|ranger|tldr|Nmap|ImHex) echo "System Tools" ;;
        npm|pnpm|yarn|uv|kubectl) echo "Package Managers" ;;
        ClamAV|GnuPG|Firejail|GameMode|Starship|Superfile|Zellij|LazyGit) echo "System Tools" ;;
        FFmpeg) echo "Media Tools" ;;
        *) echo "Development Tools" ;;
    esac
}

get_description() {
    case "$1" in
        BorgBackup) echo "Backup and archival tool" ;;
        Bun) echo "JavaScript runtime and package manager" ;;
        CMake) echo "Build system generator" ;;
        ClamAV) echo "Antivirus engine" ;;
        Deno) echo "JavaScript/TypeScript runtime" ;;
        Emacs) echo "Advanced text editor" ;;
        FFmpeg) echo "Multimedia framework" ;;
        Firejail) echo "Application sandboxing tool" ;;
        Fish) echo "User-friendly shell" ;;
        Flatpak) echo "Application containerization" ;;
        GameMode) echo "Performance optimizer for games" ;;
        Git\ LFS) echo "Git Large File Storage" ;;
        GnuPG) echo "Encryption and signing tool" ;;
        Helix) echo "Post-modern text editor" ;;
        ImHex) echo "Hex editor and analyzer" ;;
        LazyGit) echo "Simple git UI" ;;
        Micro) echo "Modern terminal text editor" ;;
        Neovim) echo "Hyperextensible Vim-based editor" ;;
        Nmap) echo "Network scanner" ;;
        Oh\ My\ Zsh) echo "Zsh framework and plugins" ;;
        OpenJDK) echo "Open-source Java platform" ;;
        Podman) echo "Container runtime" ;;
        Restic) echo "Backup program" ;;
        Rust) echo "Systems programming language" ;;
        Starship) echo "Shell prompt" ;;
        Superfile) echo "Terminal file manager" ;;
        Vagrant) echo "Infrastructure automation" ;;
        Zellij) echo "Terminal multiplexer" ;;
        Zsh) echo "Z shell" ;;
        aria2) echo "Download utility" ;;
        bat) echo "Cat clone with syntax highlighting" ;;
        btop) echo "System monitor" ;;
        eza) echo "Modern ls replacement" ;;
        fastfetch) echo "System information tool" ;;
        fd) echo "Find alternative" ;;
        fzf) echo "Fuzzy finder" ;;
        kubectl) echo "Kubernetes command-line" ;;
        ncdu) echo "Disk usage analyzer" ;;
        npm) echo "Node Package Manager" ;;
        pnpm) echo "Fast npm alternative" ;;
        ranger) echo "Terminal file manager" ;;
        ripgrep) echo "Fast grep alternative" ;;
        rsync) echo "File transfer utility" ;;
        tldr) echo "Simplified man pages" ;;
        uv) echo "Fast Python package installer" ;;
        yarn) echo "Package manager for JavaScript" ;;
        yazi) echo "Terminal file manager" ;;
        zoxide) echo "Smart cd command" ;;
        *) echo "CLI tool" ;;
    esac
}

get_pkg_name() {
    case "$1" in
        "Git LFS") echo "git-lfs" ;;
        "Oh My Zsh") echo "zsh" ;;
        "OpenJDK") echo "openjdk-bin" ;;
        *) echo "${1,,}" | sed 's/ /-/g' ;;
    esac
}

# Generate YAML entry for one app
gen_entry() {
    local app="$1"
    local script_name=$(echo "${app,,}" | sed 's/ /-/g')
    local category=$(categorize "$app")
    local description=$(get_description "$app")
    local pkg=$(get_pkg_name "$app")
    
    cat << EOF
  ${script_name}:
    description: "${description}"
    category: "${category}"
    file: "${script_name}.sh"
    os_family:
      - debian
      - redhat
      - arch
      - suse
      - alpine
    
    actions:
      - name: "install"
        parameter: "install"
        description: "Install ${app}"
        prompts: []
      
      - name: "update"
        parameter: "update"
        description: "Update ${app}"
        prompts: []
      
      - name: "uninstall"
        parameter: "uninstall"
        description: "Uninstall ${app}"
        prompts: []

EOF
}

# Generate all entries
echo "Generating config.yaml entries..."

{
    echo "scripts:"
    
    # Existing system scripts first
    grep -E "^  (curl|wget|git|vim|nano|htop|tmux|screen|build-essential|jq|locate|apache|nginx|mariadb|postgres|mysql|docker|docker-compose|portainer|proxmox|nodejs|python|ruby|golang|php|perl|rsyslog|syslog-ng|fail2ban|logrotate|openssh|net-tools|bind-utils|wireguard|openvpn|ufw|linux|ubuntu|debian|pikvm|remotely|pihole|adguard|samba|cifs):" "$CONFIG_FILE" || true
    
    # Extract existing scripts block and keep it
    sed -n '/^scripts:/,/^[^ ]/p' "$CONFIG_FILE" | head -n -1
    
} > /tmp/config.yaml.new

# Append new CLI tools
{
    while IFS=',' read -r app rest; do
        app=$(echo "$app" | xargs)
        [[ -z "$app" ]] && continue
        gen_entry "$app"
    done < "$APPS_FILE"
} >> /tmp/config.yaml.new

# Backup and replace
cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
mv /tmp/config.yaml.new "$CONFIG_FILE"

echo "✓ config.yaml updated"
