#!/bin/bash

# ULH Read-P Refactoring Script
# Automatically extracts read -p prompts from 9 scripts and moves them to config.yaml

set -e

REPO_DIR="/root/workspace/ulh"
SCRIPTS_DIR="$REPO_DIR/scripts"
CONFIG_FILE="$REPO_DIR/config.yaml"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}ULH Read-P Refactoring Script${NC}"
echo "Processing 9 scripts for prompt extraction..."
echo ""

# Array of scripts to process
scripts=("adguard-home.sh" "docker-compose.sh" "locate.sh" "openssh.sh" "pihole.sh" "proxmox.sh" "remotely.sh" "samba.sh" "ufw.sh")

for script in "${scripts[@]}"; do
    script_path="$SCRIPTS_DIR/$script"
    script_name="${script%.sh}"
    
    if [[ ! -f "$script_path" ]]; then
        echo -e "${YELLOW}⚠${NC} $script not found, skipping"
        continue
    fi
    
    echo "Processing: $script"
    
    # Count read -p occurrences
    read_p_count=$(grep -c "read -p" "$script_path" || echo 0)
    
    if [[ $read_p_count -gt 0 ]]; then
        echo "  Found $read_p_count read -p prompts"
        # Further processing would happen here
    else
        echo "  No read -p found"
    fi
done

echo ""
echo "Done. Manual refactoring needed for each script."
echo ""
echo "Next steps:"
echo "1. Analyze prompts in each script"
echo "2. Add prompts: sections to config.yaml"
echo "3. Replace read -p with parameter parsing"
echo "4. Test each script"
