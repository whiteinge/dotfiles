#!/bin/zsh
local -a precmd_functions

# {{{ setting options

autoload edit-command-line
autoload -U compinit
autoload -U zmv
autoload zcalc

setopt                          \
        auto_cd                 \
        auto_pushd              \
        chase_links             \
        noclobber               \
        complete_aliases        \
        extended_glob           \
        hist_ignore_all_dups    \
        hist_save_no_dups       \
        hist_ignore_space       \
        ignore_eof              \
        share_history           \
        noflowcontrol           \
        list_types              \
        mark_dirs               \
        path_dirs               \
        prompt_percent          \
        prompt_subst            \
        rm_star_wait

# Push a command onto a stack allowing you to run another command first
bindkey '^J' push-line-or-edit

# }}}
# {{{ environment settings

umask 027

path+=( $HOME/bin /sbin /usr/sbin /usr/local/sbin ); path=( ${(u)path} );
CDPATH=$CDPATH::$HOME:/usr/local

PYTHONSTARTUP=$HOME/.pythonrc.py
export PYTHONSTARTUP

# Local development projects go here
SRCDIR=$HOME/src
alias tworkon='SRCDIR=$HOME/tmp djworkon'

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=65536  # search this with `grep | sort -u`
HISTSIZE=4096
SAVEHIST=4096

REPORTTIME=60       # Report time statistics for progs that take more than a minute to run
WATCH=notme         # Report any login/logout of other users
WATCHFMT='%n %a %l from %m at %T.'

# utf-8 in the terminal, will break stuff if your term isn't utf aware
export LANG=en_US.UTF-8
export LC_ALL=$LANG
export LC_COLLATE=C

export EDITOR='vim'
export VISUAL=$EDITOR
export GIT_EDITOR=$EDITOR
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export GIT_PAGER=$PAGER
export BROWSER='google-chrome'
export CVSIGNORE='*.swp *.orig *.rej .git'

# Silence Wine debugging output (why isn't this a default?)
export WINEDEBUG=-all

