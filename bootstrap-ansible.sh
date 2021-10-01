sudo pacman -S --noconfirm ansible
sudo ansible-pull --url https://github.com/thomasgroch/dotfiles --limit $(cat /etc/hostname).local