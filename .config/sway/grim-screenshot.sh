#!/usr/bin/env bash

set -euo pipefail

directory="${XDG_SCREENSHOTS_DIR:-$HOME/Downloads/Screenshots}"
filename="$(date +%Y-%m-%d-%H%M%S).png"

mkdir -p "$directory"
grim -g "$(slurp)" "$directory/$filename"