# A function to construct GEXT_OPTIONS dynamically by reading a file named
# .gextoptions in both the user's home directory and the current directory (for
# project-level grep options and ignores)
function gext_options() {
    local -a opts
    local proj_opts=${PWD}/.gextoptions

    opts=( ${(f)"$(< "${HOME}/.gextoptions")"} )

    if [[ -r ${proj_opts} ]] && [[ $PWD != $HOME ]] ; then
        opts+=( ${${(f)"$(< "${proj_opts}")"}:#[#]*} )
    fi

    GEXT_OPTIONS="${(j: :)opts}"
    export GEXT_OPTIONS
}

# }}}
# {{{ completions

compinit -C

zstyle ':completion:*' list-colors "$LS_COLORS"

zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|nc|rsync):*' hosts '
    reply=( ${=${${(M)${(f)"$(<~/.ssh/config)"}:#Host*}#Host }:#*\**} )'

# }}}
# {{{ prompt and theme

# Set vi-mode and create a few additional Vim-like mappings
bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "^R" redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "ga" what-cursor-position
bindkey -M viins '^p' history-beginning-search-backward
bindkey -M vicmd '^p' history-beginning-search-backward
bindkey -M viins '^n' history-beginning-search-forward
bindkey -M vicmd '^n' history-beginning-search-forward

# Allows editing the command line with an external editor
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

# Restore bash/emacs defaults.
bindkey '^U' backward-kill-line
bindkey '^Y' yank

# Set up prompt
if [[ ! -n "$ZSHRUN" ]]; then
    source $HOME/.zsh_shouse_prompt

    # Fish shell like syntax highlighting for Zsh:
    # git clone git://github.com/nicoulaj/zsh-syntax-highlighting.git \
    #   $HOME/.zsh-syntax-highlighting/
    if [[ -d $HOME/.zsh-syntax-highlighting/ ]]; then
        source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS+=( brackets pattern cursor )
    fi
fi

# This is a workaround for tmux. When you clear the terminal with ctrl-l
# anything on-screen is not saved (this is compatible with xterm behavior).
# In contrast, GNU screen will first push anything on-screen into the
# scrollback buffer before clearing the screen which I prefer.
function tmux-clear-screen() {
    for line in {1..$(( $LINES ))} ; do echo; done
    zle clear-screen
}
zle -N tmux-clear-screen
bindkey "^L" tmux-clear-screen

# }}}
# {{{ aliases

alias zmv='noglob zmv'
# e.g., zmv *.JPEG *.jpg

alias ls='ls -F --color'
alias la='ls -A'; compdef la=ls
alias ll='ls -lh'; compdef ll=ls
alias lls='ll -Sr'; compdef lls=ls

alias vi=$EDITOR; compdef vi=vim
# fast Vim that doesn't load a vimrc or plugins
alias vv=$EDITOR' -N -u NONE'; compdef vv=vim
# Loads vimrc but no plugins
alias vvv=$EDITOR' -N --noplugin'; compdef vvv=vim

alias c='curl -sS -D /dev/stderr'
compdef c=curl
alias less='less -imJMW'
alias cls='clear' # note: ctrl-L under zsh does something similar
alias lynx='lynx -cfg=$HOME/.lynx.cfg'
alias ducks='du -cks * | sort -rn | head -15'
alias tree="tree -FC --charset=ascii"
alias info='info --vi-keys'
alias clip='xclip -selection clipboard'
alias ocaml='rlwrap ocaml'
alias node='env NODE_NO_READLINE=1 rlwrap node'
alias rs='rsync -avhzC --progress'
compdef rs=rsync

# Print all files under the current path without prefixed path.
# Useful for listing files under one path based on the files in another. E.g.:
# cd /path/to/dotfiles; filesunder | xargs -0 -I@ ls -l $HOME/@
alias filesunder='find . \( -name .git -type d \) -prune -o -type f -printf "%P\0"'

# Quickly ssh through a bastian host without having to hard-code in ~/.ssh/config
alias pssh='ssh -o "ProxyCommand ssh $PSSH_HOST nc -w1 %h %p"'

# Useful for working with Git remotes; e.g., ``git log IN``
alias -g IN='..@{u}'
alias -g OUT='@{u}..'
alias -g UP='@{u}'

# Don't prompt to save when exiting R
alias R='R --no-save'

# Selects a random file: ``mplayer RANDOM``
alias -g RANDOM='"$(files=(*(.)) && echo $files[$RANDOM%${#files}+1])"'

# trailing space helps sudo recognize aliases
# breaks if flags are given (e.g. sudo -u someuser vi /etc/hosts)
alias sudo='command sudo '

# mplayerx2 -s 2.0 mymovie.m4v
function mplayerx2() {
    local -a args
    zparseopts -D -E -a args -- s: -speed:
    mplayer -af scaletempo -speed ${args[2]:=1.5} $1
}

# }}}
# Miscellaneous Functions:
# error Quickly output a message and exit with a return code {{{1
function error() {
    EXIT=$1 ; MSG=${2:-"$NAME: Unknown Error"}
    [[ $EXIT -eq 0 ]] && echo $MSG || echo $MSG 1>&2
    return $EXIT
}

# }}}
# zshrun A lightweight, one-off application launcher {{{1
# by Mikael Magnusson (I think)
#
# To run a command without closing the dialog press ctrl-j instead of enter
# Invoke like:
# sh -c 'ZSHRUN=1 uxterm -geometry 100x4+0+0 +ls'

if [[ -n "$ZSHRUN" ]]; then
    unsetopt ignore_eof
    unset ZSHRUN

    function _accept_and_quit() {
        zsh -c "${BUFFER}" &|
        exit
    }
    zle -N _accept_and_quit
    bindkey "^J" accept-line
    bindkey "^M" _accept_and_quit
    PROMPT="zshrun %~> "
    RPROMPT=""
fi

# }}}
# ..() Switch to parent directory by matching on partial name {{{1
# Usage:
# cd /usr/share/doc/zsh
# .. s      # cd's to /usr/share

function .. () {
    (( $# == 0 )) && { cd .. && return }

    local match_idx
    local -a parents matching_parents new_path
    parents=( ${(s:/:)PWD} )
    matching_parents=( ${(M)${parents[1,-2]}:#"${1}"*} )

    if (( ${#matching_parents} )); then
        match_idx=${parents[(i)${matching_parents[-1]}]}
        new_path=( ${parents[1,${match_idx}]} )

        cd "/${(j:/:)new_path}"
        return $?
    fi

    return 1
}

# }}}
# {{{ genpass()
# Generates a tough password of a given length

function genmac() {
    # Generate a locally-assigned (starts with 02) mac address from a salt.
    # http://serverfault.com/a/299563

    local salt=${1:-$FQDN}
    echo $salt | md5sum |\
        sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/'
}

function genpass() {
    if [ ! "$1" ]; then
        echo "Usage: $0 20"
        echo "For a random, 20-character password."
        return 1
    fi

    # Use pwgen if installed.
    if (( $+commands[pwgen] )); then
        echo $(pwgen -y $1)
    else
        dd if=/dev/urandom count=1 2>/dev/null |\
            tr -cd 'A-Za-z0-9!@#$%^&*()_+' | cut -c-$1
    fi
}

function genunixpass() {
    # Generate a valid /etc/shadow password

    local pass="${1:-saltdev}"
    echo "pass: ${pass}"
    echo $(python -c "import crypt; print crypt.crypt('"$pass"', '\$6\$SALTsalt')")
}

# }}}
# {{{ bookletize()
# Converts a PDF to a fold-able booklet sized PDF
# Print it double-sided and fold in the middle

bookletize ()
{
    (( $+commands[pdfinfo] )) && (( $+commands[pdflatex] )) || {
        error 1 "Missing req'd pdfinfo or pdflatex"
    }

    pagecount=$(pdfinfo $1 | awk '/^Pages/{print $2+3 - ($2+3)%4;}')

    # create single fold booklet form in the working directory
    pdflatex -interaction=batchmode \
    '\documentclass{book}\
    \usepackage{pdfpages}\
    \begin{document}\
    \includepdf[pages=-,signature='$pagecount',landscape]{'$1'}\
    \end{document}' 2>&1 >/dev/null
}

# }}}
# {{{ joinpdf()
# Merges, or joins multiple PDF files into "joined.pdf"

joinpdf () {
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=joined.pdf "$@"
}

# }}}
# Development helpers {{{

# Start an echo server
alias echoserver='socat -T1 TCP-L:8080,crlf,reuseaddr,fork EXEC:cat'

# Start a webserver in the current directory
alias pyhttp='python -m SimpleHTTPServer'
# Start a echoing SMTP server
alias pysmtp='python -m smtpd -n -c DebuggingServer localhost:1025'
# Print an interactive Python shell session as regular Python (reads stdin)
alias pyprintdoc='python -c "import doctest, sys; print doctest.script_from_examples(sys.stdin.read())"'
# Validate and pretty-print JSON
alias jsonpp='python -m json.tool'

alias urlencode='python -c "import urllib2, sys; print urllib2.quote(sys.stdin.read().encode(\"utf8\"))"'
alias urldecode='python -c "import urllib2, sys; print urllib2.unquote(sys.stdin.read().encode(\"utf8\"))"'

# Format Django's json dumps as one-record-per-line
function djfmtjson() {
    sed -i'.bak' -e 's/^\[/\[\n/g' -e 's/]$/\n]/g' -e 's/}}, /}},\n/g' $1
}

# }}}
# Screencast helper {{{
# Usage:
# screencast [--window]

function screencast() {
    local now target size offset
    local -a win wininfo
    zparseopts -E -D -- w=win -window=win

    zformat -f target "%(c.root.frame)" c:${#win}
    now=$(date --rfc-3339=date)

    wininfo=( $(xwininfo -stats -${target} | awk -F":" '
        /Absolute.*X/ { x=$2 }
        /Absolute.*Y/ { y=$2 }
        /Width/ { w=$2 }
        /Height/ { h=$2 }
        END { print w, h, x, y }') )

    size=${(j:x:)${wininfo[1,2]}}
    offset=${(j:,:)${wininfo[3,4]}}

    ffmpeg -f alsa -ac 2 -i hw:0,0 \
        -f x11grab -r 30 -s ${size} -i ${DISPLAY}+${offset} \
        -acodec pcm_s16le -vcodec libx264 -vpre lossless_ultrafast \
        -threads 0 -y $HOME/screencast-${now}.avi

    return $?
}

# Extract a clip from a larger video file
# Usage:
#   extract_clip somevid.mp4 [hh:mm:ss start time] [hh:mm:ss end time]
function extract_clip() {
    local start_seconds end_seconds duration

    echo ${2} ${3} | awk 'BEGIN {FS=":"; ORS=" "; RS=" "}
            { sec = $1 * 3600; sec += $2 * 60; sec += $3; print sec }' |\
        read start_seconds end_seconds
    duration=$(( end_seconds - start_seconds ))

    ffmpeg -ss ${2} -t ${duration} -i ${1} -acodec copy -vcodec copy extracted_clip-${1}

    return $?
}

# }}}
# 256-colors test {{{

256test()
{
    echo -e "\e[38;5;196mred\e[38;5;46mgreen\e[38;5;21mblue\e[0m"
}

# }}}
# Dictionary lookup {{{1
# Many more options, see:
# http://linuxcommando.blogspot.com/2007/10/dictionary-lookup-via-command-line.html

dict (){
    curl 'dict://dict.org/d:$1:*'
}

spell (){
    echo $1 | aspell -a
}

# }}}
# Output total memory currently in use by you {{{1

memtotaller() {
    /bin/ps -u $(whoami) -o pid,rss,command |\
        awk '{sum+=$2} END {print "Total " sum / 1024 " MB"}'
}

# Output total memory in use by all children processes
memchildren() {
    ps -h -o pid --ppid $1 |\
        xargs printf "/proc/%s/smaps\n" |\
        xargs awk '/^Pss/ { total += $2 } END { print "Total " total / 1024 " KB" }'
}

# }}}
# xssh {{{1
# Paralelize running shell commands through ssh on multiple hosts with xargs
#
# Usage:
#   echo uptime | xssh host1 host2 host3
#
# Usage:
#   xssh host1 host2 host3
#   # prompts for commands; ctrl-d to finish
#   free -m | awk '/^-/ { print $4, "MB" }'
#   uptime
#   ^d

function xssh() {
    local HOSTS="${argv}"
    [[ -n "${HOSTS}" ]] || return 1

    local tmpfile="/tmp/xssh.cmd.$$.$RANDOM"
    trap 'rm -f '$tmpfile'; return;' EXIT

    # Grab the command(s) from stdin and write to tmpfile
    cat - > ${tmpfile}

    # Execute up to 5 ssh processes at a time and pipe tmpfile to the stdin of
    # the remote shell
    echo -n "${HOSTS[@]}" | xargs -d" " -P5 -IHOST \
        sh -c 'ssh -T HOST < '${tmpfile}' | sed -e "s/^/HOST: /g"'
}
compdef xssh=ssh

# }}}
# wait_for_ssh {{{1
# Block until a multiplexed ssh connection is ready
#
# Useful for making a single ssh connection that can be reused for many ssh
# operations. This requires ControlMaster and ControlPath to be configured in
# your ~/.ssh/config file.
#
# Usage:
#   SSH="me@example.com"
#   trap 'ssh -O exit '${SSH} SIGINT SIGTERM EXIT
#   ssh -N ${SSH} &
#   _wait_for_ssh ${SSH}
#   ...use multiplexed ssh connection here...

function _wait_for_ssh () {
    [[ $# -eq 1 ]] || { echo "ssh hostname required"; exit 1; }

    local ssh="${1}"

    echo -n "Connecting to GitHub."
    while ! ssh -O check ${ssh} &>/dev/null true; do
        echo -n '.' ; sleep 0.5;
    done
    echo -e "\nConnected!\n"
}

# }}}
# fetchall {{{1
# Run git fetch on all repos under the current dir

function fetchall () {
    local GH_SSH="git@github.com"

    # Start a connection and wait for it; exit when we're done
    trap 'ssh -O exit '${GH_SSH} SIGINT SIGTERM EXIT
    ssh -N ${GH_SSH} &
    _wait_for_ssh ${GH_SSH}

    # Kick off a ton of parallel fetch operations
    time find . -type d -name .git -print0 \
        | xargs -t -r -0 -P5 -I@ git --git-dir=@ fetch -a

    local count=$(find . -type d -name .git -print | wc -l)
    printf 'Fetched upstream changes for %s repositories.\n' "$count"
}

# }}}
# presentation_mode {{{1
# Set various settings and open a new xterm window for giving presentations

function presentation_mode() {
    (PRESENTATION_MODE=1 xterm -fg black -bg white -fs 16 &>/dev/null &)
}

# }}}
# countdown & timer {{{1
# (Ab)use prompt escapes to get the time without spawning a subshell. :)

function countdown() {
    local now remaining
    local epoch='%D{%s}'
    local target=$(( ${(%)epoch} + $1 ))

    while true; do
        now=${(%)epoch}
        remaining=$(( target - now ))

        if (( $remaining > 0 )) ; then
            printf '\rT-minus: %s' "${remaining}"
            sleep 0.5
        else
            printf '\a\n'
            break
        fi
    done
}

alias tea-timer="countdown 120 && notify-send 'Tea!' 'Tea is done.'"

function _timer_elapsed() {
    local epoch='%D{%s}'
    local start=$1
    local end=${(%)epoch}

    printf '\nElapsed time: %s seconds\n' "$(( end - start ))"
}

function timer() {
    local dts='%D{%H:%M:%S}'
    local epoch='%D{%s}'
    local start=${(%)epoch}

    trap '_timer_elapsed '"${start}"'; return;' INT

    printf 'Starting timer at %s\n' "${(%)dts}"
    while true; do 
        printf '\r%s' "${(%)dts}"
        sleep 0.5
    done
}

# }}}
# ztail {{{1
# Run a command then open two tmux panes to tail stdout and stderr separately.

function ztail() {
    unsetopt noclobber

    trap '
        excode=$?; trap - EXIT;
        rm -f /tmp/ztail.{out,err}
        return
    ' INT TERM EXIT QUIT

    touch /tmp/ztail.out /tmp/ztail.err
    tmux splitw 'less +F /tmp/ztail.out'
    tmux splitw -v 'less +F /tmp/ztail.err'

    "$@" 1>/tmp/ztail.out 2>/tmp/ztail.err
}

# }}}
# curlretry {{{1
# Repeatedly download & resume from a URL until finished;
# useful for bad connections.

function curlretry() {
    local url=$1
    local fname=$2
    until curl -L -C - -g "${url}" -o "${fname}"; do echo Retrying && sleep 1; done
}

### }}}

# Run precmd functions
precmd_functions=( precmd_prompt gext_options )

# EOF
