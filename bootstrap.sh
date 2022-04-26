#!/bin/sh

username="camilasrody"
if [ "$HOST" = "tgworkstation" ]; then
	username="thomas.groch"
fi
PASSWORD_STORE_REPO="https://gitlab.com/$username/password-store.git"
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

cd /run/media/tg/safe/safe/gpg/
./01-cat_pass.sh
./02-import_gpg_key.sh
pass show dev/git/github.com
sudo touch /var/log/ansible.log

curl -Lks https://raw.githubusercontent.com/homeofficehost/dotfiles/master/ansible.sh | /bin/bash

chsh -s $(which zsh)

mkdir ~/dev/; cd ~/dev; git clone https://github.com/homeofficehost/dotfiles
