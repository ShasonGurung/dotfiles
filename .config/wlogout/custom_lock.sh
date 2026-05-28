#!/usr/bin/env bash

set -euo pipefail

if ! command -v swaylock >/dev/null 2>&1; then
  exit 0
fi

if pgrep -x swaylock >/dev/null 2>&1; then
  exit 0
fi

exec swaylock --daemonize \
  --color 0b0f14 \
  --font "JetBrainsMono Nerd Font" \
  --font-size 15 \
  --indicator-idle-visible \
  --indicator-radius 100 \
  --indicator-thickness 7 \
  --show-failed-attempts \
  --indicator-caps-lock \
  --ring-color 7dcfffcc \
  --ring-clear-color f2d579cc \
  --ring-ver-color a6da95cc \
  --ring-wrong-color ed8796cc \
  --key-hl-color a6da95cc \
  --bs-hl-color f5a97fcc \
  --inside-color 1a212bcc \
  --inside-clear-color 2d3a4bcc \
  --inside-ver-color 1f3d2ecc \
  --inside-wrong-color 4a2230cc \
  --line-color 4c566a88 \
  --line-clear-color f2d579cc \
  --line-ver-color a6da95cc \
  --line-wrong-color ed8796cc \
  --separator-color 00000000 \
  --text-color cad3f5ff \
  --text-clear-color f2d579ff \
  --text-ver-color a6da95ff \
  --text-wrong-color ed8796ff
