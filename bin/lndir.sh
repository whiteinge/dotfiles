#!/usr/bin/env zsh
# Dead-simple replacement for lndir for WSL.
# https://github.com/Microsoft/WSL/issues/2229
# Attempts to avoid forking any more than necessary, but is still slow.

local src="${1:?Source path is required.}"
local dst="${2:?Destination path is required.}"

find "$src" -mindepth 1 \( -name .git -type d \) -prune -o -type d -printf "${dst}/%P\0" \
    | xargs -0 mkdir -p
find "$src" \( -name .git -type d \) -prune -o -type d -printf '%P\0' \
    | xargs -t -0 -I@ zsh -o GLOB_DOTS -c "ln -sf -t ${dst}/@ ${src}/@/*(.)"
