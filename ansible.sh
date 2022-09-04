#!/bin/sh

# Run playbook
if [[ "$(cat /etc/hostname)" == *"workstation"* ]]; then
	pass show "ansible/workstation/${USER}"
	ansible-pull --url https://github.com/homeofficehost/dotfiles --vault-id "${USER}@gopass-client.py" --limit $(cat /etc/hostname).local
else
	pass show "ansible/workstation/runner"
	ansible-pull --url https://github.com/homeofficehost/dotfiles --vault-id "runner@gopass-client.py" --limit runner
fi

