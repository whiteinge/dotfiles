#!/usr/bin/env zsh
# WIP: A POSIX sh implementation of pick
# set -x

local input=''
local length=0
local query=''
local result=''

# Perform the search and draw the results.
do_search() {
    printf '\e[?25l'    # hide cursor
    printf '\e[s'       # save pos
    printf '\e[1B'      # move down
    printf '\e[1000D'   # move to far left

    printf '%s\n' "$input" \
        | awk -v query="$query" -v lines="$LINES" -v cols="$COLUMNS" '
    BEGIN { maxl = lines - 1; maxc = maxl * cols; if (query == "") query = ".*" }
    NR >= maxl { exit }
    tolower($0) !~ query { next }   # Skip non-matches.
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
    ' | {
        read -r result              # Save & output first matching item.
        printf '%s\n' "$result"
        cat                         # Output the rest.
    }

    printf '\e[u'       # restore pos
    printf '\e[?25h'    # show cursor
}

# A process to collect user input.
get_query() {
    # By line...
    while true; do
        tput smcup      # Start the alt-screen.
        tput clear      # Use a blank alt-screen.
        do_search

        # By char...
        # '\r\e[K': Redraw the read prompt on every keypress.
        while read -rk1 $'?\r\e[KSearch ('"$length"' records): '"$query" key ; do
            # Backspace
            if [[ '#key' -eq '##^?' || '#key' -eq '##^h' ]]; then
                if [[ -n "$query" ]]; then
                    printf '\e[3D\e[K'
                    query="${query[1,-2]}"
                else
                    printf '\e[2D\e[K'
                fi
            # Return
            elif [[ '#key' -eq '##\n' || '#key' -eq '##\r' ]]; then
                tput rmcup
                printf '%s\n' "$result"
                exit
            # elif    arrows
            else
                query="${query}${key}"
            fi

            do_search
        done

        sleep 0.5
        tput rmcup      # Remove the alt-screen.
    done
}

main() {
    input="$(< /dev/stdin)"
    length=$(printf '%s\n' "$input" | wc -l)

    trap '
        excode=$?; trap - EXIT;
        kill $throttle_search_pid 2>/dev/null
        kill $get_query_pid 2>/dev/null
        return
    ' INT TERM EXIT QUIT

    get_query
}

main "$@"
