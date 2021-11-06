# Import my GnuPG and OpenSSH keys
. /run/media/tg/safe/run.sh
# read -n 1 -s -r -p "Press any key to continue"

if [[ ! -e ~/.password-store ]]; then
	git clone https://gitlab.com/thomas.groch/password-store.git ~/.password-store
fi
if [[ -z $(which ansible-pull) ]]; then # if are not installed
	if [[ -n $(which pacman) ]]; then # if are installed
		sudo pacman -S --noconfirm ansible
	elif [[ -n $(which apt) ]]; then
		sudo apt install -y ansible
	fi
fi

sudo ansible-pull --url https://github.com/thomasgroch/dotfiles --limit $(cat /etc/hostname).local