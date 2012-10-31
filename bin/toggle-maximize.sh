#!/bin/bash -f
# http://superuser.com/a/433702/112064
currentwindow=`tmux list-window | tr '\t' ' ' | sed -n -e '/(active)/s/^[^:]*: *\([^ ]*\) .*/\1/gp'`;
currentpane=`tmux list-panes | sed -n -e '/(active)/s/^\([^:]*\):.*/\1/gp'`;
panecount=`tmux list-panes | wc | sed -e 's/^ *//g' -e 's/ .*$//g'`;
inzoom=`echo $currentwindow | sed -n -e '/^zoom/p'`;
if [ $panecount -ne 1 ]; then
    inzoom="";
fi
if [ $inzoom ]; then
    lastpane=`echo $currentwindow | rev | cut -f 1 -d '@' | rev`;
    lastwindow=`echo $currentwindow | cut -f 2- -d '@' | rev | cut -f 2- -d '@' | rev`;
    tmux select-window -t $lastwindow;
    tmux select-pane -t $lastpane;
    tmux swap-pane -s $currentwindow;
    tmux kill-window -t $currentwindow;
else
    newwindowname=zoom@$currentwindow@$currentpane;
    tmux new-window -d -n $newwindowname;
    tmux swap-pane -s $newwindowname;
    tmux select-window -t $newwindowname;
fi
