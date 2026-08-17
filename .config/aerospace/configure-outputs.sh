#!/usr/bin/env bash

set -euo pipefail

AEROSPACE="${AEROSPACE:-aerospace}"

monitors="$("$AEROSPACE" list-monitors)"
monitor_count="$(printf '%s\n' "$monitors" | wc -l | tr -d ' ')"

has_builtin=false

if printf '%s\n' "$monitors" | grep -qi 'built-in'; then
    has_builtin=true
fi

move_workspace() {
    local workspace="$1"
    local monitor="$2"

    "$AEROSPACE" move-workspace-to-monitor \
        --workspace "$workspace" \
        "$monitor"
}

if [[ "$monitor_count" -gt 1 && "$has_builtin" == true ]]; then
    # Laptop open + external display.
    #
    # 1-7 -> external
    # 8,9,0 -> built-in

    for workspace in 1 2 3 4 5 6 7; do
        move_workspace "$workspace" secondary
    done

    for workspace in 8 9 0; do
        move_workspace "$workspace" main
    done
else
    # Single display: laptop-only OR clamshell.
    for workspace in 1 2 3 4 5 6 7 8 9 0; do
        move_workspace "$workspace" main
    done
fi
