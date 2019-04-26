#!/bin/sh

###########################
# This fast script set sensitive defaults on macOS
# ~/.macos — https://mths.be/macos
# --------------------------
# 
###########################
source $MY_DOTFILES/lib_sh/echos.sh

# running "Checking if remote got tmux instaled"
if [ -z "$(ssh $1 which tmux)" ]; then
	warn "tmux not available on remote."

	bot "Do you want me to setup tmux on remote machine? \n"
	read -r -p "Install tmux on remote? (y|N) [default=N] " response
	response=${response:-N}
	if [[ $response =~ (no|n|N) ]];then
		ssh $1
		while test $? -gt 0
		do
		   sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
		   echo "Trying again..."
		   ssh $1
		done
		exit 0
	fi

	running "Installing tmux on remote"
	if [[ "$(ssh $1 uname -s)" != "Darwin" ]]; then
		ssh $1 sudo apt-get install tmux
	else
		ssh $1 brew install tmux
	fi
	ok

	running "Checking again if remote tmux"
	if [ -z "$(ssh $1 which tmux)" ]; then
		error "Unable to install tmux on remote"
		exit 1
	fi
	ok
fi

TMUX_CMD="source ~/.profile && tmux -u -CC attach || tmux -u -CC"
ssh -t $1 $TMUX_CMD
while test $? -gt 0
do
   sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
   echo "Trying again..."
   ssh -t $1 $TMUX_CMD
done

exit 0