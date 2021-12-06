#!/bin/sh

ansible-pull --url https://github.com/thomasgroch/dotfiles --vault-id ansible/workstation/tg@gopass-client.py --limit $(cat /etc/hostname).local
