#!/bin/bash

# spoolman - Spoolman filament spool management (Donkie/Spoolman)
# Detect, back up and completely remove standalone, /opt and Docker installs
# Actions: detect | backup | uninstall
#
# Variables (from config.yaml prompts):
#   TARGET_USER      owner of the Spoolman install (default: SUDO_USER)
#   PURGE            yes = also delete database, data, images, volumes
#   CLEAN_MOONRAKER  yes = comment out [spoolman] sections in moonraker.conf
#   DO_BACKUP        yes = tar/SQLite backup before removal

set -eo pipefail
source "$(dirname "$0")/../lib/bootstrap.sh"
# Script entscheidet selbst wann geparst werden soll:
parse_parameters "$1"

# ============================================================
# DEFAULTS
# ============================================================

SPOOLMAN_PORT="${SPOOLMAN_PORT:-7912}"
TARGET_USER="${TARGET_USER:-${SUDO_USER:-$USER}}"
PURGE="${PURGE:-no}"
CLEAN_MOONRAKER="${CLEAN_MOONRAKER:-no}"
DO_BACKUP="${DO_BACKUP:-yes}"
TS="$(date +%Y%m%d-%H%M%S)"

HOME_DIR=""
BACKUP_DIR=""
ERRORS=0
DISCOVERED=0

UNITS=(); UUNITS=(); DIRS=(); DATA=(); ENVS=()
CONTAINERS=(); IMAGES=(); VOLUMES=(); COMPOSE=(); MOONCONF=()

# ============================================================
# HELPERS
# ============================================================

resolve_user() {
    HOME_DIR="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
    if [[ -z "$HOME_DIR" || ! -d "$HOME_DIR" ]]; then
        log_error "No home directory for user: $TARGET_USER"
    fi
    BACKUP_DIR="${BACKUP_DIR:-$HOME_DIR/spoolman-backup}"
}

# systemctl --user for the target user, also works when running via sudo
uctl() {
    local uid
    uid="$(id -u "$TARGET_USER")"
    if [[ "$(id -un)" == "$TARGET_USER" ]]; then
        systemctl --user "$@"
    else
        sudo -u "$TARGET_USER" \
            env "XDG_RUNTIME_DIR=/run/user/${uid}" \
                "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${uid}/bus" \
            systemctl --user "$@"
    fi
}

# read a value from a Spoolman .env file, quotes and comments stripped
env_val() {
    local file="$1" key="$2" v
    v="$(awk -F= -v k="$key" '$1==k{sub(/^[^=]*=/,"");print;exit}' "$file" 2>/dev/null || true)"
    v="${v%%#*}"; v="${v%\"}"; v="${v#\"}"; v="${v%\'}"; v="${v#\'}"
    printf '%s' "${v//[[:space:]]/}"
}

# rm -rf with a blacklist for critical paths
safe_rm() {
    local path="$1"
    case "$path" in
        /|/home|/opt|/root|/usr|/var|"$HOME_DIR"|"$HOME_DIR/.local"|"$HOME_DIR/.local/share")
            log_error "Refusing to delete critical path: $path"
            ;;
    esac
    if ! rm -rf -- "$path"; then
        log_warn "Failed to delete: $path"
        ERRORS=$((ERRORS + 1))
    fi
}

# ============================================================
# DISCOVERY
# ============================================================

