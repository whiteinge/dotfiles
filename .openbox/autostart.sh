# Run the system-wide support stuff
. $GLOBALAUTOSTART

xsetroot -solid "#303030" &
display -window root $HOME/.openbox/background.jpg &

conky &
docker &
volwheel &
