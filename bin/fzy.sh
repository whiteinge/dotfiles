#!/usr/bin/env sh
# WIP: A command-line fuzy-finder

NAME=$(basename "$0")
VERSION='0.0.1'
TEMP="${TMPDIR-/tmp}/${NAME}.${$}.$(awk \
    'BEGIN {srand(); printf "%d\n", rand() * 10^10}')"

QUERY=""
INPUT=""
TOTAL=""

search_input () {
    printf '%s\n' "$INPUT" | awk -v q="$QUERY" '
    lines_out >= 10 { exit }
    $0 ~ q { lines_out += 1; print $0 }
    '
}

show_results () {
    local query="$1"

    printf '\e[u\e[K'     # Jump to starting cursor pos & clear line.
    printf '> %s' "$query"

    printf '\e[1E\e[0J' # down one line, & clear screen

    search_input

    # Return the cursor to the query line for more input.
    printf '\e[u\e[%dC' "$(expr length "$query" + 2)"
}

read_input () {
    local dummy oct char

    if [ -t 0 ]; then
        # Put device in noncanoncial mode w/ blocking read until 1 byte.
        stty -echo -icanon min 1 time 0
    fi

    while true; do
        # Use read to more easily parse the weird output format of od.
        read -r dummy oct char << EOF
$(dd bs=1 count=1 2>/dev/null | od -t o1c | paste - -)
EOF

        case "$oct" in
        010|177) # backspace or ctrl-h
            QUERY="${QUERY%?}" ;;
        011) # tab
            ;;
        012) # enter
            ;;
        016) # ctrl-n
            ;;
        020) # ctrl-p
            ;;
        025) # ctrl-u
            QUERY="";;
        027) # ctrl-w
            QUERY="${QUERY% *}" ;;
        033) # ctrl-c
            exit 1 ;;
        040) # space
            QUERY="${QUERY} ";;
        *) # everything else
            QUERY="${QUERY}${char}";;
        esac

        printf '\e[u> %s\e[0K' "${QUERY}"
    done
}

help () {
    # Extract contiguous lines of comments in a function as help text

    awk -v cmd="${1:?'Command name required.'}" -v NAME="$NAME" '
    $0 ~ "^" cmd "\\s*\\(\\)\\s*{" { is_found=1; next }
    is_found && !NF { exit }
    is_found { gsub(/^\s*#\s?/, ""); gsub(/NAME/, NAME); print; }
    ' "$0"
}

_main () {
    # ## Usage
    #
    # `NAME [<flags>] (command [<arg>, <name=value>...])`
    #
    #     NAME -h              # Short, usage help text.
    #     NAME help command    # Command-specific help text.
    #     NAME command         # Run a command without and with args:
    #     NAME command foo bar baz=Baz qux='Qux arg here'
    #
    # Flag | Description
    # ---- | -----------
    # -V   | Show version.
    # -h   | Show this screen.
    # -x   | Enable xtrace debug logging.
    #
    # Flags _must_ be the first argument to `NAME`, before `command`.

    local opt
    local OPTARG
    local OPTIND

    local cmd
    local ret

    # Save cursor pos. This is the starting point for all movement.
    printf '\e[s'

    local saved_tty_settings=$(stty -g < /dev/tty)

    trap '
        excode=$?; trap - EXIT;
        rm -rf '"$TEMP"'
        stty '"$saved_tty_settings"' < /dev/tty
        printf '\''\e[u\e[0J'\''
        exit $excode
    ' INT TERM EXIT

    while getopts Vhx opt; do
        case $opt in
        V) printf 'Version: %s\n' $VERSION
           exit;;
        h) help _main
           printf '\n'
           exit;;
        x) set -x;;
        esac
    done
    shift $(( OPTIND - 1 ))

    # mkdir -p -m 700 "$TEMP"

    INPUT=$(< /dev/stdin)

    read_input < /dev/tty
}

_main "$@"
