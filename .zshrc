#!/bin/zsh
#
# Best Goddamn zshrc in the whole world (if you're obsessed with Vim).
# Author: Seth House <seth@eseth.com>
# Release: 1.1.0
# Version: $LastChangedRevision$
# Modified: $LastChangedDate$
# thanks to Adam Spiers, Steve Talley
# and to Unix Power Tools by O'Reilly
#
# {{{ setting options

setopt                          \
        auto_cd                 \
        chase_links             \
        noclobber               \
        complete_aliases        \
        extended_glob           \
        hist_ignore_all_dups    \
        hist_ignore_space       \
        ignore_eof              \
        share_history           \
        no_flow_control         \
        list_types              \
        mark_dirs               \
        path_dirs               \
        rm_star_wait

# }}}
# {{{ environment settings

umask 027
PATH=$PATH:$HOME/bin:/sbin:/usr/X11/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin
MANPATH=$MANPATH:/usr/X11/man:/usr/local/man:/usr/local/share/man:/usr/man:/usr/share/man
CDPATH=$CDPATH::$HOME:/usr/local:/opt/local

HISTFILE=$HOME/.zsh_history
HISTSIZE=500
SAVEHIST=500

REPORTTIME=60       # Report time statistics for progs that take more than a minute to run
WATCH=notme         # Report any login/logout of other users
WATCHFMT='%n %a %l from %m at %T.'

# great for displaying utf-8 in the terminal, but it tends to break old apps
LANG=en_US.UTF-8 
LC_CTYPE=en_US.UTF-8

EDITOR=vi
VISUAL=vi
PAGER='less -imJMWN'
MANPAGER='less -imJMWN'
BROWSER='firefox'

# SSH Keychain
# http://www.gentoo.org/proj/en/keychain/
if which keychain >& /dev/null && [[ $UID != 0 ]]; then
    eval $(keychain -q --eval id_rsa)
fi

# }}}
# {{{ completions

autoload -U compinit
compinit -C
zstyle ':completion:*' list-colors "$LS_COLORS"
zstyle ':completion:*:*:*:users' ignored-patterns adm apache bin daemon ftp games gdm halt ident junkbust lp mail mailnull mysql named news nfsnobody nobody nscd ntp operator pcap pop postgres radvd rpc rpcuser rpm shutdown smmsp squid sshd sshfs sync uucp vcsa xfs
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle -e ':completion:*:(ssh|scp|sshfs|ping|telnet|ftp|rsync):*' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,$HOME/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# }}}
# {{{ prompt and theme

autoload -U promptinit
promptinit

# Keywords: black, red, green, yellow, blue, magenta, cyan, and white
# prompt adam2 hyphens cur-dir user@host user-input
if [[ $TERM == 'xterm-256color' || $TERM == 'screen-256color' ]]; then
    prompt adam2 bg_grey green magenta white
else
    prompt adam2 yellow green magenta white
fi

# }}}
# {{{ vi mode, mode display and extra vim-style keybindings
# TODO: why is there a half-second delay when pressing ? to enter search?
#       Update: found out has something to do with $KEYTIMEOUT and that
#       command-mode needs to use the same keys as insert-mode
# TODO: bug when searching through hist with n and N, when you pass the EOF the
#       term decrements the indent of $VIMODE on the right, which will collide
#       with the command you're typing

bindkey -v
bindkey "^?" backward-delete-char
bindkey -M vicmd "^R" redo
bindkey -M vicmd "u" undo
bindkey -M vicmd "ga" what-cursor-position
bindkey -M viins '^p' history-search-backward
bindkey -M vicmd '^p' history-search-backward
bindkey -M viins '^n' history-search-forward
bindkey -M vicmd '^n' history-search-forward

autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd "v" edit-command-line

showmode() { # may need adjustment with non adam2 themes
    RIGHT=$[COLUMNS-11]
    echo -n "7[$RIGHT;G" # one line down, right side
    echo -n "--$VIMODE--" # will be overwritten during long commands
    echo -n "8" # returns cursor to last position (normal prompt position)
}
makemodal () {
    eval "$1() { zle .'$1'; ${2:+VIMODE='$2'}; showmode }"
    zle -N "$1"
}
makemodal vi-add-eol           INSERT
makemodal vi-add-next          INSERT
makemodal vi-change            INSERT
makemodal vi-change-eol        INSERT
makemodal vi-change-whole-line INSERT
makemodal vi-insert            INSERT
makemodal vi-insert-bol        INSERT
makemodal vi-open-line-above   INSERT
makemodal vi-substitute        INSERT
makemodal vi-open-line-below   INSERT
makemodal vi-replace           REPLACE
makemodal vi-cmd-mode          NORMAL
unfunction makemodal

# }}}
# {{{ aliases

alias ls='ls -F --color'
alias la='ls -A'
alias ll='ls -lh'

# .svn exclusioqn doesn't work very well, but it's better than nothing.
alias grep='grep --color --exclude=\*.svn\* --exclude=\*.pyc'

alias less='less -imJMWN'
alias cls='clear' # note: ctrl-L under zsh does something similar
alias ssh='ssh -X -C'
alias locate='locate -i'
alias lynx='lynx -cfg=$HOME/.lynx.cfg -lss=$HOME/.lynx.lss'
alias ducks='du -cks * | sort -rn | head -15'
alias tree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias ps='ps -opid,uid,cpu,time,stat,command'

alias sc="exec screen -e'^Aa' -RD"
alias rsc="exec screen -e'^Ss' -RD"
if [[ $TERM == 'xterm-256color' ]]; then
    alias sc="exec screen -e'^Aa' -RD -T xterm-256color"
    alias rsc="exec screen -e'^Ss' -RD -T xterm-256color"
