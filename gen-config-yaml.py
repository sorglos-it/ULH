#!/usr/bin/env python3

import csv
import sys

def categorize(app):
    cats = {
        'BorgBackup': 'Backup Tools',
        'Restic': 'Backup Tools',
        'Flatpak': 'Container Tools',
        'Podman': 'Container Tools',
        'Vagrant': 'Container Tools',
        'CMake': 'Development Tools',
        'Git LFS': 'Development Tools',
        'OpenJDK': 'Development Tools',
        'Rust': 'Development Tools',
        'Bun': 'Development Tools',
        'Deno': 'Development Tools',
        'Helix': 'Development Tools',
        'LazyGit': 'Development Tools',
        'Fish': 'Shells',
        'Zsh': 'Shells',
        'Oh My Zsh': 'Shells',
        'Neovim': 'Text Editors',
        'Emacs': 'Text Editors',
        'Micro': 'Text Editors',
        'Helix': 'Text Editors',
    }
    return cats.get(app, 'System Tools')

def get_description(app):
    descs = {
        'BorgBackup': 'Backup and archival tool',
        'Bun': 'JavaScript runtime and package manager',
        'CMake': 'Build system generator',
        'ClamAV': 'Antivirus engine',
        'Deno': 'JavaScript/TypeScript runtime',
        'Emacs': 'Advanced text editor',
        'FFmpeg': 'Multimedia framework',
        'Firejail': 'Application sandboxing',
        'Fish': 'User-friendly shell',
        'Flatpak': 'Application containerization',
        'GameMode': 'Performance optimizer',
        'Git LFS': 'Git Large File Storage',
        'GnuPG': 'Encryption and signing',
        'Helix': 'Post-modern text editor',
        'ImHex': 'Hex editor and analyzer',
        'LazyGit': 'Simple git UI',
        'Micro': 'Terminal text editor',
        'Neovim': 'Vim-based editor',
        'Nmap': 'Network scanner',
        'Oh My Zsh': 'Zsh framework',
        'OpenJDK': 'Java platform',
        'Podman': 'Container runtime',
        'Restic': 'Backup program',
        'Rust': 'Systems programming language',
        'Starship': 'Shell prompt',
        'Superfile': 'Terminal file manager',
        'Vagrant': 'Infrastructure automation',
        'Zellij': 'Terminal multiplexer',
        'Zsh': 'Z shell',
        'aria2': 'Download utility',
        'bat': 'Cat with syntax highlighting',
        'btop': 'System monitor',
        'eza': 'Modern ls replacement',
        'fastfetch': 'System information tool',
        'fd': 'Find alternative',
        'fzf': 'Fuzzy finder',
        'kubectl': 'Kubernetes CLI',
        'ncdu': 'Disk usage analyzer',
        'npm': 'Node Package Manager',
        'pnpm': 'Fast npm alternative',
        'ranger': 'Terminal file manager',
        'ripgrep': 'Fast grep alternative',
        'rsync': 'File transfer utility',
        'tldr': 'Simplified man pages',
        'uv': 'Fast Python installer',
        'yarn': 'JavaScript package manager',
        'yazi': 'Terminal file manager',
        'zoxide': 'Smart cd command',
    }
    return descs.get(app, 'CLI tool')

def script_name(app):
    return app.lower().replace(' ', '-')

# Parse and generate
with open('/root/workspace/app_cli.txt') as f:
    reader = csv.reader(f)
    apps = []
    for row in reader:
        if row:
            app = row[0].strip()
            if app:
                apps.append(app)

print("scripts:")
for app in apps:
    name = script_name(app)
    cat = categorize(app)
    desc = get_description(app)
    
    print(f"""  {name}:
    description: "{desc}"
    category: "{cat}"
    file: "{name}.sh"
    os_family:
      - debian
      - redhat
      - arch
      - suse
      - alpine
    
    actions:
      - name: "install"
        parameter: "install"
        description: "Install {app}"
      
      - name: "update"
        parameter: "update"
        description: "Update {app}"
      
      - name: "uninstall"
        parameter: "uninstall"
        description: "Uninstall {app}"
""")
