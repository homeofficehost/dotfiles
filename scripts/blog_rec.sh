#!/bin/bash

# fail hard
set -o pipefail
# fail on first error
set -e
# fail no variables
# set -u
# IFS=$'\n\t'

###########################
# This script quick record shell session
# --------------------------
# 
###########################
source $MY_DOTFILES/lib_sh/echos.sh

DATE=`date +\%Y_\%m_\%d_\%H_\%M_\%S`
RECORD_NAME=$1
# RECORD_NAME="${1:-"${DATE}"}"
FILE_PATH="${HOME}/casts/"
FILE_NAME="asciinema_${RECORD_NAME}"
_NAME="${FILE_PATH}${FILE_NAME}"
_FILE="${_NAME}.cast"

[[ -e $_FILE ]] && \
running "File found, play: $COL_YELLOW$_FILE$COL_RESET" && \
asciinema play -i 2.5 $_FILE;ok

mkdir -p $FILE_PATH
asciinema rec -i 2.5 $_FILE;ok
# asciinema rec -i 2.5 $_FILE >$_NAME.log 2>&1

bot "Perfect! Saved to $COL_YELLOW$_FILE$COL_RESET?"
read -r -p "Do you want to upload it? (y|N) [default=N] " response
[[ $response =~ ^(yes|y|Y) ]] && \
running "uploading: $COL_YELLOW$_FILE$COL_RESET" && \
asciinema upload $_FILE;ok

read -r -p "Do you want to delete it? (y|N) [default=N] " response
[[ $response =~ ^(yes|y|Y) ]] && \
running "deleting: $COL_YELLOW$_FILE$COL_RESET" && \
rm $_FILE;ok

# asciinema upload $_FILE
