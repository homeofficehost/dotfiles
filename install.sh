#!/usr/bin/env bash
# This is the main install script, it runs the system specific installer script

source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

if [[ "$(uname -s)" == "Darwin" ]]; then
  caffeinate -i ./install-darwin.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  . ./install-linux.sh
fi
