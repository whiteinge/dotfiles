#!/usr/bin/env sh
# Create a shadow directory of symbolic links to another directory tree
#
# A naive implementation of lndir for WSL and/or busybox that don't have easy
# access to that package. Attempts to be as performant as can be expected since
# we're potentially creating thousands of symlinks.
# https://github.com/Microsoft/WSL/issues/2229
#
# Usage:
#
#   lndir.sh $HOME/src/dotfiles $HOME

while getopts h opt; do
    case $opt in
    h) awk 'NR == 1 { next } /^$/ { exit } { print substr($0, 3) }' "$0"
       exit ;;
    esac
done
shift $(( OPTIND - 1 ))

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
