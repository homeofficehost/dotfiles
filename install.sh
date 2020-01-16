#!/usr/bin/env bash
# This is the main install script, it runs the system specific installer script

if [[ "$(uname -s)" == "Darwin" ]]; then
  caffeinate -i ./install-darwin.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  . ./install-linux.sh
fi
