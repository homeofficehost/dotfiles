if [[ -z $(which ansible-pull) ]]; then
	sudo pacman -S --noconfirm ansible
fi
if [[ -n $(which ansible-pull) ]]; then
	sudo ansible-pull --url https://github.com/thomasgroch/dotfiles --limit $(cat /etc/hostname).local
fi