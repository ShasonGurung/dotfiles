#!/usr/bin/env bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
    exit 0
fi

if ! command -v "$1" >/dev/null 2>&1; then
    exit 0
fi

exec "$@"
