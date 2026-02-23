#!/usr/bin/env python3

import yaml

# Define new category mapping
CATEGORY_MAP = {
    # Essential Tools
    'curl': 'Essential Tools',
    'wget': 'Essential Tools',
    'git': 'Essential Tools',
    'htop': 'Essential Tools',
    'tmux': 'Essential Tools',
    'screen': 'Essential Tools',
    'build-essential': 'Essential Tools',
    'jq': 'Essential Tools',
    'locate': 'Essential Tools',
    'rsync': 'Essential Tools',
    
    # Text Editors & IDE
    'vim': 'Text Editors',
    'nano': 'Text Editors',
    'emacs': 'Text Editors',
    'neovim': 'Text Editors',
    'micro': 'Text Editors',
    'helix': 'Text Editors',
    
    # Shells & Terminals
    'fish': 'Shells & Terminals',
    'zsh': 'Shells & Terminals',
    'oh-my-zsh': 'Shells & Terminals',
    'zellij': 'Shells & Terminals',
    'starship': 'Shells & Terminals',
    
    # Web Servers
    'apache': 'Web Servers',
    'nginx': 'Web Servers',
    
    # Databases
    'mariadb': 'Databases',
    'postgres': 'Databases',
    'mysql': 'Databases',
    
    # Container & VM
    'docker': 'Container & Virtualization',
    'docker-compose': 'Container & Virtualization',
    'portainer': 'Container & Virtualization',
    'proxmox': 'Container & Virtualization',
    'flatpak': 'Container & Virtualization',
    'podman': 'Container & Virtualization',
    'vagrant': 'Container & Virtualization',
    'kubernetes': 'Container & Virtualization',
    'kubectl': 'Container & Virtualization',
    
    # Programming Languages
    'nodejs': 'Programming Languages',
    'python': 'Programming Languages',
    'ruby': 'Programming Languages',
    'golang': 'Programming Languages',
    'php': 'Programming Languages',
    'perl': 'Programming Languages',
    'rust': 'Programming Languages',
    'bun': 'Programming Languages',
    'deno': 'Programming Languages',
    'openjdk': 'Programming Languages',
    
    # Development Tools
    'cmake': 'Development Tools',
    'git-lfs': 'Development Tools',
    'lazygit': 'Development Tools',
    'imhex': 'Development Tools',
    
    # System Utilities
    'aria2': 'System Utilities',
    'bat': 'System Utilities',
    'btop': 'System Utilities',
    'clamav': 'System Utilities',
    'eza': 'System Utilities',
    'fastfetch': 'System Utilities',
    'fd': 'System Utilities',
    'fzf': 'System Utilities',
    'ncdu': 'System Utilities',
    'ranger': 'System Utilities',
    'ripgrep': 'System Utilities',
    'superfile': 'System Utilities',
    'tldr': 'System Utilities',
    'yazi': 'System Utilities',
    'zoxide': 'System Utilities',
    
    # Backup & Sync
    'borgbackup': 'Backup & Sync',
    'restic': 'Backup & Sync',
    
    # Monitoring & Logging
    'rsyslog': 'Monitoring & Logging',
    'syslog-ng': 'Monitoring & Logging',
    'fail2ban': 'Monitoring & Logging',
    'logrotate': 'Monitoring & Logging',
    
    # Networking
    'openssh': 'Networking',
    'net-tools': 'Networking',
    'bind-utils': 'Networking',
    'wireguard': 'Networking',
    'openvpn': 'Networking',
    'ufw': 'Networking',
    'pihole': 'Networking',
    'adguard-home': 'Networking',
    'samba': 'Networking',
    'cifs-utils': 'Networking',
    'nmap': 'Networking',
    
    # System Management
    'linux': 'System Management',
    'ubuntu': 'System Management',
    'debian': 'System Management',
    'pikvm-v3': 'System Management',
    'remotely': 'System Management',
    
    # Package Managers
    'npm': 'Package Managers',
    'pnpm': 'Package Managers',
    'yarn': 'Package Managers',
    'uv': 'Package Managers',
    
    # Security & Sandboxing
    'firejail': 'Security & Sandboxing',
    'gamemode': 'Security & Sandboxing',
    'gnupg': 'Security & Sandboxing',
    
    # Multimedia
    'ffmpeg': 'Multimedia',
}

# Category descriptions
CATEGORY_DESC = {
    'Essential Tools': 'Core utilities for system administration',
    'Text Editors': 'Text editors and code editors',
    'Shells & Terminals': 'Shell environments and terminal tools',
    'Web Servers': 'HTTP/HTTPS web servers',
    'Databases': 'Database management systems',
    'Container & Virtualization': 'Container and VM technologies',
    'Programming Languages': 'Language runtimes and environments',
    'Development Tools': 'Development and debugging tools',
    'System Utilities': 'System information and file tools',
    'Backup & Sync': 'Backup and file synchronization',
    'Monitoring & Logging': 'System monitoring and log management',
    'Networking': 'Network tools and utilities',
    'System Management': 'System configuration and management',
    'Package Managers': 'Package and dependency managers',
    'Security & Sandboxing': 'Security and sandboxing tools',
    'Multimedia': 'Media processing and conversion',
}

# Load config
with open('config.yaml', 'r') as f:
    config = yaml.safe_load(f)

# Update categories section
categories = {}
for cat_name, cat_desc in CATEGORY_DESC.items():
    categories[cat_name] = {'description': cat_desc}

config['categories'] = categories

# Remap scripts
new_scripts = {}
for name, script in config['scripts'].items():
    script_copy = script.copy()
    if name in CATEGORY_MAP:
        script_copy['category'] = CATEGORY_MAP[name]
    else:
        print(f"Warning: {name} not in category map, keeping: {script.get('category', 'Unknown')}")
    new_scripts[name] = script_copy

config['scripts'] = new_scripts

# Save
with open('config.yaml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False, sort_keys=False, allow_unicode=True)

print("✓ config.yaml reorganized with new category structure")
print(f"  Categories: {len(categories)}")
print(f"  Scripts: {len(new_scripts)}")
