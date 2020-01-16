#!/usr/bin/env bash
# This is the main install script, it runs the system specific installer script

git clone "${$PASSWORD_STORE_REMOTE_URL}.git" $HOME/.password-store

if [[ "$(uname -s)" == "Darwin" ]]; then
  caffeinate -i ./install-darwin.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  . ./install-linux.sh
fi
