#!/bin/bash

# fail hard
set -o pipefail
# fail on first error
# set -e # Disable by default
# fail no variables
set -u
IFS=$'\n\t'

source ~/.shellvars
source ~/.shellpaths

# function finish {
#     # re-link system's python
#     brew link --overwrite --dry-run python@2
# }
# trap finish EXIT

# Automatically randomize MAC address on update
sudo npx spoof randomize wi-fi; sudo npx spoof randomize en4

# Local Notification
osascript -e 'display notification "" with title "System Booted"'


exit 0
