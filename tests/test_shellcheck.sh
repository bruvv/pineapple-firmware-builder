#!/bin/sh
SCRIPT_DIR="$(dirname "$0")"
shellcheck -S warning "$SCRIPT_DIR/../build_pineapple.sh"
