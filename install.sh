#!/usr/bin/env bash
# This is the main install script, it runs the system specific installer script

bash ./lib_sh/echos.sh
bash ./lib_sh/requirers.sh

if [[ "$(uname -s)" == "Darwin" ]]; then
  bash ./install-darwin.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  bash ./install-linux.sh
fi
