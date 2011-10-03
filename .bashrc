shopt -s globstar
shopt -s checkjobs
shopt -s autocd

export SCREEN_AUTH_SOCK=$HOME/.screen/ssh-auth-sock
export PYTHONSTARTUP=$(echo $HOME)/.pythonrc.py
export EDITOR=vi
export VISUAL=vi

alias ls='ls -F --color'
alias la='ls -A'
alias ll='ls -lh'

alias rtm="exec sh -c 'ln -sfn \$SSH_AUTH_SOCK $SCREEN_AUTH_SOCK; \
    SSH_AUTH_SOCK=$SCREEN_AUTH_SOCK exec tmux attach'"

source ~/.git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM="verbose"
PS1='\u@\h:\W$(__git_ps1 " (%s)")\$ '
