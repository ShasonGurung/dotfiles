#!/bin/bash

# Environment setup
export PATH=/usr/local/bin:/usr/bin:/bin:$PATH
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=/run/user/$(id -u)

LIVE_DIR="$HOME/.config/Wallpapers/Live"
AZOTE_RESTORE="$HOME/.azotebg"

# Helper for notifications
notify() {
    if command -v notify-send >/dev/null; then
        notify-send -u low -t 2000 "Wallpaper Engine" "$1"
    fi
}

stop_wallpaper() {
    if pgrep -x "mpvpaper" > /dev/null; then
        killall mpvpaper 2>/dev/null
        
        # Restore the static wallpaper
        if [ -f "$AZOTE_RESTORE" ]; then
            bash "$AZOTE_RESTORE"
            notify "Static Wallpaper Restored"
        else
            # Fallback if the restore script isn't found
            azote --random
            notify "Live Wallpaper Stopped (Random Static Set)"
        fi
    fi
}

start_wallpaper() {
    # Ensure no existing mpvpaper is running
    pkill -x mpvpaper 2>/dev/null
    
    # Kill common static wallpaper setters to prevent overlapping/clipping
    pkill -x swaybg 2>/dev/null
    pkill -x wbg 2>/dev/null

    sleep 0.3

    # Start mpvpaper
    mpvpaper -o "no-audio loop --shuffle --hwdec=auto --profile=fast" "*" "$LIVE_DIR" &
    notify "Live Wallpaper Started"
}

toggle_wallpaper() {
    if pgrep -x "mpvpaper" > /dev/null; then
        stop_wallpaper
    else
        start_wallpaper
    fi
}

case "$1" in
    start)  start_wallpaper ;;
    stop)   stop_wallpaper ;;
    toggle) toggle_wallpaper ;;
    *)      echo "Usage: $0 {start|stop|toggle}" ;;
esac
