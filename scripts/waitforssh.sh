#!/bin/sh

###########################
# This fast script set sensitive defaults on macOS
###########################
source $MY_DOTFILES/lib_sh/echos.sh

function connect(){
	password="pipi"
	expect << EOF
spawn /usr/bin/$@
expect {
    ".*key fingerprint" {send "yes\r"; exp_continue}
    "assword:" {send "$password\r"}
}
expect eof
EOF
}

TMUX_CMD="source ~/.profile && tmux -u -CC attach || tmux -u -CC; ${ARGUMENTS}"
INPUT_ARGUMENTS=${@:2}

if [ -n "${INPUT_ARGUMENTS}" ]; then
	# No args passed so dont need tmux on remote code execution
	ARGUMENTS="${INPUT_ARGUMENTS}"
else
	running "Checking if remote got tmux instaled"
	REMOTE_TMUX_CMD=$(connect ssh $1 which tmux);ok

	if [ -z "${REMOTE_TMUX_CMD}" ]; then
		warn "tmux not available on remote."

		bot "Do you want me to setup tmux on remote machine? \n"
		read -t 3 -r -p "Install tmux on remote? (y|N) [or wait 3 seconds for default=N] " response
		response=${response:-N}

		if [[ $response =~ (yes|y|Y) ]];then
		
			running "Installing tmux on remote"
			if [[ "$(connect ssh $1 uname -s)" != "Darwin" ]]; then
				connect ssh $1 sudo apt-get install tmux
			else
				connect ssh $1 brew install tmux
			fi
			ok

			running "Checking again if remote tmux"
			if [ -z "$(connect ssh $1 which tmux)" ]; then
				warn "Unable to install tmux on remote"
				ARGUMENTS="${INPUT_ARGUMENTS}"
			fi
			ok
		fi
	fi
fi

ssh -t $1 $ARGUMENTS
while test $? -gt 0
do
   sleep 5 # highly recommended - if it's in your local network, it can try an awful lot pretty quick...
   echo "Trying again..."
   ssh -t $1 $ARGUMENTS
done

exit 0