#!/bin/bash

set -euo pipefail

function usage() {
    echo "Usage:"
    echo "  $(basename "${BASH_SOURCE[0]}") [options] [--] arg1 arg2"
    echo
    echo "Options:"
    echo "  --help, -h"
    echo "    This help."
}

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

# 引数を入れる配列を定義する
declare -a ARGS=()

# コマンドラインオプションをパースする
while (($# > 0)); do
    case "$1" in
        --help | -h)
            usage
            exit 0
            ;;
        --)
            # ダブルダッシュがあったら以降は引数とみなす
            shift
            while (($# > 0)); do
            ARGS+=("$1")
            shift
            done
            break
            ;;
        -*)
            cecho red "[ERROR] Illegal option: $1"
            exit 1
            ;;
        *)
            if [[ $1 != "" ]] && [[ ! $1 =~ ^-+ ]]; then
            ARGS+=("$1")
            fi
            shift
            ;;
    esac
done

# このスクリプト自身のディレクトリに移動する
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# スクリプト終了時に呼ばれるハンドラー関数
function on_exit() {
    local exit_code=$1
    # スクリプト終了時の後始末を行う場合はここに書く
    exit "$exit_code"
}

function main() {
    # スクリプト終了時のハンドラーを登録
    trap 'on_exit $?' EXIT

    cecho cyan "hello"
}

main
