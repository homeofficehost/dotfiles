#!/bin/bash

source $MY_DOTFILES/lib_sh/echos.sh

running "Delete all .DS_Store from mac"
sudo find / -name ".DS_Store" -type f -ls -delete;ok
