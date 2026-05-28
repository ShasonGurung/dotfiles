#!/usr/bin/env bash

set -euo pipefail

LIVE_DIR="$HOME/.config/Wallpapers/Live"
STATIC_DIR="$HOME/.config/Wallpapers/Static"
AZOTE_RESTORE="$HOME/.azotebg"
STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="$STATE_DIR/sway-wallpaper-mode"
LOG_FILE="$STATE_DIR/sway-wallpaper.log"

log() {
    mkdir -p "$STATE_DIR"
    printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG_FILE"
}

notify() {
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u low -t 2000 "Wallpaper Engine" "$1"
    fi
}

pick_random_file() {
    local directory="$1"
    local -a files=()

    [[ -d "$directory" ]] || return 1

    while IFS= read -r file; do
        files+=("$file")
    done < <(find "$directory" -maxdepth 1 -type f | sort)

    [[ "${#files[@]}" -gt 0 ]] || return 1

    printf '%s\n' "${files[RANDOM % ${#files[@]}]}"
}

set_mode() {
    mkdir -p "$STATE_DIR"
    printf '%s\n' "$1" >"$STATE_FILE"
}

restore_static_wallpaper() {
    local static_wallpaper=""

    log "restore_static_wallpaper"
    static_wallpaper="$(pick_random_file "$STATIC_DIR" || true)"

    if [[ -f "$AZOTE_RESTORE" ]]; then
        sh "$AZOTE_RESTORE"
        notify "Static Wallpaper Restored"
        set_mode "static"
        return 0
    fi

    if [[ -n "$static_wallpaper" ]] && command -v swaymsg >/dev/null 2>&1; then
        pkill -x swaybg 2>/dev/null || true
        swaymsg output "*" bg "$static_wallpaper" fill >/dev/null 2>&1
        notify "Random Static Wallpaper Set"
        set_mode "static"
        return 0
    fi

    if command -v swaybg >/dev/null 2>&1; then
        if [[ -n "$static_wallpaper" ]]; then
            pkill -x swaybg 2>/dev/null || true
            swaybg -i "$static_wallpaper" -m fill >/dev/null 2>&1 &
            notify "Random Static Wallpaper Set"
            set_mode "static"
            return 0
        fi
    fi

    if command -v azote >/dev/null 2>&1; then
        azote --random
        notify "Random Static Wallpaper Set"
        set_mode "static"
        return 0
    fi

    notify "No static wallpaper restore method available"
    return 1
}

stop_wallpaper() {
    log "stop_wallpaper"
    if pgrep -x "mpvpaper" >/dev/null; then
        killall mpvpaper 2>/dev/null
    fi

    restore_static_wallpaper
}

start_wallpaper() {
    local live_wallpaper

    log "start_wallpaper"
    if [[ ! -d "$LIVE_DIR" ]]; then
        log "live directory missing: $LIVE_DIR"
        notify "Live wallpaper directory not found"
        exit 1
    fi

    if ! command -v mpvpaper >/dev/null 2>&1; then
        log "mpvpaper not installed or not in PATH"
        notify "mpvpaper is not installed"
        exit 1
    fi

    pkill -x mpvpaper 2>/dev/null || true
    pkill -x swaybg 2>/dev/null || true
    pkill -x wbg 2>/dev/null || true

    sleep 0.3

    live_wallpaper="$(pick_random_file "$LIVE_DIR" || true)"
    if [[ -z "$live_wallpaper" ]]; then
        log "no live wallpapers found in $LIVE_DIR"
        notify "No live wallpapers found"
        exit 1
    fi

    log "starting mpvpaper with $live_wallpaper"
    mpvpaper -o "no-audio loop --hwdec=auto --profile=fast" "*" "$live_wallpaper" &
    set_mode "live"
    notify "Live Wallpaper Started"
}

toggle_wallpaper() {
    log "toggle_wallpaper"
    if pgrep -x "mpvpaper" > /dev/null; then
        stop_wallpaper
    else
        start_wallpaper
    fi
}

action="${1:-}"
log "invoked with action=${action:-<empty>}"

case "$action" in
    start)  start_wallpaper ;;
    stop)   stop_wallpaper ;;
    toggle) toggle_wallpaper ;;
    *)      echo "Usage: $0 {start|stop|toggle}" >&2; exit 1 ;;
esac
