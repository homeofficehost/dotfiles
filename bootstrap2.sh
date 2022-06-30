#!/bin/bash

# echo $DOTFILES_REF "8acd4815dfe44ee26810b01e6a0129f13781480a"
# echo $WORKSPACE_PATH "/home/runner/work/dotfiles/dotfiles"

LOCAL_USER=$2
# Restore pass
PASSWORD_STORE_REPO=$1
echo -n "${GPG_SIGNING_KEY_PRIVATE}" | base64 --decode | gpg --import
echo -n "${GPG_SIGNING_KEY}" | base64 --decode | gpg --import

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

pass show ansible/workstation/runner