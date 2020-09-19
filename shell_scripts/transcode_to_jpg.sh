#!/bin/bash

set -euo pipefail

# このスクリプト自身が置かれているディレクトリに移動する
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd thumb/

for f in *;
do
    echo "${f%.*}.${f##*.}"
    if [[ "${f##*.}" = "webp" ]]; then
        ffmpeg -i "${f%.*}.${f##*.}" ../img/"${f%.*}.jpg"
    elif [[ "${f##*.}" = "png" ]]; then
        ffmpeg -i "${f%.*}.${f##*.}" ../img/"${f%.*}.jpg"
    elif [[ "${f##*.}" = "jpg" ]]; then
        cp "$f" ../img/
    else
        :
    fi
done
