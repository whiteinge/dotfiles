# Run the system-wide support stuff
. $GLOBALAUTOSTART

xsetroot -solid "#303030" &
display -window root $HOME/.openbox/background.jpg &

conky &
MPD_HOST=localhost MPD_PORT=6600 WMmp &
wmix &
wmsystray -geometry 64x32 &
