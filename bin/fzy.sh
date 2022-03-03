#!/usr/bin/env sh
# WIP: A command-line fuzy-finder

# TODO: would it work to redirect stdin to a tmpdir file in a backgrounded
# process then on keypress re-read the contents of that file through awk and
# print the matches?


NAME=$(basename "$0")
VERSION='0.0.1'
TEMP="${TMPDIR-/tmp}/${NAME}.${$}.$(awk \
    'BEGIN {srand(); printf "%d\n", rand() * 10^10}')"

INPUT="${TEMP}/input.bak"

QUERY=""
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

    mkdir -p -m 700 "$TEMP"
    > "$INPUT" &

    read_input < /dev/tty
}

_main "$@"

# https://github.com/huijunchen9260/shmenu/blob/main/shmenu

cat <<'EOF'
### Overcome the limitation of POSIX shell

POSIX shell is very limited, and quite inefficient compared to compiling
language. Previously, I experimented the efficiency of POSIX shell in terms of
passing through all the argument array elements into the key detecting part:

> The efficiency of shellect is highly constraint by the total number of entries
> and the content that you want to display. With `bash`, as I tested, probably
> only numbers of 5000 is large enough to create significant lag. The command
> I run is `tree /directory/have/5000/subitems | shellect` or `echo $(seq 1 5000)
> | shellect`. With `dash`, the efficiency is highly depends on both directions.
> At the number 20000, shellect runs fair efficiency. The command is `tree
> /directory/have/20000/subitems | shellect`. With the number of 30000, the
> pointer will not stop if I relieve my key press. However, changing the command
> to `echo $(seq 1 30000) | shellect`, in my computer, shellect runs with fair
> efficiency. Comparing with `dmenu` and `fzf`, shellect is probably extremely
> inefficient in terms of large numbers of entry. This is probably the limitation
> of an interpreting language compared to compiling language.

As an interpreting language, I found a way to avoid such inefficiency.

First, I'll define some terminologies that I'll use through the explanation:

1. argument array: POSIX shell has no array type. However, there's actually
   one, and only one array in POSIX shell, i.e., the positional parameters,
   `$1`, `$2`, etc.

   To see more information, go to "Working with arrays" section in [Rich’s sh (POSIX shell) tricks](http://www.etalabs.net/sh_tricks.html).

2. selection: the item in argument array that is defined in `$cur`.

3. Length of array: access by `$#`. The length of the total content is `$last`,
   and the length of a list is `$len`. `$len` is set to 500 if the length of
   the total content, `$last`, is larger than 500.


```sh
    while key=$(dd ibs=1 count=1 2>/dev/null); do
    ...
    done
```

This `while` loop is the part to detect key press. This `dd` command has
nothing to interact with the argument array. However, `dd`'s efficiency will be
highly affected by argument array that just pass through it. If the total
number of argument array is too high, then `dd` will become laggy when reading
the key press, eventually causing the cursor movement is laggy.

To resolve this limitation. I developed a technique to only feed part of the
total content to the above while loop:

```sh
key() {
    input_assign ...  # Generate a list which is part of the total content

    set -- $list # let the list to be argument array

    while key=$(dd ibs=1 count=1 2>/dev/null); do
    ...
	othercommand
	return 0 # Go back to main function and stay in the while loop in main function
    ...
	selection key pressed
	return 1 # Go back to main and leave the while loop in main function
    done
}

main() {
    ...
    while [ $? -eq 0 ]; do # If return 0, stay in while loop; others, leave the while loop
	set -- $content	# total content
	key "$@"
    done
}
```

The following steps are to actively switch between `main` function and `key`
function. Within the `$list`, the selection stay in the `while key` loop. If
the current selection ever go out of the `$list`, then go back to `main`
function, reload the `$content` and generate new `$list`, back to `while key`
loop, and process again. That is to say, user will experience an one-time
inaction when reach the boundary of `$list`. This inaction is to renew `$list`
to match current position in the whole `$content`. Press again, and the
selection will move to the next item.
EOF
