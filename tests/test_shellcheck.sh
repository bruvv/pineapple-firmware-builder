#!/bin/sh
SCRIPT_DIR="$(dirname "$0")"
shellcheck -S error "$SCRIPT_DIR/../build_pineapple.sh"
