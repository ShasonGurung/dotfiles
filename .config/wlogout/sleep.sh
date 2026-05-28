#!/usr/bin/env bash

set -euo pipefail

action="${1:-suspend}"
lock_script="${HOME}/.config/wlogout/custom_lock.sh"

case "$action" in
    suspend|hibernate)
        ;;
    *)
        echo "Usage: $0 {suspend|hibernate}" >&2
        exit 1
        ;;
esac

if [ -x "$lock_script" ] && ! pgrep -x swaylock >/dev/null 2>&1; then
    "$lock_script"
    # Give swaylock a moment to present before sleeping.
    sleep 1
fi

systemctl "$action"