fi

alias vi='vim'
alias view='view'

# OS X versions
if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -FG'
    unalias locate
    alias lynx='lynx -cfg=$HOME/.lynx.cfg'
    alias top='top -ocpu'
fi

# }}}
# Miscellaneous Functions:
# {{{ calc()
# Command-line calculator (has some limitations...not sure the extent)(based on zsh functionality)

alias calc="noglob _calc"
function _calc() {
    echo $(($*))
}

# }}}
# {{{ body() | like head and tail

# Provides an in-between to head and tail to print a range of lines
# Usage: `body firstline lastline filename`
function body() {   
    head -$2 $3 | tail -$(($2-($1-1)))
}

# }}}
# {{{ pkill()
# Because OS X doesn't have pgrep :-(

function pkill() {
    HOSTTYPE=$(uname -s)

    SIGNAL=$1
    STRING=$2

    if [ -z "$1" -o -z "$2" ]
    then
        echo Usage: $0 signal string
        exit 1
    fi

    case $HOSTTYPE in
        Darwin|BSD)
        ps -a -opid,command | grep $STRING | awk '{ print $1; }' | xargs kill $SIGNAL
        ;;
        Linux|Solaris|AIX|HP-UX)
        ps -e -opid,command | grep $STRING | awk '{ print $1; }' | xargs kill $SIGNAL
        ;;
    esac
}

# }}}
# {{{ bookletize()
# Converts a PDF to a fold-able booklet sized PDF
# Print it double-sided and fold in the middle

bookletize ()
{
    if which pdfinfo && which pdflatex; then
        pagecount=$(pdfinfo $1 | awk '/^Pages/{print $2+3 - ($2+3)%4;}')

        # create single fold booklet form in the working directory
        pdflatex -interaction=batchmode \
        '\documentclass{book}\
        \usepackage{pdfpages}\
        \begin{document}\
        \includepdf[pages=-,signature='$pagecount',landscape]{'$1'}\
        \end{document}' 2>&1 >/dev/null
    fi
}

# }}}
# {{{ joinpdf()
# Merges, or joins multiple PDF files into "merged.pdf"

joinpdf () {
    gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=merged.pdf "$@"
}

# }}}
# {{{ dotsync()
# Checks for the lastest versions of various config files

dotsync ()
{
    dotsyncURI=http://eseth.org/filez/prefs
    dotsyncFiles=(
        Xresources
        lynx.cfg
        lynx.lss
        lynxrc
        nethackrc
        screenrc
        toprc
        vimrc
        gvimrc
        zshrc
    )
    dotsyncVimPlugins=(
        ToggleComment.vim
        vimbuddy.vim
    )
    dotsyncMozFiles=(
        bookmarks.html
        user.js
    )
    dotsyncMozChrome=(
        userChrome.css
        userContent.css
    )

    # Firefox files
    if [[ $1 == 'moz' ]]; then
        if pgrep firefox >& /dev/null; then
            echo "Please close Firefox first since it will overwrite these files on exit"
            return 1;
        fi
        if [[ ! -L $HOME/.firefox_home ]]; then
            echo "Symlink your Firefox profile dir to ~/.firefox_home first"
            return 1;
        fi
        for file in $dotsyncMozFiles
        do
            curl -f $dotsyncURI/$file -o $HOME/.firefox_home/$file
        done
        for file in $dotsyncMozChrome
        do
            curl -f $dotsyncURI/$file -o $HOME/.firefox_home/chrome/$file
        done
        return 0;
    fi

    # Misc dot files
    for file in $dotsyncFiles
    do
        curl -f -z $HOME/.$file $dotsyncURI/$file -o $HOME/.$file
    done

    # Vim files
    mkdir -m 750 -p $HOME/.vim/{tmp,plugin}
    for file in $dotsyncVimPlugins
    do
        curl -f -z $HOME/.vim/plugin/$file $dotsyncURI/$file -o $HOME/.vim/plugin/$file
    done

}

# }}}
# Useful for the Sony Reader {{{

html2reader() {
    echo htmldoc --gray --no-title --no-embedfonts --textcolor black --fontsize 12 --header ... --footer ... --left 1mm --right 1mm --top 1mm --bottom 1mm --size 90x120mm -f $(basename $1 '.html').pdf $1
}

# }}}
# svn_up_and_log() {{{
# As seen on http://woss.name/2007/02/01/display-svn-changelog-on-svn-up/

# Get the current revision of a repository
svn_revision()
{
  svn info $@ | awk '/^Revision:/ {print $2}'
}
# Does an svn up and then displays the changelog between your previous
# version and what you just updated to.
svn_up_and_log()
{
  local old_revision=`svn_revision $@`
  local first_update=$((${old_revision} + 1))
  svn up -q $@
  if [ $(svn_revision $@) -gt ${old_revision} ]; then
    svn log -v -rHEAD:${first_update} $@
  else
    echo "No changes."
  fi
}

# }}}
# {{{ Django functions djedit & djsetup

# run this in your base project dir
djsetup()
{
    cd ..
    export PYTHONPATH=$PWD
    export DJANGO_SETTINGS_MODULE=$(basename $OLDPWD).settings
    cd -
}

# This loads all the app files.
djedit() {
    screen -t $(basename $1) vim "+cd $1" \
        $1/__init__.py \
        "+argadd **/*py" \
        "+argadd **/*html"
}

# }}}
# {{{ Displays the titles and their length in a VIDEO_TS folder

dvd_info()
{
    mplayer dvd:// -dvd-device $1 -identify -ao null -vo -null -frames 0 | grep '^ID_DVD'
}

# }}}
# EOF
