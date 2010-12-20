#!/usr/bin/env zsh
# Output a warning when the battery drops below a certain percentage;
# put the machine to sleep when the battery drops below a certain percentage.
# vim:ft=zsh
# #############################################################################

local NAME=$(basename $0)

# Exit with an error
function error() {
    EXIT=$1 ; MSG=${2:-"$NAME: Unknown Error"}
    [[ $EXIT -eq 0 ]] && echo $MSG || echo $MSG 1>&2
    exit $EXIT
}

# Send a graphical message about the current battery usage
function message() {
    local msg msgcmd user display
    local -a curusers
    msg=$1

    if [[ -n $(which notify-send 2>/dev/null) ]] ; then
        msgcmd=notify-send
    elif [[ -n $(which xmessage 2>/dev/null) ]] ; then
        msgcmd=xmessage
    else
        error 1 "No messaging command found."
    fi

    # Send a message to all users, if root, or current user
    if [[ $EUID -eq 0 ]] ; then
        curusers=( $(w -s -h | awk '/(startx|dm\?)/ { print $1, $2 }') )

        for user display in $curusers; do
            DISPLAY=$display sudo -u $user $msgcmd "${msg}"
        done
    else
        $msgcmd "${msg}"
    fi
}

function main() {
    # NOTE: acpid starts emiting low-battery events at 5%
    local -a OPTS
    local WARNLEVEL=5
    local SLEEPLEVEL=3
    local BATT=$(acpi -b | awk '
        BEGIN { FS=", " }

        /Discharging/ {
            sub(/\%/, "", $2)
            print $2
        }')
    local HELPTEXT="\
    Usage:: ${NAME} [options]

    Options:
    --warn=warn, -w warn
        Set the battery percentage to begin displaying warnings.
        Default: ${WARNLEVEL}
    --sleep=sleep, -s sleep
        Set the battery percentage at which to put the machine to sleep.
        Default: ${SLEEPLEVEL}
    --help
        Print this summary and exit.
    "

    # Parse any arguments
    # zparseopts -D -a OPTS -- \
    #     -warn:=WARNLEVEL w:=WARNLEVEL \
    #     -sleep:=SLEEPLEVEL s:=SLEEPLEVEL \
    #     -help || exit 1

    # Print help or version info
    # (( $OPTS[(I)--help] )) && error 0 "${HELPTEXT}"

    # Bail out early if connected to AC
    [[ -n $BATT ]] || exit 0

    # Emit warnings
    if [[ $BATT -le $WARNLEVEL ]] ; then
        if [[ $BATT -le $SLEEPLEVEL ]] ; then
            message "Your battery is critical; sleeping..."
            sleep 5
            /etc/acpi/sleep.sh
        else
            message "Your battery level is currently ${BATT}%"
        fi
    fi
}

# #############################################################################

main $*
