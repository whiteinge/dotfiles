#!/bin/zsh
# Best Goddamn zshrc in the whole world.
# Author: Seth House <seth@eseth.com>
# Modified: 2009-10-11
# thanks to Adam Spiers, Steve Talley, Aaron Toponce, and Unix Power Tools

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
bindkey '^J' push-line

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
export VISUAL='vim'
export GIT_EDITOR=$EDITOR
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export GIT_PAGER=$PAGER
export BROWSER='chromium-browser'

# Silence Wine debugging output (why isn't this a default?)
export WINEDEBUG=-all

# A function to construct GREP_OPTIONS dynamically by reading a file named
# .grepoptions in both the user's home directory and the current directory (for
# project-level grep options and ignores)
function grep_options() {
    local -a opts
    local proj_opts=${PWD}/.grepoptions

    opts=( ${(f)"$(< "${HOME}/.grepoptions")"} )

    if [[ -r ${proj_opts} ]] && [[ $PWD != $HOME ]] ; then
        opts+=( ${${(f)"$(< "${proj_opts}")"}:#[#]*} )
    fi

    GREP_OPTIONS="${(j: :)opts}"
    export GREP_OPTIONS
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

# Gvim package is often the full-featured Vim (Fedora) but I prefer CLI
alias ls='ls -F --color'
alias la='ls -A'
alias ll='ls -lh'
alias lls='ll -Sr'

alias less='less -imJMW'
alias cls='clear' # note: ctrl-L under zsh does something similar
alias locate='locate -i'
alias lynx='lynx -cfg=$HOME/.lynx.cfg -lss=$HOME/.lynx.lss'
alias ducks='du -cks * | sort -rn | head -15'
alias dirtree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias psf='ps -opid,uid,cpu,time,stat,command'
alias df='df -h'
alias dus='du -sh'
alias info='info --vi-keys'
alias clip='xclip -selection clipboard'
alias rs='rsync -avhz --progress'
compdef rs=rsync

# Quickly ssh through a bastian host without having to hard-code in ~/.ssh/config
alias pssh='ssh -o "ProxyCommand ssh $PSSH_HOST nc -w1 %h %p"'

# Useful for accessing versioned Mercurial Queues
alias mq='hg -R $(hg root)/.hg/patches'

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

# Integrate ssh-agent with GNU Screen:
######################################
#
# ssh-agent varies the location of the socket pointed to by SSH_AUTH_SOCK; to
# avoid having to update that variable in every terminal running in Screen
# every time we reattach we create a permanent pointer that is easier to update
SCREEN_AUTH_SOCK=$HOME/.screen/ssh-auth-sock
#
# For local Screen sessions, start ssh-agent and update SCREEN_AUTH_SOCK to
# point to the new ssh-agent socket. Bonus: when the screen session is detached
# the agent will be killed, securing your session. Simply run ssh-add every
# time you start a new screen session or reattach.
alias sc="exec ssh-agent \
    sh -c 'ln -sfn \$SSH_AUTH_SOCK $SCREEN_AUTH_SOCK; \
    SSH_AUTH_SOCK=$SCREEN_AUTH_SOCK exec screen -e\"^Aa\" -S main -DRR'"
#
# For remote Screen sessions (e.g. ssh-ed Screen inside local Screen), update
# SCREEN_AUTH_SOCK to point at the (hopefully) existing forwarded SSH_AUTH_SOCK
# that points to your locally running agent. (For more info see ForwardAgent in
# the ssh_config manpage.)
alias rsc="exec sh -c 'ln -sfn \$SSH_AUTH_SOCK $SCREEN_AUTH_SOCK; \
    SSH_AUTH_SOCK=$SCREEN_AUTH_SOCK exec screen -e\"^Ss\" -S main -DRR'"

# tmux agent alias
alias tm="exec ssh-agent \
    sh -c 'ln -sfn \$SSH_AUTH_SOCK $SCREEN_AUTH_SOCK; \
    SSH_AUTH_SOCK=$SCREEN_AUTH_SOCK exec tmux -2 attach'"

# remote tmux agent alias
alias rtm="exec sh -c 'ln -sfn \$SSH_AUTH_SOCK $SCREEN_AUTH_SOCK; \
    SSH_AUTH_SOCK=$SCREEN_AUTH_SOCK exec tmux attach'"

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
    bindkey "^M" _accept_and_quit
    PROMPT="zshrun %~> "
    RPROMPT=""
fi

# }}}
# gext A wrapper to grep files with a given file extension {{{1
# Also guesses case-insensitivity and performs many searches in parallel.

gext() {
    local spath search ext prune help icase extsearch findcmd xargscmd grepcmd

    spath="$1"
    search="$2"
    ext="$3"

    prune="\
        -path \*/.svn \
        -o -path \*/.git \
        -o -path \*/.hg \
        -o -path \*/.bzr \
        -o -name \*.pyc \
        -o -name \*.pyo"

    help="Usage: gext ./somepath sometext [someext]
    Search will be case-sensitive if the search text contains capital letters."

    # Output help if missing path or search
    [[ -n "${spath}" ]] && [[ -n "${search}" ]] || { echo ${help}; return 1 }

    # Check for capital letters in the search pattern
    echo "${search}" | grep -qE '[A-Z]+'
    [[ $? -ne 0 ]] && icase="-i"

    # Build a find search if user passed a file extension to search
    [[ -n "${ext}" ]] && extsearch="-name \"*.${ext}\""

    # Assemble the commands to perform the search
    findcmd="find \"${spath}\" \( ${prune} \) -prune -o -type f ${extsearch} -print0"
    xargscmd="xargs -0 -P8"
    grepcmd="grep ${icase} -nH -e \"${search}\""

    eval "${findcmd} | ${xargscmd} ${grepcmd}"
}

# }}}
# ..(), ...() for quickly changing $CWD {{{1
# http://www.shell-fu.org/lister.php?id=769

# Go up n levels:
# .. 3
function .. (){
    local arg=${1:-1};
    local dir=""
    while [ $arg -gt 0 ]; do
        dir="../$dir"
        arg=$(($arg - 1));
    done
    cd $dir >&/dev/null
}

# Go up to a named dir
# ... usr
function ... (){
    if [ -z "$1" ]; then
        return
    fi
    local maxlvl=16
    local dir=$1
    while [ $maxlvl -gt 0 ]; do
        dir="../$dir"
        maxlvl=$(($maxlvl - 1));
        if [ -d "$dir" ]; then
            cd $dir >&/dev/null
        fi
    done
}

# }}}
# {{{ genpass()
# Generates a tough password of a given length

function genpass() {
    if [ ! "$1" ]; then
        echo "Usage: $0 20"
        echo "For a random, 20-character password."
        return 1
    fi
    dd if=/dev/urandom count=1 2>/dev/null | tr -cd 'A-Za-z0-9!@#$%^&*()_+' | cut -c-$1
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
# Python development helpers {{{

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

# work on virtualenv
function workon(){
    local vchkdirs

    for vchkdirs in $1/bin/activate $SRCDIR/$1/bin/activate ; do
        if [[ -f $vchkdirs ]] ; then
            source $vchkdirs
            break
        fi
    done

    [[ -n $VIRTUAL_ENV ]] || error 1 "virtualenv activate script not found"

    VIRTUAL_ENV_LIB="$(python -c 'from distutils import sysconfig; print sysconfig.get_python_lib()')"
    alias cdsitepackages="cd $VIRTUAL_ENV_LIB"
}

# Quickly add system-level Python libs to the active virtualenv
# Stolen from virtualenvwrapper
function add2virtualenv() {
    [[ -z $VIRTUAL_ENV || -z $VIRTUAL_ENV_LIB ]] && return 1
    local path_file="$VIRTUAL_ENV_LIB/virtualenv_path_extensions.pth"
    touch "$path_file"

    for pydir in "$@" ; do
        local absolute_path=$(python -c "import os; print os.path.abspath('$pydir')")
        if [[ -d $absolute_path ]] ; then
            echo "$absolute_path" >> "$path_file"
        elif [[ -r $absolute_path ]] ; then
            ln -s $absolute_path $VIRTUAL_ENV_LIB/
        else
            echo "Could not read path: $absolute_path"
        fi
    done
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
    /bin/ps -u $(whoami) -o pid,rss,command | awk '{sum+=$2} END {print "Total " sum / 1024 " MB"}'
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
    trap 'rm -f '$tmpfile SIGINT SIGTERM EXIT

    # Grab the command(s) from stdin and write to tmpfile
    cat - > ${tmpfile}

    # Execute up to 5 ssh processes at a time and pipe tmpfile to the stdin of
    # the remote shell
    echo -n "${HOSTS[@]}" | xargs -d" " -P5 -IHOST \
        sh -c 'ssh -T HOST < '${tmpfile}' | sed -e "s/^/HOST: /g"'
}

# }}}

# Run precmd functions
precmd_functions=( precmd_prompt grep_options )

# EOF
