#!/usr/bin/env sh
val="${1:?Missing query}"
gpg -qd $HOME/.vdirsyncer/passwords.gpg |
    awk -v val="$val" '$1 ~ val { print $2 }'
