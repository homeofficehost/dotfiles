#!/bin/bash

# echo $DOTFILES_REF "8acd4815dfe44ee26810b01e6a0129f13781480a"
# echo $WORKSPACE_PATH "/home/runner/work/dotfiles/dotfiles"
echo $GPG_SIGNING_KEY
echo $ASD

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
# Update system
if [[ -z $(which ansible-pull) ]]; then # if are not installed
	if [[ -n $(which pacman) ]]; then # if are installed
		sudo pacman -S --noconfirm ansible
	elif [[ -n $(which apt) ]]; then
		sudo apt install -y ansible
	fi
fi
if [[ -n $(which pacman) ]]; then
	sudo sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 50/g" /etc/pacman.conf
	sudo sed -i "s/#Color/Color/g" /etc/pacman.conf
	sudo pacman -Syyu --noconfirm
elif [[ -n $(which apt) ]]; then
	sudo apt update
fi

if [[ -z $DOTFILES_REF ]]; then
	cd "/run/media/${LOCAL_USER}/safe/safe/gpg/"
	./01-cat_pass.sh
	./02-import_gpg_key.sh
	pass show dev/git/github.com
fi
sudo touch /var/log/ansible.log

# Restore ansible
curl -Lks https://raw.githubusercontent.com/homeofficehost/dotfiles/master/ansible.sh | /bin/bash

#chsh -s $(which zsh)