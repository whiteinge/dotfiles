#!/bin/zsh
# Start profling:
# zmodload zsh/zprof

local -a precmd_functions

# {{{ setting options

autoload edit-command-line
autoload -U compinit

setopt \
    append_history \
    auto_cd \
    auto_pushd \
    chase_links \
    complete_aliases \
    extended_glob \
    extended_history \
    hist_ignore_all_dups \
    hist_ignore_dups \
    hist_ignore_space \
    hist_reduce_blanks \
    hist_save_no_dups \
    hist_verify \
    ignore_eof \
    list_types \
    mark_dirs \
    noclobber \
    noflowcontrol \
    path_dirs \
    prompt_percent \
    prompt_subst \
    rm_star_wait \
    share_history

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

export MANPATH="$HOME/share/man:${MANPATH}"

CDPATH=$CDPATH::$HOME:/usr/local

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=65536  # search this with `grep | sort -u`
HISTSIZE=4096
SAVEHIST=4096

# Output time stats for progs that run for longer than a minute.
REPORTTIME=60

# Report any login/logout of other users.
WATCH=notme
WATCHFMT='%n %a %l from %m at %T.'

export LANG=en_US.UTF-8
export LC_ALL=$LANG
export LC_COLLATE=C

export EDITOR='vim'
export VISUAL=$EDITOR
export LESS='-imJMWR'
export PAGER="less $LESS"
export MANPAGER=$PAGER
export BROWSER='firefox'

export WINEDEBUG=-all
export WINEARCH=win32

export PYTHONSTARTUP=$HOME/.pythonrc.py

# Inline nodenv init to shave ~10ms more off the startup time.
# eval "$(nodenv init -)"
export NODENV_SHELL=zsh
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
source "$HOME/.nodenv/libexec/../completions/nodenv.zsh"

# }}}
# {{{ completions

compinit -C

zstyle ':completion:*' list-colors "$LS_COLORS"

zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|nc|rsync):*' hosts '
    reply=( ${=${${(M)${(f)"$(<~/.ssh/config)"}:#Host*}#Host }:#*\**} )'

# Custom script in $HOME/bin/c
compdef c=curl

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

# }}}
# {{{ aliases

# ls:
alias ls='ls -F --color'
alias la='ls -A'; compdef la=ls
alias ll='ls -lh'; compdef ll=ls

# Vim:
alias vi=$EDITOR
# fast Vim that doesn't load a vimrc or plugins
alias vv="${EDITOR} -N -u NONE"
# Loads vimrc but no plugins
alias vvv="${EDITOR} -N --noplugin"

alias vimprof="${EDITOR} \
    --cmd 'profile start vim-profile.log' \
    --cmd 'profile func *' \
    --cmd 'profile file *'"

compdef vi=vim
compdef vv=vim
compdef vvv=vim
compdef vimprof=vim

# Aliases that override default names:
alias less='less -imJMW'
alias tree="tree -FC --charset=ascii"
alias info='info --vi-keys'
alias wtf='wtf -o'
alias nnn='nnn -S'
alias ocaml='rlwrap ocaml'
alias mplayer='mplayer -af scaletempo -speed 1'
alias R='R --no-save'

# Aliases around scripts in $HOME/bin:
alias tea-timer="countdown 120 && notify-send 'Tea!' 'Tea is done.'"
alias fetchall-gh='fetchall "git@github.com"'
alias fetchall-gl='fetchall "git@gitlab.com"'

# Aliases that make new things:
alias ducks='du -cks * | sort -rn | head -15'
alias incognito=' export HISTFILE=/dev/null'
alias osx_openports='lsof -iTCP -sTCP:LISTEN -P'
alias clip='xclip -selection clipboard'
alias rs='rsync -avhzC --progress'
compdef rs=rsync

# Print all files under the current path without prefixed path.
# Useful for listing files under one path based on the files in another. E.g.:
# cd /path/to/dotfiles; filesunder | xargs -0 -I@ ls -l $HOME/@
alias filesunder='find . \( -name .git -type d \) -prune -o -type f -printf "%P\0"'
alias filesmissing='find . -maxdepth 2 -xtype l'

# Quickly ssh through a bastian host without having to hard-code in ~/.ssh/config
alias pssh='ssh -o "ProxyCommand ssh $PSSH_HOST nc -w1 %h %p"'

# mkdir and cd at once
mkcd() { mkdir -p -- "$1" && cd -- "$1" }
compdef mkcd=mkdir

# Useful for working with Git remotes; e.g., ``git log IN``, ``git diff OUT``.
alias -g IN='..@{u}'
alias -g IIN='...@{u}'
alias -g OUT='@{u}..'
alias -g OOUT='@{u}...'
alias -g UP='@{u}'

# Selects a random file: ``mplayer RANDOM``
alias -g RANDOM='"$(shuf -e -n1 *)"'

# Output stderr in red. Usage: somecomand RED
alias -g RED='2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)'

# Drop-in for quick notifications. E.g., sleep 10; lmk
alias lmk='notify-send "Task in $(basename $(pwd)) is done"\
    "Task in $(basename $(pwd)) is done"'

# Output names if terminal can handle 256 colors.
alias 256test='echo -e "\e[38;5;196mred\e[38;5;46mgreen\e[38;5;21mblue\e[0m"'

# }}}

# Miscellaneous Functions:

# zshrun A lightweight, one-off application launcher {{{1
# by Mikael Magnusson (I think)
#
# Invokes a command and then immediately closes the terminal window.
# To run a command without closing the terminal use ctrl-j instead of Enter.
#
# Usage:
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
# Use a fuzzy-finder for common CLI tasks {{{1

alias ..='cd ..'

# cd to a parent directory.
function ...() {
    explode_path | tail -n +2 | pick | read -d -r new_dir
    cd "$new_dir"
}

# Search and replay a command from the shell history.
# (Will output the command but not execute.)
function phist() {
    print -z $(pick < $HOME/.zsh_history \
        | awk 'sub(/[^;]*;/, "", $0)')
}

# Complete hostnames from ~/.ssh/config.
function _fzy_ssh() {
    < $HOME/.ssh/config awk '/^Host [0-9a-zA-Z\.-_]+/ {
        for (i = 2; i <= NF; i += 1) print $i
    }' | fzy -p "SSH Hosts > " | xargs printf '%s %s\n' "$cmd"
}

# Complete available manpages.
function _fzy_man() {
man -k . | fzy -p 'Manpages > ' | awk -F' - ' -v cmd="$1" '{
    sec = match($1, / ?\([0-9]/)
    print cmd, substr($1, sec + 2, 1), substr($1, 0, sec)
}'
}

# Complete Git refs.
function _fzy_git() {
    git show-ref \
        | awk '{ sub(/refs\/(heads|tags)\//, "", $2); print $2 }' \
        | pick -p 'Git refs > ' | xargs printf '%s %s' "$*"
}

# Complete directories and open nnn at that location.
function _fzy_nnn() {
    ffind "${2:-$PWD}" -type d | fzy -p "Directories > " \
        | xargs printf '%s %s\n' "$1"
}

# Complete directories under a path and cd to the result.
function _fzy_cd() {
    ffind "${2:-$PWD}" -type d | fzy -p "Directories > " \
        | xargs printf '%s %s\n' "$1"
}

function _fzy_kill() {
    ps -ef | sed 1d | pick -p 'Processes > ' \
        | awk -v cmd="$1" '{ print cmd, $2 }'
}

# A completion fallback if something more specific isn't available.
function _fzy_generic_find() {
    ffind "$PWD" 2>/dev/null | pick \
        | xargs printf '%s %s\n' "$*"
}

# Start typing a CLI command then invoke a fuzzy-finder to complete the rest
# (This idea is stolen from fzf.)
#
# Usage: type a command name and then manually invoke completion with ctrl-f.
#
# New completions can be added for a <cmd> by adding a shell function or
# a shell script on PATH with the pattern _fzy_<cmd>. The script will be
# invoked with the command name and any arguments as ARGV and should print the
# full resulting command and any additions to stdout.
pick-completion() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins

    local tokens=(${(z)LBUFFER})
    if [ ${#tokens} -lt 1 ]; then
        return
    fi
    local cmd=${tokens[1]}

    # Filter (:#) the arrays of the names ((k)) Zsh function and scripts on
    # PATH and remove ((M)) entries that don't match "_fzy_<cmdname>":
    local cmd_fzy_match=${(M)${(k)functions}:#_fzy_${cmd}}
    if [[ ${#cmd_fzy_match} -eq 0 ]]; then
        cmd_fzy_match=${(M)${(k)commands}:#_fzy_${cmd}}
        if [[ ${#cmd_fzy_match} -eq 0 ]]; then
            cmd_fzy_match=( '_fzy_generic_find' )
        fi
    fi

    zle -M "Gathering suggestions..."
    zle -R

    local result
    $cmd_fzy_match "${tokens[@]}" | read -d -r result
    LBUFFER="$result"

    zle reset-prompt
}

zle -N pick-completion
bindkey '^F' pick-completion

# }}}
# Manually refresh the tmux status infos {{{1
# Needed to immediate update the Git status display.

function refresh_tmux() {
    tmux refresh -S
}

_last_cmd_was_git=0
function last_command_was_git() {
    [[ "$1" == git* ]] && _last_cmd_was_git=1
}

function refresh_tmux_on_git() {
    if [[ "$_last_cmd_was_git" -eq 1 ]]; then
        _last_cmd_was_git=0
        tmux refresh -S
    fi
}

# }}}

# Run precmd functions
preexec_functions=( last_command_was_git )
chpwd_functions=( refresh_tmux )
precmd_functions=( precmd_prompt refresh_tmux_on_git )

# Allow OS or environment specific overrides:
if [[ -r "$HOME/.zsh_customize" ]]; then
    source "$HOME/.zsh_customize"
fi

# End profiling:
# zprof

# EOF
