#!/usr/bin/env sh
# Dead-simple replacement for lndir for WSL and/or busybox.
# https://github.com/Microsoft/WSL/issues/2229

src="${1:?Source path is required.}"
dst="${2:?Destination path is required.}"

case $src in
    /*) src=$src;;
    *) printf 'Must be an absolute path\n'; exit 1;;
esac

find "$src" -mindepth 1 \( -name .git -type d \) -prune -o -type d \
    | awk -v src="$src" -v dst="$dst" '
        BEGIN { sub(/\/$/, "", src) }
        {
            path = substr($0, length(src) + 2)
            print dst "/" path
        }
    ' \
    | xargs mkdir -p

find "$src" -mindepth 1 \( -name .git \) -prune -o \( -type f -o -type l \) -print \
    | awk -v src="$src" -v dst="$dst" '
        BEGIN { sub(/\/$/, "", src) }
        {
            path = substr($0, length(src) + 2)
            print src "/" path
            print dst "/" path
        }
    ' \
    | xargs -n 2 sh -c 'ln -sf $1 $2' -
