#!/usr/bin/awk -f

function init() {
    # # Put device in noncanoncial mode w/ blocking read until 1 byte.
    # stty -echo -icanon min 1 time 0

    system("stty -isig -icanon -echo")
    LANG = ENVIRON["LANG"]; # save LANG
    ENVIRON["LANG"] = C; # simplest locale setting
}

function finale() {
    system("stty isig icanon echo")
    ENVIRON["LANG"] = LANG; # restore LANG
}

# Stolen from https://github.com/huijunchen9260/fm.awk
function key_collect() {
    key = ""; rep = 0
    do {

        cmd = "dd ibs=1 count=1 2>/dev/null"
        cmd | getline ans;
        close(cmd)

        gsub(/[\\^$()\[\]|]/, "\\\\&", ans) # escape special char
        if (ans ~ /\033/ && rep == 1) { ans = ""; continue; } # first char of escape seq
        else { key = key ans }
        if (key ~ /[^\x00-\x7f]/) { break } # print non-ascii char
        if (key ~ /^\\\[5$|^\\\[6$$/) { ans = ""; continue; } # PageUp / PageDown
    } while (ans !~ /[\006\025\033\003\177[:space:][:alnum:]><\}\{.~\/:!?*+-]|"/)
    return key
}

BEGIN {
    init()
    RS = "\a"
    getline lines < "-"

    while (key = key_collect()) {
        if (key ~ /\[C/ || key == "\003" || key == "\033" || key == "q") { finale(); exit }
    }

    
}

END {
    finale()
}
