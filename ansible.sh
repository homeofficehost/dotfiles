#!/bin/sh

if [[ $USER == *"workstation"* ]]; then
	pass show "ansible/workstation/${USER}"
	ansible-pull --url https://github.com/homeofficehost/dotfiles --vault-id "${USER}@gopass-client.py" --limit $(cat /etc/hostname).local
else
	ansible-pull --url https://github.com/homeofficehost/dotfiles
fi

