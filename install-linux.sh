#!/usr/bin/env bash

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Not running on Linux. Aborting!"
  exit 1
fi

bot "Start!"

curl -LO larbs.xyz/larbs.sh
bash larbs.sh