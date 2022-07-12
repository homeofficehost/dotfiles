#!/bin/bash

LOCAL_USER=$2
# Restore pass
PASSWORD_STORE_REPO=$1

if [[ ! -e ~/.password-store ]]; then
	git clone "$PASSWORD_STORE_REPO" ~/.password-store
fi
if [[ -z $(which pass) ]]; then # if are not installed
	if [[ -n $(which pacman) ]]; then # if are installed
		sudo pacman -S --noconfirm pass
	elif [[ -n $(which apt) ]]; then
		sudo apt install -y pass
	fi
fi

curl -Lks https://raw.githubusercontent.com/homeofficehost/dotfiles/master/ansible.sh | /bin/bash
