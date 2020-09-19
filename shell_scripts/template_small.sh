#!/bin/bash

set -euo pipefail

# 色付きの echo
function cecho() {
    local color_name color
    readonly color_name="$1"
    shift
    case $color_name in
        red) color=31 ;;
        green) color=32 ;;
        yellow) color=33 ;;
        blue) color=34 ;;
        cyan) color=36 ;;
        *) error_exit "An undefined color was specified." ;;
    esac
    printf "\033[${color}m%b\033[m\n" "$*"
}

# このスクリプト自身のディレクトリに移動する
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"


function main() {
    cecho cyan "hello"

    exit 0
}

main