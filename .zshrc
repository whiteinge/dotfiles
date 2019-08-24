#!/bin/zsh
# Start profling:
# zmodload zsh/zprof

local -a precmd_functions

# {{{ setting options

autoload edit-command-line
autoload -U compinit
autoload -U zmv
autoload zcalc

setopt                          \
        append_history          \
        auto_cd                 \
        auto_pushd              \
        chase_links             \
        complete_aliases        \
        extended_glob           \
        extended_history        \
        hist_ignore_all_dups    \
        hist_ignore_dups        \
        hist_ignore_space       \
        hist_reduce_blanks      \
        hist_save_no_dups       \
        hist_verify             \
        ignore_eof              \
        list_types              \
        mark_dirs               \
        noclobber               \
        noflowcontrol           \
        path_dirs               \
        prompt_percent          \
        prompt_subst            \
        rm_star_wait            \
        share_history

# Push a command onto a stack allowing you to run another command first
bindkey '^J' push-line-or-edit

# }}}
# {{{ environment settings

umask 027

extra_path=(
    $HOME/bin \
    $HOME/.nodenv/bin \
    $HOME/.nodenv/shims/ \
    $HOME/.cabal/bin \
    $HOME/.ghcup/bin \
    $HOME/.local/bin \
    /sbin \
    /usr/sbin \
    /usr/local/bin \
    /usr/local/sbin \
)
export PATH="${(j|:|)extra_path}:$PATH"

CDPATH=$CDPATH::$HOME:/usr/local

export MANPATH="$HOME/share/man:${MANPATH}"

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
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export BROWSER='google-chrome'
export CVSIGNORE='*.swp *.orig *.rej .git'

# Silence Wine debugging output (why isn't this a default?)
export WINEDEBUG=-all
# We pretty much always want 32-bit...
export WINEARCH=win32

# Inline nodenv init to shave a few more ms off the startup time.
# eval "$(nodenv init -)"
export NODENV_SHELL=zsh
source "$HOME/.nodenv/libexec/../completions/nodenv.zsh"
command nodenv rehash 2>/dev/null
nodenv() {
    local command
    command="${1:-}"
    if [ "$#" -gt 0 ]; then
        shift
    fi

    case "$command" in
        rehash|shell)
            eval "$(nodenv "sh-$command" "$@")";;
        *)
            command nodenv "$command" "$@";;
    esac
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
        ZSH_HIGHLIGHT_HIGHLIGHTERS+=( brackets pattern )
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

alias vimprof=$EDITOR' \
    --cmd "profile start vim-profile.log" \
    --cmd "profile func *" \
    --cmd "profile file *"'

compdef c=curl

alias less='less -imJMW'
alias cls='clear' # note: ctrl-L under zsh does something similar
alias ducks='du -cks * | sort -rn | head -15'
alias tree="tree -FC --charset=ascii"
alias info='info --vi-keys'
alias wtf='wtf -o'
alias nnn='nnn -S'
alias clip='xclip -selection clipboard'
alias ocaml='rlwrap ocaml'
alias rs='rsync -avhzC --progress'
compdef rs=rsync
alias mplayer='mplayer -af scaletempo -speed 1'

# Print all files under the current path without prefixed path.
# Useful for listing files under one path based on the files in another. E.g.:
# cd /path/to/dotfiles; filesunder | xargs -0 -I@ ls -l $HOME/@
alias filesunder='find . \( -name .git -type d \) -prune -o -type f -printf "%P\0"'
alias filesmissing='find . -maxdepth 2 -xtype l'

# Quickly ssh through a bastian host without having to hard-code in ~/.ssh/config
alias pssh='ssh -o "ProxyCommand ssh $PSSH_HOST nc -w1 %h %p"'

# Useful for working with Git remotes; e.g., ``git log IN``
alias -g IN='..@{u}'
alias -g IIN='...@{u}'
alias -g OUT='@{u}..'
alias -g OOUT='@{u}...'
alias -g UP='@{u}'

# Don't prompt to save when exiting R
alias R='R --no-save'

# Selects a random file: ``mplayer RANDOM``
alias -g RANDOM='"$(shuf -e -n1 *)"'

# Output stderr in red. Usage: somecomand RED
alias -g RED='2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)'

# trailing space helps sudo recognize aliases
# breaks if flags are given (e.g. sudo -u someuser vi /etc/hosts)
alias sudo='command sudo '

# Drop-in for quick notifications. E.g., sleep 10; lmk
alias lmk='notify-send "Task in $(basename $(pwd)) is done"\
    "Task in $(basename $(pwd)) is done"'

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
# ...() Open fuzzy-finder of parent directory names {{{1

alias ..='cd ..'
function ...() {
    explode_path | tail -n +2 | pick | read -d -r new_dir
    cd "$new_dir"
}

# }}}
# cdd() Open fuzzy-finder of child directory names {{{1

function cdd() {
    ffind . -type d | pick | read -d -r new_dir
    cd "$new_dir"
}

# Same thing but open with nnn instead of cd'ing.
function nnnn() {
    ffind "${1:-$PWD}" -type d | pick | read -d -r new_dir
    nnn "$new_dir"
}

# }}}
# 256-colors test {{{

256test()
{
    echo -e "\e[38;5;196mred\e[38;5;46mgreen\e[38;5;21mblue\e[0m"
}

# }}}
alias tea-timer="countdown 120 && notify-send 'Tea!' 'Tea is done.'"

# Run precmd functions
precmd_functions=( precmd_prompt )

if [[ -r "$HOME/.zsh_customize" ]]; then
    source "$HOME/.zsh_customize"
fi

# End profiling:
# zprof

# EOF
