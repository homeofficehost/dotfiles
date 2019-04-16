#!/bin/bash

# fail hard
set -o pipefail
# fail on first error
set -e
# fail no variables
# set -u
# IFS=$'\n\t'

###########################
# This script run my prefs to use sortphotos
# --------------------------
# https://github.com/andrewning/sortphotos
# TODO: Copy questions
###########################
source $MY_DOTFILES/lib_sh/echos.sh

SRC_PATH="${1:-}"
DEST_PATH="${2:-}"

bot "Apply default fixes on $COL_YELLOW$SRC_PATH$COL_RESET"
read -r -p "Do you want to reset file permissions recursively? (y|N|r) [default=N] " response
response=${response:-N}
if [[ $response =~ (yes|y|Y) ]];then	

	# Ask for the administrator password upfront
	bot "I need you to enter your sudo password so I can install some things."

	if ! sudo grep -q "%wheel   ALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

	  sudo -v

	fi

	running "Unlock$COL_YELLOW chflags nouchg $COL_RESETto all files"
	sudo find "${SRC_PATH}" -user "$USER" -not -type d -exec chflags nouchg {} \;
	ok

	running "All files to$COL_YELLOW staff $COL_RESET group"
	sudo chown -R $USER:staff ${SRC_PATH}/**/*
	ok

	running "All folders to$COL_YELLOW 770 $COL_RESETpermissions"
	sudo find "${SRC_PATH}" -user "$USER" -type d -exec chmod 770 {} \;
	ok

	running "All files to$COL_YELLOW 660 $COL_RESETpermissions"
	sudo find "${SRC_PATH}" -user "$USER" -not -type d -exec chmod 660 {} \;
	ok

fi

bot "No lets organize it"
read -n 1 -s -r -p "Press any key to continue";echo ""

running "Moving files from $COL_YELLOW$SRC_PATH$COL_RESET to $COL_YELLOW$DEST_PATH$COL_RESET"
python2 ~/dev/sortphotos/build/lib/src/sortphotos.py $SRC_PATH $DEST_PATH --recursive --rename %Y_%m%d_%H%M --day-begins 4  >photo_magic_`date +\%Y-\%m-\%d-\%H:\%M:\%S.log` 2>&1
ok
