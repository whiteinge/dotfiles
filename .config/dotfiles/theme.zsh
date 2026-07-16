# theme.zsh --- grayscale light/dark toggle for e-ink readability.
#
# Single source of truth: the terminal's own default fg/bg. Everything we own
# (tmux styles, the zsh prompt, ls colors) is expressed in terms of "terminal
# default + a monochrome attribute" rather than a named colour, so flipping the
# terminal's default fg/bg flips them all at once. Foreign programs that emit
# their own colours are caught by the OSC-4 grayscale ramp below (or switched
# off in light mode where a ramp can't help, e.g. truecolor pygments).
#
#   theme light | dark   set mode: repaint this terminal + persist + shell vars
#   theme toggle         flip to the other mode
#   theme status         print the persisted mode (defaults to dark)
#   theme apply          repaint this shell/terminal from the persisted mode
#                        (used at startup so new shells/panes inherit the mode)

: ${THEME_STATE_FILE:=${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/theme.state}

# Light-mode grayscale ramp for the 16 ANSI colours (dark inks on white). This
# is the one table of values we maintain; dark mode just resets to .Xresources.
typeset -ga _THEME_RAMP=(
    000000 303030 4d4d4d 5c5c5c 383838 444444 565656 1c1c1c
    6e6e6e 262626 3f3f3f 4d4d4d 2b2b2b 383838 464646 000000
)

# Send an escape sequence to the real terminal, tunnelling through tmux when
# inside it (wrap in a DCS passthrough and double every ESC). Requires
# `set -g allow-passthrough on` in .tmux.conf.
_theme_emit() {
    local seq=$1 esc=$'\e'
    if [[ -n $TMUX ]]; then
        # $'...' is not expanded inside ${//}, so double ESC via a variable.
        printf '\ePtmux;%s\e\\' "${seq//$esc/$esc$esc}"
    else
        printf '%s' "$seq"
    fi
}

# Repaint the terminal for a mode (terminal-level state only).
_theme_paint() {
    local mode=$1 i
    if [[ $mode == light ]]; then
        _theme_emit $'\e]10;#000000\a'   # default foreground -> black
        _theme_emit $'\e]11;#ffffff\a'   # default background -> white
        _theme_emit $'\e]12;#000000\a'   # cursor -> black
        for i in {0..15}; do             # grayscale ANSI ramp
            _theme_emit $'\e]4;'"${i};#${_THEME_RAMP[i+1]}"$'\a'
        done
        _theme_emit $'\e[?12l'           # stop cursor blink (e-ink ghosting)
    else
        _theme_emit $'\e]110\a'          # reset fg     to .Xresources default
        _theme_emit $'\e]111\a'          # reset bg     to .Xresources default
        _theme_emit $'\e]112\a'          # reset cursor to .Xresources default
        _theme_emit $'\e]104\a'          # reset all ANSI colours to defaults
        _theme_emit $'\e[?12h'           # restore cursor blink
    fi
}

# Apply shell-level colour settings for a mode, in THIS shell. In light mode we
# simply switch off colour sources that can't follow the terminal default.
_theme_shell() {
    local mode=$1
    if [[ $mode == light ]]; then
        unset LESSOPEN                   # pygments style is dark-only truecolor
        export LR_GNU_COLORS=0           # uncoloured ls
        ZSH_HIGHLIGHT_HIGHLIGHTERS=()    # no syntax highlighting
        _THEME_ERR=$'\e[7m'              # prompt error marker: reverse video
        _THEME_ERR_OFF=$'\e[27m'
    else
        export LESSOPEN=$_THEME_LESSOPEN_DARK
        export LR_GNU_COLORS=$_THEME_LRCOLORS_DARK
        ZSH_HIGHLIGHT_HIGHLIGHTERS=("${_THEME_HL_DARK[@]}")
        _THEME_ERR=$'\e[31m'             # prompt error marker: red
        _THEME_ERR_OFF=$'\e[39m'
    fi
}

theme() {
    local mode
    case ${1:-status} in
        light|dark) mode=$1 ;;
        toggle)     [[ $(theme status) == light ]] && mode=dark || mode=light ;;
        status)
            if [[ -r $THEME_STATE_FILE ]]; then print -r -- "$(<$THEME_STATE_FILE)"
            else print -r -- dark; fi
            return ;;
        apply)  mode=$(theme status) ;;
        *)      print -u2 -- 'usage: theme [light|dark|toggle|status|apply]'; return 2 ;;
    esac

    _theme_paint $mode
    _theme_shell $mode

    if [[ $1 != apply ]]; then           # persist, but `apply` only reads
        mkdir -p -- ${THEME_STATE_FILE:h}
        print -r -- $mode >! $THEME_STATE_FILE
    fi
}

# Capture dark-mode defaults once (this file is sourced after .zshrc sets them),
# so `theme dark` can restore them without duplicating the values here.
: ${_THEME_LESSOPEN_DARK:=$LESSOPEN}
: ${_THEME_LRCOLORS_DARK:=${LR_GNU_COLORS:-1}}
typeset -ga _THEME_HL_DARK
(( ${#_THEME_HL_DARK} )) || _THEME_HL_DARK=("${ZSH_HIGHLIGHT_HIGHLIGHTERS[@]:-main}")

# Inherit the persisted mode in this new shell + its terminal.
theme apply

# vim: ft=zsh
