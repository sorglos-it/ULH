# LIAUH - Changelog

## [0.2] - Custom Repository Hub & SSH Key Management

### 🎯 Major Features

#### Multi-Repository Support
- **Custom Repository Hub** - Clone multiple script repositories with auto-updates
- **Multiple Authentication Methods:**
  - SSH with keys in `custom/keys/` (recommended)
  - SSH with `~/.ssh/` keys
  - HTTPS with Personal Access Tokens
  - HTTPS with username/password
  - Public repositories (no auth)
- **Auto-Update Control** - `auto_update: false` flag for read-only repos
- **Environment Variable Support** - Secure credential handling via `${VAR_NAME}`

#### SSH Key Management
- **custom/keys/ Directory** - Store SSH keys locally (`.gitignore` prevents commits)
- **Smart Path Resolution** - Searches custom/keys/ → ~/.ssh/ automatically
- **SSH Passphrase Support** - Encrypted keys via `${SSH_KEY_PASSPHRASE}`

#### Version Display
- **LIAUH_VERSION** - Variable at top of liauh.sh for easy version management
- **Header Display** - Version shown in main menu header (right-aligned)

#### Documentation Updates
- **README.md** - Comprehensive Custom Repository Hub guide
- **SCRIPTS.md** - Dedicated script reference (moved from README for clarity)
- **custom/repo.yaml** - Detailed configuration examples & setup instructions
- **Troubleshooting** - SSH key, repository, and custom script debugging

### 🔧 Technical Changes

- **lib/repos.sh** - New repository management library (700+ lines)
  - `repo_init()` - Initialize custom repositories on startup
  - `repo_sync_all()` - Clone/pull all enabled repositories
  - `repo_clone()` - Clone with auth and retry logic
  - `repo_pull()` - Update existing repos with SSH support
  - `repo_resolve_ssh_key()` - Smart key path resolution
  - `repo_expand_var()` - Environment variable expansion

- **Simplified Paths** - Remove "custom/" prefix from repo.yaml paths
  - Before: `path: "custom/custom-scripts"`
  - After: `path: "custom-scripts"` (auto-prefixed)

- **lib/menu.sh** - Enhanced header display
  - `menu_header()` now accepts optional version parameter
  - Version displayed right-aligned in header box
  - Proper width calculation (80 chars total)

- **liauh.sh** - Repository initialization
  - Added `repo_init()` call on startup
  - Auto-clones/pulls custom repositories before menu
  - Respects auto_update flags per repository

### 🎯 Workflow Example

```bash
# 1. Setup SSH key in custom/keys/
cp ~/.ssh/id_rsa liauh/custom/keys/id_rsa
chmod 600 liauh/custom/keys/id_rsa

# 2. Configure repository in custom/repo.yaml
repositories:
  my-scripts:
    url: "git@github.com:org/my-scripts.git"
    path: "my-scripts"
    auth_method: "ssh"
    ssh_key: "id_rsa"
    enabled: true
    auto_update: true

# 3. Run liauh - repos auto-clone/pull
bash liauh.sh

# Your scripts appear in the menu!
```

### 📋 File Changes

**New Files:**
- `lib/repos.sh` - Repository management engine
- `custom/repo.yaml` - Repository configuration template
- `custom/keys/.gitignore` - Protect SSH keys from git

**Modified Files:**
- `liauh.sh` - Added `repo_init()` on startup
- `lib/menu.sh` - Enhanced header with version display
- `README.md` - Comprehensive Custom Repository Hub docs
- `SCRIPTS.md` - New dedicated scripts reference (extracted from README)

### ✅ Testing Status

- ✅ All 15 scripts pass bash syntax validation
- ✅ Repository cloning with SSH keys (manual testing)
- ✅ Auto-update on/off toggles working
- ✅ Environment variable expansion functional
- ✅ Header alignment perfected (80-char width)
- ⏳ Live deployment testing pending

---

## [Latest] - Complete Script Library (Previous Version)

### 🚀 New Scripts Added

