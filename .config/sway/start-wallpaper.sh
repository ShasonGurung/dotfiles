#!/bin/bash
PIDFILE=/tmp/live-mpv.pid

start_mpv() {
    if [ ! -f "$PIDFILE" ] || ! kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        mpv --fs --no-audio --loop-playlist --shuffle "$HOME/.config/Wallpapers/Live/" &
        echo $! > "$PIDFILE"
    fi
}

stop_mpv() {
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null
        rm -f "$PIDFILE"
    fi
}

case "$1" in
    start) start_mpv ;;
    stop) stop_mpv ;;
    idle)
        swayidle \
            timeout 180 "$0 start" \
            timeout 600 "$0 stop; swaylock -f; swaymsg 'output * dpms off'" \
            resume "$0 stop; swaymsg 'output * dpms on'" \
            before-sleep "$0 stop; swaylock -f"
        ;;
esac
