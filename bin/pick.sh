#!/usr/bin/env zsh
# set -x

do_search() {
    local input="$1"
    local search="$2"

    printf '\e[?25l'    # hide cursor
    printf '\e[s'       # save pos
    printf '\e[1B'      # move down
    printf '\e[1000D'   # move to far left

    printf '%s\n' "$input" \
        | awk -v search="$search" -v lines="$LINES" -v cols="$COLUMNS" '
    BEGIN { maxl = lines - 1; maxc = maxl * cols; if (search == "") search = ".*" }
    NR >= maxl { exit }
    tolower($0) !~ search { next }
    # Total line length & remaining whitespace, even for wrapped lines:
    {
        len = length($0)
        if (len < cols) {
            total += cols
        } else {
            total += len + (cols - (len % cols))
        }
    }
    total >= maxc { exit }
    { printf("\033[2K%s\n", $0) }   # Clear line & print match.
    END { printf("\033[J") }        # Clear remaining lines.
    '

    printf '\e[u'       # restore pos
    printf '\e[?25h'    # show cursor
}

main() {
    input="$(< /dev/stdin)"
    search=''

    # By line...
    while true; do
        tput smcup
        tput clear
        printf '\rPrompt: '
        do_search "$input" '.*'

        # By char...
        while read -rk1 key; do
            # Backspace
            if [[ '#key' -eq '##^?' || '#key' -eq '##^h' ]]; then
                if [[ -n "$search" ]]; then
                    printf '\e[3D\e[K'
                    search="${search[1,-2]}"
                else
                    printf '\e[2D\e[K'
                fi
            # Return
            elif [[ '#key' -eq '##\n' || '#key' -eq '##\r' ]]; then
                tput rmcup
                printf '%s\n' "$search"
                exit
            # elif    arrows
            else
                search="${search}${key}"
            fi

            do_search "$input" "$search"
        done

        sleep 1
        tput rmcup
    done
}

main "$@"
