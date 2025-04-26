#!/bin/zsh
# Start profling:
# zmodload zsh/zprof

local -a precmd_functions

# {{{ setting options

autoload edit-command-line
autoload -U compinit

setopt \
    auto_cd \
    auto_pushd \
    chase_links \
    complete_aliases \
    extended_history \
    hist_ignore_all_dups \
    hist_ignore_dups \
    hist_ignore_space \
    hist_reduce_blanks \
    hist_save_no_dups \
    hist_verify \
    ignore_eof \
    list_types \
    noclobber \
    noflowcontrol \
    prompt_percent \
    prompt_subst \
    pushd_ignore_dups \
    rm_star_wait \
    share_history

# }}}
# {{{ environment settings

umask 027

extra_path=(
    $HOME/bin \
    $HOME/.nodejs/nodejs/bin \
    $HOME/.cargo/bin \
    $HOME/.local/bin \
    $HOME/.luarocks/bin/ \
    /sbin \
    /usr/sbin \
    /usr/local/bin \
    /usr/local/sbin \
)
export PATH="${(j|:|)extra_path}:$PATH"

# Prepend : so man also references default config file.
export MANPATH=":${HOME}/share/man:${MANPATH}"

CDPATH=$CDPATH::$HOME:/usr/local

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=65536  # search this with `grep | sort -u`
HISTSIZE=4096
SAVEHIST=4096

# Output time stats for progs that run for longer than a minute.
REPORTTIME=60

# Add memory and disk usage stats to time output.
TIMEFMT='time: %J
time: %U user; %S system; %E real; %P cpu; total disk %K KB; max RSS %M KB'

# Report any login/logout of other users.
WATCH=notme
WATCHFMT='%n %a %l from %m at %T.'

export EDITOR='vim'
export VISUAL=$EDITOR
export PAGER='less -imMWR'
export MANPAGER="$PAGER"
export BROWSER='firefox'

export WINEDEBUG=-all
export WINEARCH=win32

export PYTHONSTARTUP=$HOME/.pythonrc.py
export LYNX_CFG_PATH=/etc/lynx
export LYNX_CFG=$HOME/.lynx/lynx.cfg

# }}}
# {{{ completions

# Use somecommand <ctrl-x>h  to invoke completion help output.
# Use the following to output helpful messages during a completion:
#     zstyle ':completion:*' group-name ''
#     zstyle ':completion:*' format 'Completing "%d":'

compinit -C

zstyle ':completion:*' list-colors "$LS_COLORS"

zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|nc|rsync):*' hosts '
    reply=( ${=${${(M)${(f)"$(cat ~/.ssh/config ~/.ssh/*.conf)"}:#Host*}#Host }:#*\**} )'

# Open kill and fg options in a selection menu:
zstyle ':completion:*:*:(kill|fg):*' menu yes select
zstyle ':completion:*:*:(kill|fg):*' complete-options true

# Disable Git completion for remote branch names without a 'remote/' prefix.
zstyle ':completion::complete:git-checkout:argument-rest:remote-branch-refs-noprefix' command 'echo'

# Custom script in $HOME/bin
compdef c=curl

# }}}
# {{{ prompt and theme

# Set vi-mode and create a few additional Vim-like mappings
bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "ga" what-cursor-position
bindkey -M viins '^p' history-beginning-search-backward
bindkey -M vicmd '^p' history-beginning-search-backward
bindkey -M viins '^n' history-beginning-search-forward
bindkey -M vicmd '^n' history-beginning-search-forward

# Edit command with an external editor
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

# Restore bash/emacs defaults.
bindkey '^U' backward-kill-line
bindkey '^Y' yank

# Set up prompt
if [[ ! -n "$ZSHRUN" ]]; then
    autoload -U colors && colors

    promptseg=( \
        # In incognito mode?
        '%{${fg[yellow]}%}' \
        '$(test ${+HISTFILE} -eq 0 && echo !!)' \
        '%{${reset_color}%}' \

        # In dotfiles mode?
        '$(test -n "$GIT_WORK_TREE" && git prompt -c zsh)' \

        # Any background jobs?
        '%(1j.%j .)' \

        # Last command failed?
        '%(0?.%{${fg[white]}%}.%{${fg[red]}%})' \
        '%#' \
        '%{${reset_color}%}' \

        # Breathe.
        ' ' \
    )
    PS1=${(j::)promptseg}

    # Fish-like syntax highlighting for Zsh:
    # https://github.com/zsh-users/zsh-syntax-highlighting.git
    if [[ -d $HOME/.zsh-syntax-highlighting/ ]]; then
        source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS+=( brackets pattern )
    fi
fi

# Are we inside a Vim 8 :terminal?
if [[ -n "$VIM_TERMINAL" ]]; then

    # Cause the running Vim to open a given file.
    # Usage (from within Vim):
    #   :term ++close
    #   vim-open somefile.txt
    function vim-open() {
        fname="${1:?File name missing}"
        printf '\e]51;["drop","%s"]\a' "$fname"
        exit
    }
fi

# }}}
# {{{ aliases

# lr but through a wrapper
unalias ls la ll 2>/dev/null

# Regular Vim
alias vi=$EDITOR; compdef vi=vim
# Fast Vim (no vimrc, syntax, ftplugins) for big files
alias vv="${EDITOR} -N -u NONE"; compdef vv=vim
# Vim without plugins for debugging weird behavior
alias vvv="${EDITOR} -N --noplugin"; compdef vvv=vim
# Vim for profiling slow startup or initialization
alias vimprof="${EDITOR} \
    --cmd 'profile start vim-profile.log' \
    --cmd 'profile func *' \
    --cmd 'profile file *'"; compdef vimprof=vim

# Open a list of file names that contain line and column information as
# quickfix entries (Quickfix is preferable because Vim's arglist doesn't suport
# columns nor line information for more than one file).
#
# Usage:
#
#     vimjump path/to/foo.txt:30:22 path/to/bar:40:19
#
function vimjump () {
    "$EDITOR" -q <(printf '%s: \n' "$@")
}

alias pp='pepper --config ~/.config/pepper/init.pp'

# Aliases that override default names:
alias less='less -imJMW'
tree() { command tree -FC --charset=ascii "$@" | less -RF }
alias csi='rlwrap csi -quiet'
alias noderepl='rlwrap -z node_complete.pl ~/bin/noderepl.js'
alias ocaml='rlwrap ocaml'
alias R='R --no-save'
alias ifstat='ifstat -S -n -z 5'
alias cloc='cloc --exclude-list-file ~/.cloc-exclude-list-file'

# Aliases around scripts in $HOME/bin:
alias tea-timer="countdown 120 && notify-send 'Tea!' 'Tea is done.'"
alias fetchall-gh='git fetchall "git@github.com"'
alias fetchall-gl='git fetchall "git@gitlab.com"'

# Aliases that make new things:
alias ducks='du -cks * | sort -rn | head -15'
alias incognito=' unset HISTFILE'
alias osx_openports='lsof -iTCP -sTCP:LISTEN -P'
alias rs='rsync -ah --info=progress2'
compdef rs=rsync

# Print all files under the current path without prefixed path.
# Useful for listing files under one path based on the files in another. E.g.:
# cd /path/to/dotfiles; filesunder | xargs -0 -I@ ls -l $HOME/@
alias filesunder='find . \( -name .git -type d \) -prune -o -type f -printf "%P\0"'
alias filesmissing='find . -maxdepth 2 -xtype l'

# Quickly ssh through a bastion host without having to hard-code in ~/.ssh/config
alias pssh='ssh -o "ProxyCommand ssh $PSSH_HOST nc -w1 %h %p"'

# mkdir and cd at once
mkcd() { mkdir -p -- "$1" && cd -- "$1" }
compdef mkcd=mkdir

# Create a disposable directory and cd to it.
# Useful for mucking around with temporary files that will be auto-deleted.
cdtmp() { cd $(mktemp -d --suffix="-${1:-"cdtmp"}") }

# Export all environment variables defined in an .env file.
senv() { set -a; source .env; set +a; }

# Override GNU info to open info pages in less instead.
function info() { command info "$@" \
    | vim +'exe search(".") ? "" : "quit!"' -M +MANPAGER - }

# Wrap man to use Vim as MANPAGER.
function _man() {
    [[ $# -eq 0 ]] && return 1
    MANPAGER='cat' command man "$@" | col -b \
        | vim +'exe search(".") ? "" : "quit!"' -M +MANPAGER -
}
# Zsh's completion invokes man on tab so avoid a recursive definition.
alias man='_man'

# Override ~/bin/mdless use our Zsh function _man override
function mdless() { command mdless "$@" | _man -l -; }

# Useful for working with Git remotes; e.g., `git log IN`, `git diff OUT`.
alias -g IN='..@{u}'
alias -g IIN='...@{u}'
alias -g OUT='@{u}..'
alias -g OOUT='@{u}...'
alias -g UP='@{u}'

# Choose the last item in the filename glob.
alias -g LAST='*([-1])'

# Selects a random file: `mpv RANDOM`
alias -g RANDOM='"$(shuf -e -n1 *)"'

# Output stderr in red. Usage: somecomand RED
alias -g RED='2> >(while read line; do echo -e "\e[01;31m$line\e[0m" >&2; done)'

# Output names if terminal can handle 256 colors.
alias 256test='echo -e "\e[38;5;196mred\e[38;5;46mgreen\e[38;5;21mblue\e[0m"'

# Associate an ssh-agent process with the life of a tmux session.
export TMUX_AUTH_SOCK=$HOME/.ssh/ssh-auth-sock
alias tm="exec ssh-agent \
    sh -c 'ln -sfn \$SSH_AUTH_SOCK $TMUX_AUTH_SOCK; \
    SSH_AUTH_SOCK=$TMUX_AUTH_SOCK exec tmux new-session -A -E -s 0'"
# systemd version to prevent getting killed on logout (>_<)
alias tms="exec ssh-agent \
    sh -c 'ln -sfn \$SSH_AUTH_SOCK $TMUX_AUTH_SOCK; \
    SSH_AUTH_SOCK=$TMUX_AUTH_SOCK \
    exec systemd-run --scope --user tmux new-session -A -E -s 0'"
# ssh ForwardAgent version:
alias tmf="test -n \"\$SSH_AUTH_SOCK\" || return 1; \
    ln -sfn \$SSH_AUTH_SOCK $TMUX_AUTH_SOCK; \
    SSH_AUTH_SOCK=$TMUX_AUTH_SOCK exec tmux \
    new-session -A -E -s 0\; \
    set -s set-clipboard external"

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
# dotfiles Toggle Git dir and work-tree env vars {{{1
#
# I don't want the usual `--git-dir=<dir> --work-tree=<dir>` alias to work on
# my dotfiles; I'd rather stick with the vanilla `git` command for the muscle
# memory and tmux status display. This function turns "dotfiles mode" on and
# off by setting and unsetting env vars instead.

dotfiles () {
    if [[ "$GIT_WORK_TREE" = "$HOME" ]]; then
        unset GIT_DIR
        unset GIT_WORK_TREE
    else
        export GIT_DIR="${HOME}/src/dotfiles.git"
        export GIT_WORK_TREE="$HOME"
    fi
}

# }}}
# Use a fuzzy-finder for common CLI tasks {{{1

# cd to a parent directory.
function ...() {
    new_dir="$(explode_path | tail -n +2 | fzy -p 'Parents > ')"
    if [ -n "$new_dir" ]; then
        cd "$new_dir"
    else
        return 1
    fi
}

function timesheets() {
    local timesheets_dir="${HOME}/src/timesheets"
    local tgt_dir=$(find "$timesheets_dir" -mindepth 1 -maxdepth 1 \
            -name .git -prune -o -type d -printf '%P\n' \
        | fzy -p 'Choose timesheet > ' ${1:+-q "$1"})
    local new_dir="${timesheets_dir}/${tgt_dir}"

    if [ -d "$new_dir" ]; then
        cd "$new_dir"
    fi
}

# A completion fallback if something more specific isn't available.
function _fzy_generic_find() {
    local cmd="$1"; shift 1
    flr . 2>/dev/null | fzy -p 'Files > ' -q "$*" \
        | xargs printf '%s %s\n' "$cmd"
}

# Invoke a fuzzy-finder to complete history, file paths, or command arguments
# Press ctrl-f to start completion.
# (This idea is stolen from fzf.)
#
# Usage:
#   <[empty cli]> - complete from tmux scrollback.
#   <cmd> - complete from _fzy_<cmd> script or function output.
#   <cmd> - falls back to generic file path completion.
#
# New completions can be added for a <cmd> by adding a shell function or
# a shell script on PATH with the pattern _fzy_<cmd>. The script will be
# invoked with the command name and any arguments as ARGV and should print the
# full resulting command and any additions to stdout.
fzy-completion() {
    setopt localoptions localtraps noshwordsplit noksh_arrays noposixbuiltins

    local tokens=(${(z)LBUFFER})
    local cmd=${tokens[1]}
    local cmd_fzy_match

    if [[ ${#tokens} -gt 1 ]]; then
        # Filter (:#) the arrays of the names ((k)) Zsh function and scripts on
        # PATH and remove ((M)) entries that don't match "_fzy_<cmdname>":
        cmd_fzy_match=${(M)${(k)functions}:#_fzy_${cmd}}
        if [[ ${#cmd_fzy_match} -eq 0 ]]; then
            cmd_fzy_match=${(M)${(k)commands}:#_fzy_${cmd}}
            if [[ ${#cmd_fzy_match} -eq 0 ]]; then
                cmd_fzy_match=( '_fzy_generic_find' )
            fi
        fi
    fi

    zle -M "Gathering suggestions..."
    zle -R

    local result=$($cmd_fzy_match "${tokens[@]}")
    if [ -n "$result" ]; then
        LBUFFER="$result"
    fi

    zle reset-prompt
}

zle -N fzy-completion
bindkey '^F' fzy-completion

# }}}
# Manually refresh the tmux status infos {{{1
# Needed to immediate update the Git status display.

function refresh_tmux() {
    tmux refresh -S 2>/dev/null
}

_last_cmd_was_git=0
function last_command_was_git() {
    if [[ "$1" == git* ]]; then
        _last_cmd_was_git=1
    else
        _last_cmd_was_git=0
    fi
}

function refresh_tmux_on_git() {
    if [[ "$_last_cmd_was_git" -eq 1 ]]; then
        tmux refresh -S 2>/dev/null
    fi
}

function ssh_tmux_status() {
    [[ "$1" == 'ssh '* ]] && tmux selectp -T "${1##ssh }" 2>/dev/null
}

# }}}

# Run precmd functions
preexec_functions=( last_command_was_git ssh_tmux_status )
chpwd_functions=( refresh_tmux )
precmd_functions=( refresh_tmux_on_git )

# Allow OS or environment specific overrides:
if [[ -r "$HOME/.zsh_customize" ]]; then
    source "$HOME/.zsh_customize"
fi

# End profiling:
# zprof

# EOF
