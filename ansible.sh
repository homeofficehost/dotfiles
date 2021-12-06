#!/bin/sh

ansible-pull --url https://github.com/thomasgroch/dotfiles --vault-id ansible/workstation/tg@gopass-client.py --accept-host-key --limit $(cat /etc/hostname).local --ask-vault-pass --ask-become-pass
