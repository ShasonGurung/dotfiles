#!/usr/bin/env bash

set -euo pipefail

local_env="$HOME/.config/sway/local/outputs.env"
[[ -f "$local_env" ]] && . "$local_env"

profile_name="${SWAY_OUTPUT_PROFILE:-auto}"
profile_dir="$HOME/.config/sway/local/profiles"
profile_env="$profile_dir/${profile_name}.env"
if [[ "$profile_name" != "auto" && -f "$profile_env" ]]; then
    . "$profile_env"
fi

require_cmd() {
    command -v "$1" >/dev/null 2>&1
}

if ! require_cmd swaymsg || ! require_cmd jq; then
    exit 0
fi

outputs_json="$(swaymsg -t get_outputs -r 2>/dev/null || true)"
[[ -n "$outputs_json" ]] || exit 0

active_outputs="$(printf '%s\n' "$outputs_json" | jq '[.[] | select(.active == true)]')"
active_count="$(printf '%s\n' "$active_outputs" | jq 'length')"
[[ "$active_count" -gt 0 ]] || exit 0

internal_regex="${SWAY_INTERNAL_REGEX:-^(eDP|LVDS)}"
workspace_count="${SWAY_WORKSPACE_COUNT:-10}"
layout="${SWAY_OUTPUT_LAYOUT:-auto}"

internal_name="$(printf '%s\n' "$active_outputs" | jq -r --arg re "$internal_regex" 'map(select(.name | test($re))) | .[0].name // empty')"
external_name="$(printf '%s\n' "$active_outputs" | jq -r --arg re "$internal_regex" 'map(select(.name | test($re) | not)) | .[0].name // empty')"

output_width() {
    local output_name="$1"
    printf '%s\n' "$active_outputs" | jq -r --arg name "$output_name" 'map(select(.name == $name)) | .[0].rect.width // 0'
}

output_height() {
    local output_name="$1"
    printf '%s\n' "$active_outputs" | jq -r --arg name "$output_name" 'map(select(.name == $name)) | .[0].rect.height // 0'
}

run_sway() {
    swaymsg "$@" >/dev/null
}

focused_workspace() {
    swaymsg -t get_workspaces -r 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -n1
}

disable_output() {
    local output_name="$1"
    [[ -n "$output_name" ]] || return 0
    run_sway output "$output_name" disable
}

apply_output_defaults() {
    local output_name="$1"
    [[ -n "$output_name" ]] || return 0

    run_sway output "$output_name" enable

    if [[ -n "${SWAY_SCALE:-}" ]]; then
        run_sway output "$output_name" scale "$SWAY_SCALE"
    fi

    if [[ -n "${SWAY_SCALE_FILTER:-}" ]]; then
        run_sway output "$output_name" scale_filter "$SWAY_SCALE_FILTER"
    fi
}

apply_output_overrides() {
    local output_name="$1"
    local mode_var="$2"
    local scale_var="$3"
    local transform_var="$4"

    [[ -n "$output_name" ]] || return 0

    if [[ -n "${!mode_var:-}" ]]; then
        run_sway output "$output_name" mode "${!mode_var}"
    fi

    if [[ -n "${!scale_var:-}" ]]; then
        run_sway output "$output_name" scale "${!scale_var}"
    fi

    if [[ -n "${!transform_var:-}" ]]; then
        run_sway output "$output_name" transform "${!transform_var}"
    fi
}

map_workspaces_to_outputs() {
    local primary="$1"
    local secondary="${2:-}"
    [[ -n "$primary" ]] || return 0

    local current_workspace
    current_workspace="$(focused_workspace || true)"

    local i target
    for i in $(seq 1 "$workspace_count"); do
        target="$primary"
        if [[ -n "$secondary" && " ${SWAY_SECONDARY_WORKSPACES:-} " == *" $i "* ]]; then
            target="$secondary"
        fi
        run_sway workspace "$i" output "$target"
        run_sway workspace number "$i"
        run_sway move workspace to output "$target"
    done

    if [[ -n "$current_workspace" ]]; then
        run_sway workspace "$current_workspace"
    fi
}

