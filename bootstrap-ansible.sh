if [[ -z $(which ansible-pull) ]]; then # if are not installed
	if [[ -n $(which pacman) ]]; then # if are installed
		sudo pacman -S --noconfirm ansible
	elif [[ -n $(which apt) ]]; then
		sudo apt install -y ansible
	fi
fi
if [[ -n $(which ansible-pull) ]]; then
	sudo ansible-pull --url https://github.com/thomasgroch/dotfiles --limit $(cat /etc/hostname).local
fi