#!/bin/bash

set -euo pipefail

# このスクリプト自身のディレクトリに移動する
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

SNIPPET=$1

while read line; do
    echo \"$line\",
done < <(sed -e 's/\"/\\\\\"/g' \
            -e 's/\(\\[0-9a-z]\)/\\\\\\\1/g' \
            -e 's/    /\\\\t/g' \
            -e 's/\$/\\\\\\\\$/g' \
            $SNIPPET)


# -e 's/\(\$[0-9]\)/\\\\\\\\\1/g' \
# -e 's/\"\$/\"\\\\\\\\\$/g' \
