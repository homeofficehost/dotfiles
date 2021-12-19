#!/bin/sh

pass show "ansible/workstation/${USER}"
ansible-pull --url https://github.com/thomasgroch/dotfiles --vault-id "ansible/workstation/${USER}@gopass-client.py" --limit $(cat /etc/hostname).local
