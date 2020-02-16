#!/bin/sh

PATH="$HOME/bin:$PATH"
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# Swap ctrl with caps lock.
setxkbmap -option ctrl:nocaps

# Disable key repeating.
xset r off

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Alternative to gnome-settings-daemon for font antialiasing & hinting.
xsettingsd &

xscreensaver -no-splash &

# Remove ssh identities from the running agent when the screensaver activates.
xscreensaver-command -watch \
    | while read a; do echo $a | grep '^LOCK' && ssh-add -D; done &

$HOME/bin/status &
xcape &
uxterm &
exec cwm
