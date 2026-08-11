# ulh - unknown linux helper

**v0.5** | 96 system management scripts for all Linux distributions

## 🚀 Installation

### One-liner (Auto-install wget)
```bash
wget -qO - https://raw.githubusercontent.com/sorglos-it/ulh/main/install.sh | bash && cd ~/ulh && bash ulh.sh
```
### One-liner (Auto-install curl)
```bash
curl -sSL https://raw.githubusercontent.com/sorglos-it/ulh/main/install.sh | bash && cd ~/ulh && bash ulh.sh
```

### Manual Install
```bash
git clone https://github.com/sorglos-it/ulh.git
cd ulh
bash ulh.sh
```

> **Deploy by cloning, not by copying.** Copying the files from a Windows machine
> (SMB, SCP, rsync from a checked-out working copy) can carry CRLF line endings
> along, and the target then fails with `/bin/bash^M: bad interpreter`. A clone is
> always LF (enforced by `.gitattributes`) and keeps the auto-update working.
> Already hit it? `find . -type f \( -name '*.sh' -o -name '*.yaml' \) -exec sed -i 's/\r$//' {} +`

## ✨ Features

- **Multi-Distribution** - Debian, Ubuntu, Red Hat, Arch, SUSE, Alpine, Proxmox
- **96 Scripts** - Network, system management, web servers, databases, languages, tools
- **Search** - Press `s` (or type `/term`) in any menu, jump straight to the script's actions
- **Auto-Updates** - Self-updates on startup with transparent restart
- **Custom Repos** - Clone your own script repositories with git authentication (SSH, Token, Basic Auth)
- **Per-Action Automation** - answer.yaml enables automated execution for specific script actions
- **Interactive Menu** - Clean, intuitive box-based CLI interface
- **All Distros** - Every script supports all 5 major distribution families
- **Zero Dependencies** - Just bash, git, and standard Linux tools

## 📖 Usage

```bash
cd ~/ulh
bash ulh.sh
```

Menu flow:
```
1. Repository Selector
   ├─ ulh Scripts
   │  └─ Categories
   │     └─ Scripts
   │        └─ Actions
   └─ Custom Repos
      └─ Scripts
         └─ Actions
```

### 🔎 Finding a script fast

Instead of walking the categories, press **`s`** in the repository, category or
script menu - or type **`/term`** directly at the prompt:

```
  Choose: /spool

+==============================================================================+
| Search: spool                                                                |
+==============================================================================+
|
|   1) spoolman         System Management          Spoolman filament spool ma..
|
+==============================================================================+
|  s) Search  (or /term)                                                       |
|  b) Back                                                                     |
|  q) Quit                                           ubuntu (debian) · v24.04  |
+==============================================================================+

  Choose: 1        -> straight into spoolman's actions, ready to run
```

Matches script name, description and category (case-insensitive), and only lists
scripts that work on your distribution. Picking a number jumps directly into that
script's action menu, so you can run it right away. `s` inside the results starts
a new search, `b` goes back.

## 🛠️ System Scripts (96)

See **[SCRIPTS.md](SCRIPTS.md)** for the complete reference and **[TREE.md](TREE.md)** for the file map (which script lives where, with actions and supported distros).

## ⚙️ Automation with answer.yaml

Define defaults and enable per-action automation:

```yaml
# custom/answer.yaml
scripts:
  ubuntu:
    install:
      - default: "no"               # Interactive: user sees prompt
    pro:
      autoscript: true              # Automated: no prompts
      answers:
        - default: "token123"
```

Works for both system and custom repo scripts. See **[DOCS.md](DOCS.md#automation)** for details.

## 🔧 Custom Repositories

Add your own script repositories with git authentication:

```yaml
# custom/repo.yaml
repositories:
  my-scripts:
    name: "My Custom Scripts"
    url: "git@github.com:user/my-scripts.git"
    path: "my-scripts"
    auth_method: "ssh"
    enabled:              # Show in menu
    auto_update:          # Auto-pull on startup
```

**Authentication Methods**: SSH (with custom/keys/), HTTPS Token, Basic Auth, or none.

See **[DOCS.md#custom-repositories](DOCS.md#custom-repositories)** for complete setup guide.

## 🏗️ Architecture

```
ulh/
├── ulh.sh                # Entry point (self-updating)
├── lib/                  # 7 focused libraries
├── scripts/              # 96 system management scripts + custom repos
├── custom/               # Your custom repos
├── config.yaml           # System scripts config
├── README.md             # This file
├── DOCS.md               # Comprehensive guide
├── SCRIPTS.md            # Script reference
└── TREE.md               # File map: what lives where
```

Full annotated tree with every script, its path, actions and distros: **[TREE.md](TREE.md)**.

## 📚 Documentation

- **[DOCS.md](DOCS.md)** - Complete guide: architecture, configuration, templates, troubleshooting
- **[SCRIPTS.md](SCRIPTS.md)** - All 96 scripts with categories and descriptions
- **[TREE.md](TREE.md)** - File map: paths, actions, sudo and distro support per script

## 🖥️ Supported Distributions

- ✅ Debian / Ubuntu / Linux Mint
- ✅ Red Hat / Fedora / CentOS / Rocky / AlmaLinux
- ✅ Arch / Manjaro
- ✅ SUSE / openSUSE
- ✅ Alpine
- ✅ Proxmox VE
- ⚠️ PiKVM v3 (Arch-based appliance, limited package management)

## 💾 Requirements

- Linux (any major distro)
- Bash 4.0+
- Git
- `sudo` access (for system-level operations)

## 🚀 Quick Start

1. **Install**: `bash install.sh` or clone repo
2. **Run**: `bash ulh.sh`
3. **Select**: Choose System Management or Custom Repo
4. **Navigate**: Category → Script → Action
5. **Configure**: Follow prompts (or accept defaults)

## 🔐 Security

- Scripts run **individually with sudo** (ulh stays unprivileged)
- SSH keys stored in **custom/keys/** (protected by .gitignore)
- No hardcoded credentials (use environment variables)
- All scripts pass **syntax validation** (bash -n)

## 📝 Creating Custom Scripts

To add scripts to your custom repository:

```bash
mkdir -p custom/myrepo/scripts
cp scripts/_template.sh custom/myrepo/scripts/my-script.sh
```

See **[DOCS.md - Script Development](DOCS.md#script-development)** for detailed guide and how to integrate custom repositories.

## 🤝 Contributing

Contributions welcome! See **[DOCS.md](DOCS.md)** for script development guidelines.

## 📄 License

MIT License - Free for personal and commercial use

---

**Questions?** Check **[DOCS.md](DOCS.md)** or open an issue on GitHub.

## 💝 Support ulh

If ulh helps you save time and reduces your Linux headaches, consider supporting the project:

[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=6CDEVZGJWTNQQ)

## 📖 The Story Behind ulh

Curious how "unknown linux helper" came to be? Read **[BACKSTORY.md](BACKSTORY.md)** — the chaotic naming odyssey featuring Kevin, the Unknown Man, and why naming things is impossible.

---

**GitHub**: https://github.com/sorglos-it/ulh
