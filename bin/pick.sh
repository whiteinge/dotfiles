#!/usr/bin/env zsh
# set -x

do_search() {
    local input="$1"
    local search="$2"

    printf '\e[?25l'    # hide cursor
    printf '\e[s'       # save pos
    printf '\e[1B'      # move down
    printf '\e[1000D'   # move to far left
    printf '\e[J%s'     # clear from cursor downward
    printf '%s\n' "$input" | grep -i "$search" | head -n $(( ${LINES} - 2 ))
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
