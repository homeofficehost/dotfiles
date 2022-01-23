#!/bin/sh

PASSWORD_STORE_REPO=$1

# echo "To import my GnuPG and OpenSSH keys run:"
# echo "cd /run/media/tg/safe && ./run.sh"
# read -n 1 -s -r -p "Press any key to continue"

if [[ ! -e ~/.password-store ]]; then
	git clone $PASSWORD_STORE_REPO ~/.password-store
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