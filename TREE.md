# ulh Tree & Script Map

**v0.5 | 96 scripts | 16 categories** - where everything lives, and how to find it fast.

## Table of Contents

1. [Repository Tree](#repository-tree)
2. [Where To Look For What](#where-to-look-for-what)
3. [Scripts By Category](#scripts-by-category)
4. [All Scripts A-Z](#all-scripts-a-z)
5. [Library Map](#library-map)
6. [Runtime Paths](#runtime-paths)

---

## Repository Tree

```
ulh/                          # clone target, default: ~/ulh
|
+-- ulh.sh                    # entry point: auto-update, load libs, start menu
+-- install.sh                # one-liner installer (installs git, clones/pulls ulh)
+-- config.yaml               # menu + action definitions for ALL system scripts
|
+-- lib/                      # framework (sourced, never called directly)
|   +-- bootstrap.sh          # sourced BY the scripts: parse_parameters, log_*, detect_os
|   +-- colors.sh             # ANSI colors (single source of truth)
|   +-- core.sh               # msg_* helpers, OS detection for the menu
|   +-- execute.sh            # prompts, answer.yaml/autoscript, runs the script
|   +-- menu.sh               # menu rendering + navigation loops
|   +-- repos.sh              # custom repo clone/pull/auth
|   +-- yaml.sh               # yq wrappers (yaml_scripts, yaml_action_name, ...)
|   +-- yq/                   # bundled yq binaries (amd64, arm64, arm, 386)
|
+-- scripts/                  # one file per program - THE place to look
|   +-- _template.sh          # copy this to start a new script
|   +-- <name>.sh             # e.g. spoolman.sh, docker.sh, nginx.sh
|
+-- custom/                   # everything user-specific (git-ignored)
|   +-- repo.yaml             # your custom repositories
|   +-- answer.yaml           # prompt defaults + autoscript flags
|   +-- keys/                 # SSH keys for private repos
|   +-- <repo>/               # cloned custom repos (own config.yaml + scripts/)
|
+-- README.md                 # quick start
+-- DOCS.md                   # full guide (architecture, answer.yaml, development)
+-- SCRIPTS.md                # script reference (name + description)
+-- TREE.md                   # this file (paths, actions, distros)
+-- BACKSTORY.md              # how the name happened
+-- LICENSE                   # MIT
```

---

## Where To Look For What

| I want to ... | Look at |
|---------------|---------|
| find a script while ulh is running | press `s` in the menu, or type `/term` at the prompt |
| find the code for program `X` | `scripts/X.sh` |
| change menu entry, category or prompts of `X` | `config.yaml` -> `scripts.X` |
| add a new program | `cp scripts/_template.sh scripts/X.sh` + entry in `config.yaml` |
| run something without the menu | `sudo bash scripts/X.sh "install"` |
| see which actions `X` has | `bash scripts/X.sh` (prints usage from config.yaml) |
| preset answers / automate | `custom/answer.yaml` |
| change how prompts behave | `lib/execute.sh` |
| change the menu layout | `lib/menu.sh` |
| add your own script repo | `custom/repo.yaml` + `lib/repos.sh` |

**Grep cheat sheet** (run from the ulh directory):

```bash
ls scripts | grep -i spool                      # find a script file
grep -n "^  spoolman:" -A 20 config.yaml        # its config block
grep -n "description:" config.yaml | grep -i vnc  # search all descriptions
grep -rn "category: System Management" config.yaml -B 2 | grep "^config.yaml-  [a-z]"
```

---

## Scripts By Category

`sudo` = the action runs via `sudo` (set by the `sudo:` key in config.yaml).
`Distros` = `all` means debian, redhat, arch, suse and alpine.

### Essential Tools

*Core utilities for system administration* - 10 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `build-essential` | `scripts/build-essential.sh` | install, update, uninstall | yes | all |
| `curl` | `scripts/curl.sh` | install, update, uninstall | - | all |
| `git` | `scripts/git.sh` | install, update, uninstall, config | - | all |
| `htop` | `scripts/htop.sh` | install, update, uninstall | - | all |
| `jq` | `scripts/jq.sh` | install, update, uninstall | - | all |
| `locate` | `scripts/locate.sh` | install, update, uninstall, config | yes | all |
| `rsync` | `scripts/rsync.sh` | install, update, uninstall | - | all |
| `screen` | `scripts/screen.sh` | install, update, uninstall | - | all |
| `tmux` | `scripts/tmux.sh` | install, update, uninstall, config | - | all |
| `wget` | `scripts/wget.sh` | install, update, uninstall | - | all |

### Text Editors

*Text editors and code editors* - 6 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `emacs` | `scripts/emacs.sh` | install, update, uninstall | - | all |
| `helix` | `scripts/helix.sh` | install, update, uninstall | - | all |
| `micro` | `scripts/micro.sh` | install, update, uninstall | - | all |
| `nano` | `scripts/nano.sh` | install, update, uninstall | - | all |
| `neovim` | `scripts/neovim.sh` | install, update, uninstall | - | all |
| `vim` | `scripts/vim.sh` | install, update, uninstall, config | - | all |

### Shells & Terminals

*Shell environments and terminal tools* - 5 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `fish` | `scripts/fish.sh` | install, update, uninstall | - | all |
| `oh-my-zsh` | `scripts/oh-my-zsh.sh` | install, update, uninstall | - | all |
| `starship` | `scripts/starship.sh` | install, update, uninstall | - | all |
| `zellij` | `scripts/zellij.sh` | install, update, uninstall | - | all |
| `zsh` | `scripts/zsh.sh` | install, update, uninstall | - | all |

### Web Servers

*HTTP/HTTPS web servers* - 2 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `apache` | `scripts/apache.sh` | install, update, uninstall, vhosts | yes | all |
| `nginx` | `scripts/nginx.sh` | install, update, uninstall, vhosts | yes | all |

### Databases

*Database management systems* - 3 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `mariadb` | `scripts/mariadb.sh` | install, update, uninstall, config | yes | debian, redhat |
| `mysql` | `scripts/mysql.sh` | install, update, uninstall, config | yes | all |
| `postgres` | `scripts/postgres.sh` | install, update, uninstall, config | yes | all |

### Container & Virtualization

*Container and VM technologies* - 8 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `docker` | `scripts/docker.sh` | install, update, uninstall, config | yes | all |
| `docker-compose` | `scripts/docker-compose.sh` | install, update, uninstall, config | yes | all |
| `flatpak` | `scripts/flatpak.sh` | install, update, uninstall | - | all |
| `kubectl` | `scripts/kubectl.sh` | install, update, uninstall | - | all |
| `podman` | `scripts/podman.sh` | install, update, uninstall | - | all |
| `portainer` | `scripts/portainer.sh` | install, update, uninstall | yes | all |
| `proxmox` | `scripts/proxmox.sh` | install, update, uninstall, make-lxc-to-template, make-template-to-lxc, unlock-vm, stop-all, list-lxc, list-lxc-running, start-vm, stop-vm, start-lxc, stop-lxc | yes | only proxmox |
| `vagrant` | `scripts/vagrant.sh` | install, update, uninstall | - | all |

### Programming Languages

*Language runtimes and environments* - 10 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `bun` | `scripts/bun.sh` | install, update, uninstall | - | all |
| `deno` | `scripts/deno.sh` | install, update, uninstall | - | all |
| `golang` | `scripts/golang.sh` | install, update, uninstall | - | all |
| `nodejs` | `scripts/nodejs.sh` | install, update, uninstall | - | all |
| `openjdk` | `scripts/openjdk.sh` | install, update, uninstall | - | all |
| `perl` | `scripts/perl.sh` | install, update, uninstall | - | all |
| `php` | `scripts/php.sh` | install, update, uninstall | - | all |
| `python` | `scripts/python.sh` | install, update, uninstall | - | all |
| `ruby` | `scripts/ruby.sh` | install, update, uninstall | - | all |
| `rust` | `scripts/rust.sh` | install, update, uninstall | - | all |

### Development Tools

*Development and debugging tools* - 4 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `cmake` | `scripts/cmake.sh` | install, update, uninstall | - | all |
| `git-lfs` | `scripts/git-lfs.sh` | install, update, uninstall | - | all |
| `imhex` | `scripts/imhex.sh` | install, update, uninstall | - | all |
| `lazygit` | `scripts/lazygit.sh` | install, update, uninstall | - | all |

### System Utilities

*System information and file tools* - 15 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `aria2` | `scripts/aria2.sh` | install, update, uninstall | - | all |
| `bat` | `scripts/bat.sh` | install, update, uninstall | - | all |
| `btop` | `scripts/btop.sh` | install, update, uninstall | - | all |
| `clamav` | `scripts/clamav.sh` | install, update, uninstall | - | all |
| `eza` | `scripts/eza.sh` | install, update, uninstall | - | all |
| `fastfetch` | `scripts/fastfetch.sh` | install, update, uninstall | - | all |
| `fd` | `scripts/fd.sh` | install, update, uninstall | - | all |
| `fzf` | `scripts/fzf.sh` | install, update, uninstall | - | all |
| `ncdu` | `scripts/ncdu.sh` | install, update, uninstall | - | all |
| `ranger` | `scripts/ranger.sh` | install, update, uninstall | - | all |
| `ripgrep` | `scripts/ripgrep.sh` | install, update, uninstall | - | all |
| `superfile` | `scripts/superfile.sh` | install, update, uninstall | - | all |
| `tldr` | `scripts/tldr.sh` | install, update, uninstall | - | all |
| `yazi` | `scripts/yazi.sh` | install, update, uninstall | - | all |
| `zoxide` | `scripts/zoxide.sh` | install, update, uninstall | - | all |

### Backup & Sync

*Backup and file synchronization* - 2 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `borgbackup` | `scripts/borgbackup.sh` | install, update, uninstall | - | all |
| `restic` | `scripts/restic.sh` | install, update, uninstall | - | all |

### Monitoring & Logging

*System monitoring and log management* - 4 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `fail2ban` | `scripts/fail2ban.sh` | install, update, uninstall, config | yes | all |
| `logrotate` | `scripts/logrotate.sh` | install, update, uninstall, config | yes | all |
| `rsyslog` | `scripts/rsyslog.sh` | install, update, uninstall, config | yes | all |
| `syslog-ng` | `scripts/syslog-ng.sh` | install, update, uninstall, config | yes | all |

### Networking

*Network tools and utilities* - 11 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `adguard-home` | `scripts/adguard-home.sh` | install, update, uninstall, config, dns-check | yes | all |
| `bind-utils` | `scripts/bind-utils.sh` | install, update, uninstall, config | - | all |
| `cifs-utils` | `scripts/cifs-utils.sh` | install, update, uninstall, mountSMB | yes | all |
| `net-tools` | `scripts/net-tools.sh` | install, update, uninstall | - | all |
| `nmap` | `scripts/nmap.sh` | install, update, uninstall | - | all |
| `openssh` | `scripts/openssh.sh` | install, update, uninstall, config, fix-xauthority | yes | all |
| `openvpn` | `scripts/openvpn.sh` | install, update, uninstall, config | yes | all |
| `pihole` | `scripts/pihole.sh` | install, update, uninstall, config | yes | all |
| `samba` | `scripts/samba.sh` | install, update, uninstall, config, add-share, smbuser | yes | all |
| `ufw` | `scripts/ufw.sh` | install, update, uninstall, enable, disable, config, status, reset | yes | all |
| `wireguard` | `scripts/wireguard.sh` | install, update, uninstall, config | yes | all |

### System Management

*System configuration and management* - 7 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `debian` | `scripts/debian.sh` | update, dist-upgrade | yes | only debian |
| `linux` | `scripts/linux.sh` | network, dns, hostname, user-add, user-delete, user-password, group-create, user-to-group, ca-cert, install-zip, uninstall-zip | yes | all |
| `pikvm-v3` | `scripts/pikvm-v3.sh` | update, mount-iso, dismount-iso, oled-enable, vnc-enable | yes | only arch |
| `remotely` | `scripts/remotely.sh` | install, update, uninstall, config | yes | debian, redhat |
| `spoolman` | `scripts/spoolman.sh` | install, update, detect, backup, uninstall | yes | all |
| `tigervnc` | `scripts/tigervnc.sh` | install, update, uninstall, config | yes | all |
| `ubuntu` | `scripts/ubuntu.sh` | update, pro, detach | yes | only ubuntu |

### Package Managers

*Package and dependency managers* - 4 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `npm` | `scripts/npm.sh` | install, update, uninstall | - | all |
| `pnpm` | `scripts/pnpm.sh` | install, update, uninstall | - | all |
| `uv` | `scripts/uv.sh` | install, update, uninstall | - | all |
| `yarn` | `scripts/yarn.sh` | install, update, uninstall | - | all |

### Security & Sandboxing

*Security and sandboxing tools* - 4 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `firejail` | `scripts/firejail.sh` | install, update, uninstall | - | all |
| `gamemode` | `scripts/gamemode.sh` | install, update, uninstall | - | all |
| `gnupg` | `scripts/gnupg.sh` | install, update, uninstall | - | all |
| `step-ca` | `scripts/step-ca.sh` | install, update, uninstall | yes | all |

### Multimedia

*Media processing and conversion* - 1 scripts

| Script | File | Actions | sudo | Distros |
|--------|------|---------|------|---------|
| `ffmpeg` | `scripts/ffmpeg.sh` | install, update, uninstall | - | all |

---

## All Scripts A-Z

| Script | Path | Category |
|--------|------|----------|
| `adguard-home` | `scripts/adguard-home.sh` | Networking |
| `apache` | `scripts/apache.sh` | Web Servers |
| `aria2` | `scripts/aria2.sh` | System Utilities |
| `bat` | `scripts/bat.sh` | System Utilities |
| `bind-utils` | `scripts/bind-utils.sh` | Networking |
| `borgbackup` | `scripts/borgbackup.sh` | Backup & Sync |
| `btop` | `scripts/btop.sh` | System Utilities |
| `build-essential` | `scripts/build-essential.sh` | Essential Tools |
| `bun` | `scripts/bun.sh` | Programming Languages |
| `cifs-utils` | `scripts/cifs-utils.sh` | Networking |
| `clamav` | `scripts/clamav.sh` | System Utilities |
| `cmake` | `scripts/cmake.sh` | Development Tools |
| `curl` | `scripts/curl.sh` | Essential Tools |
| `debian` | `scripts/debian.sh` | System Management |
| `deno` | `scripts/deno.sh` | Programming Languages |
| `docker` | `scripts/docker.sh` | Container & Virtualization |
| `docker-compose` | `scripts/docker-compose.sh` | Container & Virtualization |
| `emacs` | `scripts/emacs.sh` | Text Editors |
| `eza` | `scripts/eza.sh` | System Utilities |
| `fail2ban` | `scripts/fail2ban.sh` | Monitoring & Logging |
| `fastfetch` | `scripts/fastfetch.sh` | System Utilities |
| `fd` | `scripts/fd.sh` | System Utilities |
| `ffmpeg` | `scripts/ffmpeg.sh` | Multimedia |
| `firejail` | `scripts/firejail.sh` | Security & Sandboxing |
| `fish` | `scripts/fish.sh` | Shells & Terminals |
| `flatpak` | `scripts/flatpak.sh` | Container & Virtualization |
| `fzf` | `scripts/fzf.sh` | System Utilities |
| `gamemode` | `scripts/gamemode.sh` | Security & Sandboxing |
| `git` | `scripts/git.sh` | Essential Tools |
| `git-lfs` | `scripts/git-lfs.sh` | Development Tools |
| `gnupg` | `scripts/gnupg.sh` | Security & Sandboxing |
| `golang` | `scripts/golang.sh` | Programming Languages |
| `helix` | `scripts/helix.sh` | Text Editors |
| `htop` | `scripts/htop.sh` | Essential Tools |
| `imhex` | `scripts/imhex.sh` | Development Tools |
| `jq` | `scripts/jq.sh` | Essential Tools |
| `kubectl` | `scripts/kubectl.sh` | Container & Virtualization |
| `lazygit` | `scripts/lazygit.sh` | Development Tools |
| `linux` | `scripts/linux.sh` | System Management |
| `locate` | `scripts/locate.sh` | Essential Tools |
| `logrotate` | `scripts/logrotate.sh` | Monitoring & Logging |
| `mariadb` | `scripts/mariadb.sh` | Databases |
| `micro` | `scripts/micro.sh` | Text Editors |
| `mysql` | `scripts/mysql.sh` | Databases |
| `nano` | `scripts/nano.sh` | Text Editors |
| `ncdu` | `scripts/ncdu.sh` | System Utilities |
| `neovim` | `scripts/neovim.sh` | Text Editors |
| `net-tools` | `scripts/net-tools.sh` | Networking |
| `nginx` | `scripts/nginx.sh` | Web Servers |
| `nmap` | `scripts/nmap.sh` | Networking |
| `nodejs` | `scripts/nodejs.sh` | Programming Languages |
| `npm` | `scripts/npm.sh` | Package Managers |
| `oh-my-zsh` | `scripts/oh-my-zsh.sh` | Shells & Terminals |
| `openjdk` | `scripts/openjdk.sh` | Programming Languages |
| `openssh` | `scripts/openssh.sh` | Networking |
| `openvpn` | `scripts/openvpn.sh` | Networking |
| `perl` | `scripts/perl.sh` | Programming Languages |
| `php` | `scripts/php.sh` | Programming Languages |
| `pihole` | `scripts/pihole.sh` | Networking |
| `pikvm-v3` | `scripts/pikvm-v3.sh` | System Management |
| `pnpm` | `scripts/pnpm.sh` | Package Managers |
| `podman` | `scripts/podman.sh` | Container & Virtualization |
| `portainer` | `scripts/portainer.sh` | Container & Virtualization |
| `postgres` | `scripts/postgres.sh` | Databases |
| `proxmox` | `scripts/proxmox.sh` | Container & Virtualization |
| `python` | `scripts/python.sh` | Programming Languages |
| `ranger` | `scripts/ranger.sh` | System Utilities |
| `remotely` | `scripts/remotely.sh` | System Management |
| `restic` | `scripts/restic.sh` | Backup & Sync |
| `ripgrep` | `scripts/ripgrep.sh` | System Utilities |
| `rsync` | `scripts/rsync.sh` | Essential Tools |
| `rsyslog` | `scripts/rsyslog.sh` | Monitoring & Logging |
| `ruby` | `scripts/ruby.sh` | Programming Languages |
| `rust` | `scripts/rust.sh` | Programming Languages |
| `samba` | `scripts/samba.sh` | Networking |
| `screen` | `scripts/screen.sh` | Essential Tools |
| `spoolman` | `scripts/spoolman.sh` | System Management |
| `starship` | `scripts/starship.sh` | Shells & Terminals |
| `step-ca` | `scripts/step-ca.sh` | Security & Sandboxing |
| `superfile` | `scripts/superfile.sh` | System Utilities |
| `syslog-ng` | `scripts/syslog-ng.sh` | Monitoring & Logging |
| `tigervnc` | `scripts/tigervnc.sh` | System Management |
| `tldr` | `scripts/tldr.sh` | System Utilities |
| `tmux` | `scripts/tmux.sh` | Essential Tools |
| `ubuntu` | `scripts/ubuntu.sh` | System Management |
| `ufw` | `scripts/ufw.sh` | Networking |
| `uv` | `scripts/uv.sh` | Package Managers |
| `vagrant` | `scripts/vagrant.sh` | Container & Virtualization |
| `vim` | `scripts/vim.sh` | Text Editors |
| `wget` | `scripts/wget.sh` | Essential Tools |
| `wireguard` | `scripts/wireguard.sh` | Networking |
| `yarn` | `scripts/yarn.sh` | Package Managers |
| `yazi` | `scripts/yazi.sh` | System Utilities |
| `zellij` | `scripts/zellij.sh` | Shells & Terminals |
| `zoxide` | `scripts/zoxide.sh` | System Utilities |
| `zsh` | `scripts/zsh.sh` | Shells & Terminals |

---

## Library Map

| File | Responsibility | Key functions |
|------|----------------|---------------|
| `lib/bootstrap.sh` | sourced by every script in `scripts/` | `parse_parameters`, `log_info/warn/error/section`, `detect_os`, `command_exists`, `print_usage` |
| `lib/colors.sh` | ANSI color codes | `$RED`, `$GREEN`, `$C_CYAN`, `separator`, `separator_dots` |
| `lib/core.sh` | menu-side OS detection and messages | `detect_os`, `msg_info`, `msg_ok`, `msg_warn`, `msg_err` |
| `lib/yaml.sh` | reads config.yaml through yq | `yaml_load`, `yaml_scripts`, `yaml_scripts_by_cat`, `yaml_all_descriptions`, `yaml_action_*`, `yaml_prompt_*` |
| `lib/menu.sh` | renders and navigates the menus | `menu_main`, `menu_category`, `menu_actions`, `menu_search`, `menu_header/footer` |
| `lib/execute.sh` | collects answers and runs the script | `execute_action`, `prompt_by_type`, `get_answer_default`, `has_all_answers` |
| `lib/repos.sh` | custom repositories | `repo_init`, `repo_sync_all`, `repo_list_enabled`, `repo_get_path` |

**Call chain of one action:**

```
ulh.sh -> menu.sh (pick script + action, or search with s / /term)
       -> execute.sh (prompts, answer.yaml, sudo)
       -> scripts/<name>.sh "action,VAR1=val1,VAR2=val2"
          -> lib/bootstrap.sh (parse_parameters, detect_os, logging)
```

---

## Runtime Paths

| Path | What |
|------|------|
| `~/ulh/` | default install location (`install.sh` clones here) |
| `~/ulh/custom/answer.yaml` | your prompt defaults, never overwritten by updates |
| `~/ulh/custom/keys/` | SSH keys for private custom repos (`chmod 600`) |
| `~/ulh/custom/<repo>/` | cloned custom repo with its own `config.yaml` and `scripts/` |
| `~/ulh/lib/yq/yq-<arch>` | bundled yq, picked automatically by architecture |

Everything ulh itself needs lives under the clone directory - there is no state
in `/etc` or `/var`. What the individual scripts install (packages, services,
config files) is documented in the header comment of each script.
