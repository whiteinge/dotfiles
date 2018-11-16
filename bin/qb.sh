#!/bin/sh
# Qutebrowser helpers

i() {
    # Usage: printf foo | qb.sh i

    xargs -0 printf 'insert-text %s\n' >> "$QUTE_FIFO"
}

main() {
    local cmd="$1" && shift
    "$cmd" "$@"
}

main "$@"