apply_single_output() {
    local output_name="$1"
    local disable_name="${2:-}"
    [[ -n "$output_name" ]] || return 0

    apply_output_defaults "$output_name"
    apply_output_overrides "$output_name" SWAY_PRIMARY_MODE SWAY_PRIMARY_SCALE SWAY_PRIMARY_TRANSFORM
    run_sway output "$output_name" pos 0 0
    disable_output "$disable_name"
    map_workspaces_to_outputs "$output_name"
}

apply_dual_vertical_stack() {
    local top_output="$1"
    local bottom_output="$2"
    [[ -n "$top_output" && -n "$bottom_output" ]] || return 0

    local top_width top_height bottom_width bottom_x
    top_width="$(output_width "$top_output")"
    top_height="$(output_height "$top_output")"
    bottom_width="$(output_width "$bottom_output")"
    bottom_x=$(( (top_width - bottom_width) / 2 ))
    if (( bottom_x < 0 )); then
        bottom_x=0
    fi

    apply_output_defaults "$top_output"
    apply_output_defaults "$bottom_output"
    apply_output_overrides "$top_output" SWAY_EXTERNAL_MODE SWAY_EXTERNAL_SCALE SWAY_PRIMARY_TRANSFORM
    apply_output_overrides "$bottom_output" SWAY_INTERNAL_MODE SWAY_INTERNAL_SCALE SWAY_SECONDARY_TRANSFORM

    run_sway output "$top_output" pos 0 0
    run_sway output "$bottom_output" pos "$bottom_x" "$top_height"

    map_workspaces_to_outputs "$top_output" "$bottom_output"
}

apply_dual_horizontal_stack() {
    local left_output="$1"
    local right_output="$2"
    [[ -n "$left_output" && -n "$right_output" ]] || return 0

    local left_width
    left_width="$(output_width "$left_output")"

    apply_output_defaults "$left_output"
    apply_output_defaults "$right_output"
    apply_output_overrides "$left_output" SWAY_EXTERNAL_MODE SWAY_EXTERNAL_SCALE SWAY_PRIMARY_TRANSFORM
    apply_output_overrides "$right_output" SWAY_INTERNAL_MODE SWAY_INTERNAL_SCALE SWAY_SECONDARY_TRANSFORM

    run_sway output "$left_output" pos 0 "${SWAY_PRIMARY_Y:-0}"
    run_sway output "$right_output" pos "$left_width" "${SWAY_SECONDARY_Y:-0}"

    map_workspaces_to_outputs "$left_output" "$right_output"
}

primary_name="${SWAY_PRIMARY_OUTPUT:-}"
secondary_name="${SWAY_SECONDARY_OUTPUT:-}"

if [[ -z "$primary_name" ]]; then
    if [[ -n "$external_name" ]]; then
        primary_name="$external_name"
    else
        primary_name="$internal_name"
    fi
fi

if [[ -z "$secondary_name" ]]; then
    if [[ "$primary_name" == "$external_name" ]]; then
        secondary_name="$internal_name"
    else
        secondary_name="$external_name"
    fi
fi

if [[ "$layout" == "single" ]]; then
    apply_single_output "$primary_name" "$secondary_name"
    exit 0
fi

if [[ "$active_count" -eq 1 ]]; then
    apply_single_output "$primary_name"
    exit 0
fi

if [[ "$layout" == "stack-horizontal" && -n "$primary_name" && -n "$secondary_name" ]]; then
    apply_dual_horizontal_stack "$primary_name" "$secondary_name"
    exit 0
fi

if [[ "$layout" == "stack-vertical" && -n "$primary_name" && -n "$secondary_name" ]]; then
    apply_dual_vertical_stack "$primary_name" "$secondary_name"
    exit 0
fi

if [[ -n "$internal_name" && -n "$external_name" ]]; then
    apply_dual_vertical_stack "$external_name" "$internal_name"
    exit 0
fi

if [[ -n "$external_name" ]]; then
    apply_single_output "$external_name" "$internal_name"
    exit 0
fi

if [[ -n "$internal_name" ]]; then
    apply_single_output "$internal_name" "$external_name"
fi
