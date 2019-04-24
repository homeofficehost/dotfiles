#!/bin/sh

TMUX_CMD="source ~/.profile && tmux -u -CC attach || tmux -u -CC"
# TODO: Check if remote got tmux instaled
ssh -t $1 $TMUX_CMD
while test $? -gt 0
do
   sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
   echo "Trying again..."
   ssh -t $1 $TMUX_CMD
done