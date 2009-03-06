shopt -s globstar
shopt -s checkjobs
shopt -s autocd

# PS1 from http://thesmithfam.org/blog/2009/01/06/best-bash-prompt-ever/
BLACK="\[\033[0;30m\]"
DARK_GRAY="\[\033[1;30m\]"
LIGHT_GRAY="\[\033[0;37m\]"
BLUE="\[\033[0;34m\]"
LIGHT_BLUE="\[\033[1;34m\]"
GREEN="\[\033[0;32m\]"
LIGHT_GREEN="\[\033[1;32m\]"
CYAN="\[\033[0;36m\]"
LIGHT_CYAN="\[\033[1;36m\]"
RED="\[\033[0;31m\]"
LIGHT_RED="\[\033[1;31m\]"
PURPLE="\[\033[0;35m\]"
LIGHT_PURPLE="\[\033[1;35m\]"
BROWN="\[\033[0;33m\]"
YELLOW="\[\033[1;33m\]"
WHITE="\[\033[1;37m\]"
DEFAULT_COLOR="\[\033[00m\]"

export PS1="\`if [ \$? = 0 ];
    then
        echo -e '$GREEN--( $LIGHT_CYAN\u$YELLOW@$LIGHT_CYAN\h$GREEN )--( $YELLOW\w$GREEN )-- :)\n--\$$DEFAULT_COLOR ';
    else
        echo -e '$LIGHT_RED--( $LIGHT_CYAN\u$YELLOW@$LIGHT_CYAN\h$LIGHT_RED )--( $YELLOW\w$LIGHT_RED )-- :(\n--\$$DEFAULT_COLOR ';
    fi; \`"


# copy and paste from my .zshrc

umask 027

PATH=$HOME/bin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11/bin:/bin:/sbin:/usr/bin:/usr/sbin:$PATH
MANPATH=$HOME/man:/opt/local/share/man:/usr/local/man:/usr/local/share/man:/usr/X11/man:/usr/man:/usr/share/man:$MANPATH
CDPATH=$CDPATH::$HOME:/usr/local

export PYTHONSTARTUP=$(echo $HOME)/.pythonrc.py

HISTFILE=$HOME/.zsh_history
HISTFILESIZE=65536  # search this with `grep | sort -u`
HISTSIZE=4096
SAVEHIST=4096

REPORTTIME=60       # Report time statistics for progs that take more than a minute to run
WATCH=notme         # Report any login/logout of other users
WATCHFMT='%n %a %l from %m at %T.'

# utf-8 in the terminal, will break stuff if your term isn't utf aware
LANG=en_US.UTF-8 
LC_ALL=$LANG
LC_COLLATE=C

EDITOR=vi
VISUAL=vi
PAGER='less -imJMW'
MANPAGER='less -imJMW'
BROWSER='firefox'

# Silence Wine debugging output (why isn't this a default?)
WINEDEBUG=-all

alias vi='vim'

alias ls='ls -F --color'
alias la='ls -A'
alias ll='ls -lh'

# .svn exclusion doesn't work very well, but it's better than nothing.
alias grep='grep --color --exclude=\*.svn\* --exclude=\*.pyc'

alias less='less -imJMW'
alias cls='clear' # note: ctrl-L under zsh does something similar
alias ssh='ssh -X -C'
alias locate='locate -i'
alias lynx='lynx -cfg=$HOME/.lynx.cfg -lss=$HOME/.lynx.lss'
alias ducks='du -cks * | sort -rn | head -15'
alias tree="ls -R | grep \":$\" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"
alias ps='ps -opid,uid,cpu,time,stat,command'

# Starts ssh-agent when screen is started/reattached, stops the agent when
# screen is detached. Use ssh-add to activate key for the session.
SSH_AUTH_SOCK=$HOME/.screen/ssh-auth-sock
alias sc="exec ssh-agent sh -c 'ln -sfn \$SSH_AUTH_SOCK \$HOME/.screen/ssh-auth-sock; exec screen -e\"^Aa\" -S main -DRR'"
alias rsc="exec ssh-agent sh -c 'ln -sfn \$SSH_AUTH_SOCK \$HOME/.screen/ssh-auth-sock; exec screen -e\"^Ss\" -S main -DRR'"
