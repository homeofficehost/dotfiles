#!/usr/bin/env bash

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Not running on Linux. Aborting!"
  exit 1
fi

read -t 7 -r -p "Change OS language? (y|N) [or wait 7 seconds for default=N] " response; echo ;
response=${response:-N}
if [[ $response =~ (yes|y|Y) ]];then
    bot "Reboot to take effect."
fi

ok "test"