#!/bin/bash

# Extract read -p prompts from scripts and generate YAML format

SCRIPTS_DIR="/root/workspace/ulh/scripts"

scripts=("adguard-home" "docker-compose" "locate" "openssh" "pihole" "proxmox" "remotely" "samba" "ufw")

for script_name in "${scripts[@]}"; do
    script_file="$SCRIPTS_DIR/$script_name.sh"
    
    if [[ ! -f "$script_file" ]]; then
        continue
    fi
    
    echo "=== $script_name.sh ==="
    
    # Extract all read -p lines with context
    grep -n "read -p" "$script_file" | while IFS=':' read -r line_num line_content; do
        # Extract question text (between "read -p" and the first quote)
        question=$(echo "$line_content" | sed 's/.*read -p "\([^"]*\).*/\1/')
        echo "Line $line_num: $question"
    done
    
    echo ""
done