#### System Management
- **linux.sh** - Universal Linux configuration (network, DNS, hostname, users, groups)
- **proxmox.sh** - Proxmox VE management (stop VMs/LXC, language, qemu-guest-agent, SSH, templates)

#### PiKVM
- **pikvm-v3.sh** - Comprehensive PiKVM v3 management (11 actions):
  - System updates
  - ISO directory management
  - OLED display control
  - Hostname configuration
  - VNC setup & user management
  - ATX menu control
  - USB IMG creation
  - SSL certificate setup (Step-CA)
  - RTC support (Geekworm)

#### Web Servers
- **apache.sh** - Apache2 full management (install, update, uninstall, vhosts, config)
- **nginx.sh** - Nginx full management (install, update, uninstall, server blocks, config)

#### Container & Tools
- **docker.sh** - Docker management with configuration
- **portainer.sh** - Portainer Main (Docker UI) with custom ports
- **portainer-client.sh** - Portainer Agent (Edge) deployment

#### System Updates
- **debian.sh** - Debian system update
- **ubuntu.sh** - Ubuntu system update with Pro support

#### Security & Infrastructure
- **ca-cert-update.sh** - CA certificate installation
- **mariadb.sh** - MariaDB management (install, update, uninstall, config)
- **compression.sh** - Compression tools (zip/unzip)

### ✨ Key Features

- **13 Production Scripts** covering most common Linux management tasks
- **100+ Actions** across all scripts
- **Multi-Platform Support:** Debian, Red Hat, Arch, SUSE, Alpine, Proxmox, PiKVM v3
- **Comprehensive Error Handling** with colored logging
- **Parameter Validation** on all user inputs
- **Automatic Package Manager Detection**
- **Configuration Backups** before modifications
- **Security-First Design** (no eval, proper quoting, input validation)

### 🔧 Architecture Improvements

- **Modular Library Structure** - 11 focused library files
- **Consistent Parameter Passing** - Comma-separated format
- **Unified Logging** - Color-coded info/warn/error messages
- **Automatic Permissions** - Scripts auto-chmod when needed
- **Sudo Caching** - Password prompted once per session (~15 min)

### 📊 Script Statistics

| Metric | Count |
|--------|-------|
| Total Scripts | 15 |
| Production Scripts | 13 |
| Total Actions | 100+ |
| Libraries | 11 |
| Code Quality | ✓ 100% Syntax Pass |
| Security Issues | 0 |

### 📋 Script Breakdown by Category

**System Management (2):** linux, proxmox
**System Updates (3):** debian, ubuntu, pikvm-v3
**Webservers (2):** apache, nginx
**Databases (1):** mariadb
**Container/Tools (3):** docker, portainer, portainer-client
**Security (1):** ca-cert-update
**Utilities (1):** compression

### 🎯 Use Cases Covered

- ✅ Full system configuration (network, DNS, hostname, users)
- ✅ Web server deployment & management
- ✅ Database installation & configuration
- ✅ Container orchestration (Docker, Portainer)
- ✅ Proxmox infrastructure management
- ✅ PiKVM appliance configuration
- ✅ Security certificate management
- ✅ System updates & upgrades

### 🐛 Bug Fixes & QA

- Fixed mariadb.sh syntax errors
- Added apk update for Alpine
- Added timeout warnings for long operations
- Enhanced error handling for edge cases
- Improved documentation throughout

### 📝 Documentation

- **README.md** - Quick start & script overview (updated)
- **DOCS.md** - Comprehensive architecture documentation (updated)
- **CHANGES.md** - This file

### 🔐 Security Considerations

- No shell injection vulnerabilities
- Proper quote handling throughout
- Input validation on all parameters
- Configuration backups before modifications
- Secure password handling
- No credential exposure in logs

### 🚀 Ready for Production

All scripts have been:
- ✅ Syntax checked
- ✅ Logic reviewed
- ✅ Security audited
- ✅ Documented
- ✅ Tested for error handling

**Status:** PRODUCTION READY 🎉