discover() {
    resolve_user
    DISCOVERED=1

    mapfile -t UNITS < <(find /etc/systemd/system /lib/systemd/system /usr/lib/systemd/system \
        -maxdepth 1 -iname 'spoolman*.service' 2>/dev/null | sort -u || true)
    mapfile -t UUNITS < <(find "$HOME_DIR/.config/systemd/user" \
        -maxdepth 1 -iname 'spoolman*.service' 2>/dev/null | sort -u || true)

    local d
    for d in "$HOME_DIR"/Spoolman "$HOME_DIR"/Spoolman-* "$HOME_DIR"/spoolman \
             /opt/spoolman /opt/Spoolman "$HOME_DIR"/printer_data/spoolman; do
        [[ -d "$d" ]] || continue
        if [[ -d "$d/.venv" || -f "$d/scripts/install.sh" || -f "$d/.env" || -f "$d/docker-compose.yml" ]]; then
            DIRS+=("$d")
            if [[ -f "$d/.env" ]]; then
                ENVS+=("$d/.env")
            fi
        fi
    done

    if [[ -d "$HOME_DIR/.local/share/spoolman" ]]; then
        DATA+=("$HOME_DIR/.local/share/spoolman")
    fi
    local e k v
    for e in "${ENVS[@]}"; do
        for k in SPOOLMAN_DIR_DATA SPOOLMAN_DIR_BACKUPS SPOOLMAN_DIR_LOGS; do
            v="$(env_val "$e" "$k")"
            if [[ -n "$v" && -d "$v" ]]; then
                DATA+=("$v")
            fi
        done
    done
    if [[ ${#DATA[@]} -gt 0 ]]; then
        mapfile -t DATA < <(printf '%s\n' "${DATA[@]}" | awk 'NF && !seen[$0]++')
    fi

    if command_exists docker && docker info &>/dev/null; then
        mapfile -t CONTAINERS < <(docker ps -a --format '{{.Names}}\t{{.Image}}' 2>/dev/null \
            | grep -Ei 'spoolman' | cut -f1 || true)
        mapfile -t IMAGES < <(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null \
            | grep -Ei 'spoolman' || true)
        mapfile -t VOLUMES < <(docker volume ls --format '{{.Name}}' 2>/dev/null \
            | grep -Ei 'spoolman' || true)
        mapfile -t COMPOSE < <(find "$HOME_DIR" /opt -maxdepth 3 \
            \( -name 'docker-compose.y*ml' -o -name 'compose.y*ml' \) 2>/dev/null \
            | xargs -r grep -lEi 'donkie/spoolman' 2>/dev/null | sort -u || true)
    fi

    mapfile -t MOONCONF < <(find "$HOME_DIR" -maxdepth 4 -name 'moonraker.conf' 2>/dev/null \
        | xargs -r grep -lE '^\[(spoolman|update_manager spoolman)\]' 2>/dev/null | sort -u || true)
}

found_count() {
    echo $(( ${#UNITS[@]} + ${#UUNITS[@]} + ${#DIRS[@]} + ${#DATA[@]} \
           + ${#CONTAINERS[@]} + ${#COMPOSE[@]} ))
}

show_findings() {
    local f
    log_section "Spoolman installation (user: $TARGET_USER)"
    printf "  %-20s %s\n" "system units:"     "${#UNITS[@]}"
    printf "  %-20s %s\n" "user units:"       "${#UUNITS[@]}"
    printf "  %-20s %s\n" "install dirs:"     "${#DIRS[@]}"
    printf "  %-20s %s\n" "data dirs:"        "${#DATA[@]}"
    printf "  %-20s %s\n" "docker container:" "${#CONTAINERS[@]}"
    printf "  %-20s %s\n" "docker images:"    "${#IMAGES[@]}"
    printf "  %-20s %s\n" "docker volumes:"   "${#VOLUMES[@]}"
    printf "  %-20s %s\n" "compose files:"    "${#COMPOSE[@]}"
    printf "  %-20s %s\n" "moonraker.conf:"   "${#MOONCONF[@]}"
    for f in "${UNITS[@]}" "${UUNITS[@]}" "${DIRS[@]}" "${DATA[@]}" \
             "${COMPOSE[@]}" "${MOONCONF[@]}"; do
        printf "    - %s\n" "$f"
    done
}

# ============================================================
# ACTIONS
# ============================================================

detect_spoolman() {
    discover
    show_findings
    if [[ "$(found_count)" -eq 0 ]]; then
        log_info "No Spoolman installation found"
    else
        log_info "Detection complete - nothing was changed"
    fi
}

backup_spoolman() {
    if [[ "$DISCOVERED" -eq 0 ]]; then
        discover
    fi

    local src=() c db
    src+=("${DATA[@]}" "${ENVS[@]}" "${UNITS[@]}" "${UUNITS[@]}" "${COMPOSE[@]}" "${MOONCONF[@]}")
    for c in "${COMPOSE[@]}"; do
        if [[ -d "$(dirname "$c")/data" ]]; then
            src+=("$(dirname "$c")/data")
        fi
    done

    if [[ ${#src[@]} -eq 0 ]]; then
        log_warn "Nothing to back up"
        return 0
    fi

    log_section "Backup"
    mkdir -p "$BACKUP_DIR" || log_error "Cannot create backup directory: $BACKUP_DIR"

    # consistent SQLite copy while the service may still be running
    if command_exists sqlite3 && [[ ${#DATA[@]} -gt 0 ]]; then
        while read -r db; do
            [[ -n "$db" ]] || continue
            if sqlite3 "$db" ".backup '${BACKUP_DIR}/spoolman-${TS}.db'"; then
                log_info "SQLite dump: ${BACKUP_DIR}/spoolman-${TS}.db"
            else
                log_warn "SQLite dump failed: $db"
            fi
        done < <(find "${DATA[@]}" -maxdepth 2 -name 'spoolman.db' 2>/dev/null || true)
    fi

    tar --ignore-failed-read -czf "${BACKUP_DIR}/spoolman-${TS}.tgz" -- "${src[@]}" \
        || log_error "Backup failed"
    log_info "Backup: ${BACKUP_DIR}/spoolman-${TS}.tgz"
}

remove_services() {
    if [[ ${#UNITS[@]} -eq 0 && ${#UUNITS[@]} -eq 0 ]]; then
        return 0
    fi
    log_section "Services"

    local u n
    for u in "${UUNITS[@]}"; do
        n="$(basename "$u")"
        log_info "Removing user unit: $n"
        uctl stop "$n" 2>/dev/null || true
        uctl disable "$n" 2>/dev/null || true
        rm -f -- "$u" || log_warn "Failed to delete: $u"
    done
    if [[ ${#UUNITS[@]} -gt 0 ]]; then
        uctl daemon-reload 2>/dev/null || true
        uctl reset-failed 2>/dev/null || true
    fi

    for u in "${UNITS[@]}"; do
        n="$(basename "$u")"
        log_info "Removing system unit: $n"
        systemctl stop "$n" 2>/dev/null || true
        systemctl disable "$n" 2>/dev/null || true
        rm -f -- "$u" || log_warn "Failed to delete: $u"
    done
    if [[ ${#UNITS[@]} -gt 0 ]]; then
        systemctl daemon-reload || true
        systemctl reset-failed || true
    fi

    if pgrep -f 'spoolman.main:app' &>/dev/null; then
        log_warn "Killing leftover uvicorn worker(s)"
        pkill -f 'spoolman.main:app' || true
    fi
    return 0
}

remove_docker() {
    if [[ ${#CONTAINERS[@]} -eq 0 && ${#COMPOSE[@]} -eq 0 ]]; then
        return 0
    fi
    log_section "Docker"

    local c i v
    for c in "${COMPOSE[@]}"; do
        log_info "compose down: $c"
        if [[ "$PURGE" == "yes" ]]; then
            docker compose -f "$c" down -v --remove-orphans || log_warn "compose down failed: $c"
        else
            docker compose -f "$c" down --remove-orphans || log_warn "compose down failed: $c"
        fi
    done
    for c in "${CONTAINERS[@]}"; do
        log_info "Removing container: $c"
        docker rm -f -- "$c" &>/dev/null || log_warn "Failed to remove container: $c"
    done

    if [[ "$PURGE" == "yes" ]]; then
        for i in "${IMAGES[@]}"; do
            docker rmi -f -- "$i" &>/dev/null || log_warn "Failed to remove image: $i"
        done
        for v in "${VOLUMES[@]}"; do
            docker volume rm -f -- "$v" &>/dev/null || log_warn "Failed to remove volume: $v"
        done
    else
        log_info "Docker images and volumes kept (PURGE=no)"
    fi
    return 0
}

remove_files() {
    log_section "Files"
    local d
    for d in "${DIRS[@]}"; do
        log_info "Removing: $d"
        safe_rm "$d"
    done

    if [[ "$PURGE" == "yes" ]]; then
        for d in "${DATA[@]}"; do
            log_warn "Deleting data: $d"
            safe_rm "$d"
        done
    elif [[ ${#DATA[@]} -gt 0 ]]; then
        log_info "Database kept: ${DATA[*]}"
    fi
}

clean_moonraker() {
    if [[ ${#MOONCONF[@]} -eq 0 ]]; then
        return 0
    fi

    local m tmp
    if [[ "$CLEAN_MOONRAKER" != "yes" ]]; then
        for m in "${MOONCONF[@]}"; do
            log_warn "Still references spoolman: $m"
        done
        return 0
    fi

    log_section "Moonraker"
    for m in "${MOONCONF[@]}"; do
        cp -a -- "$m" "${m}.bak-${TS}" || log_error "Cannot back up: $m"
        tmp="$(mktemp)"
        awk '
            /^[[:space:]]*\[/ { sec = ($0 ~ /^[[:space:]]*\[(spoolman|update_manager[[:space:]]+spoolman)\][[:space:]]*$/) ? 1 : 0 }
            { print (sec ? "#" $0 : $0) }
        ' "$m" > "$tmp" && cat -- "$tmp" > "$m"
        rm -f -- "$tmp"
        log_info "Patched: $m (backup: ${m}.bak-${TS})"
    done
    log_warn "Restart moonraker to apply: systemctl restart moonraker"
}

uninstall_spoolman() {
    discover
    show_findings

    if [[ "$(found_count)" -eq 0 ]]; then
        log_info "No Spoolman installation found - nothing to do"
        return 0
    fi

    if [[ "$PURGE" == "yes" ]]; then
        log_warn "PURGE=yes - database and data directories will be deleted"
    fi
    if [[ "$DO_BACKUP" == "yes" ]]; then
        backup_spoolman
    else
        log_warn "Backup skipped (DO_BACKUP=$DO_BACKUP)"
    fi

    remove_services
    remove_docker
    remove_files
    clean_moonraker

    log_section "Result"
    if command_exists ss && ss -ltn "sport = :${SPOOLMAN_PORT}" 2>/dev/null | grep -q ":${SPOOLMAN_PORT}"; then
        log_warn "Port ${SPOOLMAN_PORT} is still in use"
    fi
    if systemctl list-units --all 2>/dev/null | grep -qi 'spoolman'; then
        log_warn "systemd still knows a spoolman unit"
    fi

    if [[ "$ERRORS" -gt 0 ]]; then
        log_error "Finished with $ERRORS failed step(s)"
    fi

    if [[ "$PURGE" == "yes" ]]; then
        log_info "Spoolman completely uninstalled (data deleted)!"
    else
        log_info "Spoolman uninstalled (data preserved)!"
    fi
}

# ============================================================
# MAIN
# ============================================================

case "$ACTION" in
    detect)
        detect_spoolman
        ;;
    backup)
        discover
        backup_spoolman
        ;;
    uninstall)
        uninstall_spoolman
        ;;
    *)
        print_usage spoolman && exit 1
        ;;
esac
