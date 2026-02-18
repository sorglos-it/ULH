# LIAUH Scripts Reference

**v0.3** | Complete catalog of 60+ system management scripts

All scripts support **install**, **update**, **uninstall**, and **config** actions (where applicable).

## Essential Tools (13 scripts)

| Script | Description | Supports |
|--------|-------------|----------|
| **curl** | HTTP/HTTPS requests | All 5 distros |
| **wget** | HTTP/FTP downloads | All 5 distros |
| **git** | Version control system | All 5 distros |
| **vim** | Advanced text editor | All 5 distros |
| **nano** | Simple text editor | All 5 distros |
| **htop** | System resource monitor | All 5 distros |
| **tmux** | Terminal multiplexer | All 5 distros |
| **screen** | Terminal multiplexer | All 5 distros |
| **openssh** | SSH server/client | All 5 distros |
| **net-tools** | Network utilities (ifconfig, netstat, etc.) | All 5 distros |
| **build-essential** | Development tools & compilers | All 5 distros |
| **jq** | JSON query processor | All 5 distros |
| **ufw** | Uncomplicated Firewall | All 5 distros |

## Web Servers (2 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **apache** | Apache HTTP Server | All 5 distros | install, update, uninstall, vhosts |
| **nginx** | Nginx HTTP Server | All 5 distros | install, update, uninstall, vhosts |

## Database (1 script)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **mariadb** | MariaDB database server | Debian, Red Hat | install, update, uninstall, config |

## Containerization (3 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **docker** | Docker container runtime | All 5 distros | install, update, uninstall, config |
| **portainer** | Container management UI | All 5 distros | install, update, uninstall |
| **portainer-client** | Portainer Agent | All 5 distros | install, update, uninstall |

## Programming Languages (6 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **nodejs** | Node.js + npm | All 5 distros | install, update, uninstall |
| **python** | Python 3 + pip | All 5 distros | install, update, uninstall |
| **ruby** | Ruby + gem | All 5 distros | install, update, uninstall |
| **golang** | Go programming language | All 5 distros | install, update, uninstall |
| **php** | PHP + cli | All 5 distros | install, update, uninstall |
| **perl** | Perl + modules | All 5 distros | install, update, uninstall |

## Logging & Monitoring (4 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **rsyslog** | System logging daemon | All 5 distros | install, update, uninstall, config |
| **syslog-ng** | Advanced system logging | All 5 distros | install, update, uninstall, config |
| **fail2ban** | Brute-force attack protection | All 5 distros | install, update, uninstall, config |
| **logrotate** | Log rotation utility | All 5 distros | install, update, uninstall, config |

## Networking (3 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **bind-utils** | DNS tools (dig, nslookup, host) | All 5 distros | install, update, uninstall, config |
| **wireguard** | Modern VPN protocol | All 5 distros | install, update, uninstall, config |
| **openvpn** | OpenVPN tunneling protocol | All 5 distros | install, update, uninstall, config |

## System Management (6 scripts)

| Script | Description | Supports | Actions |
|--------|-------------|----------|---------|
| **linux** | Network, DNS, users, groups, CA certs | All 5 distros | network, dns, hostname, user-add, user-delete, user-password, group-create, user-to-group, ca-cert, install-zip, uninstall-zip |
| **ubuntu** | Ubuntu-specific management | Ubuntu only | update, pro, detach |
| **debian** | Debian-specific management | Debian only | update, dist-upgrade |
| **proxmox** | Proxmox VE management | Proxmox only | update, maintenance-mode |
| **pikvm-v3** | PiKVM v3 appliance management | Arch (PiKVM) only | update, mount-iso, dismount-iso, oled-enable, vnc-enable |

## Usage Examples

### Install Node.js
```bash
# From menu:
1. Select LIAUH Scripts → Programming Languages → nodejs → install

# Or manually:
bash liauh.sh
# Navigate through menus
```

### Configure Network
```bash
# From menu:
1. LIAUH Scripts → System → linux → network
2. Enter interface name (eth0)
3. Choose DHCP or static IP
```

### Install Custom Repo Scripts
```bash
# Edit custom/repo.yaml
nano custom/repo.yaml

# Add repository:
repositories:
  my-tools:
    name: "My Tools"
    url: "https://github.com/user/my-tools.git"
    path: "my-tools"
    enabled: true
    auto_update: false

# Run LIAUH - it will clone automatically
bash liauh.sh
```

## Distribution Support Matrix

| Distro | Family | Supports | Package Manager |
|--------|--------|----------|-----------------|
| Debian | debian | All scripts | apt-get |
| Ubuntu | debian | All scripts | apt-get |
| Linux Mint | debian | All scripts | apt-get |
| Red Hat | redhat | Most scripts | dnf/yum |
| Fedora | redhat | Most scripts | dnf |
| CentOS | redhat | Most scripts | dnf/yum |
| Rocky Linux | redhat | Most scripts | dnf |
| Arch | arch | Most scripts | pacman |
| Manjaro | arch | Most scripts | pacman |
| openSUSE | suse | Most scripts | zypper |
| SUSE | suse | Most scripts | zypper |
| Alpine | alpine | Essential tools | apk |
| Proxmox VE | debian | All scripts | apt-get |

## Creating Your Own Scripts

See **[DOCS.md - Script Development](DOCS.md#script-development)** for:
- Using the template (`scripts/_template.sh`)
- Parameter parsing format
- Multi-distribution support examples
- Best practices and guidelines

## Notes

- All scripts support the full parameter passing format: `action,VAR1=val1,VAR2=val2`
- Prompts in `config.yaml` are converted to environment variables automatically
- Service management (enable/start/stop) happens automatically where applicable
- SSH keys for custom repos are stored in `custom/keys/` (protected by .gitignore)

---

**For detailed documentation:** See [DOCS.md](DOCS.md)
**For quick start:** See [README.md](README.md)
