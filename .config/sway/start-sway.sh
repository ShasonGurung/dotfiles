#!/usr/bin/env bash

set -euo pipefail

export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}"
export MOZ_ENABLE_WAYLAND="${MOZ_ENABLE_WAYLAND:-1}"
export MOZ_WEBRENDER="${MOZ_WEBRENDER:-1}"
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"

exec sway
