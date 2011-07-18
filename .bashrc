shopt -s globstar
shopt -s checkjobs
shopt -s autocd

export PYTHONSTARTUP=$(echo $HOME)/.pythonrc.py
EDITOR=vi
VISUAL=vi

alias ls='ls -F --color'
alias la='ls -A'
alias ll='ls -lh'

source ~/.git-completion.bash
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM="verbose"
PS1='\u@\h:\W$(__git_ps1 " (%s)")\$ '
