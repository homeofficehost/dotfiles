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

function finish {
    # re-link system's python
    brew link --overwrite --dry-run python@2
}
trap finish EXIT

# Automatically randomize MAC address on update
sudo npx spoof randomize wi-fi; sudo npx spoof randomize en4

# Use python3 by default
rm -f /usr/local/bin/python 2>&1 >/dev/null; ln -s $(which python3) /usr/local/bin/python

# stdout to null, stderr to stdout
pip3 install --upgrade setuptools 2>&1 >/dev/null;	code=$?; [[ code -ne 0 ]] && echo "pip setuptools update; exit code was ${code}"
pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U 2>&1 >/dev/null;	code=$?; [[ code -ne 0 ]] && echo "pip3 update; exit code was ${code}"
gem update --verbose 2>&1 >/dev/null;	code=$?; [[ code -ne 0 ]] && echo "gem update; exit code was ${code}"
brew update 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "brew update; exit code was ${code}"
brew upgrade 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "brew upgrade; exit code was ${code}"
brew cask upgrade 2>&1 >/dev/null;		code=$?; [[ code -ne 0 ]] && echo "cask upgrade; exit code was ${code}"
mas upgrade 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "mas upgrade; exit code was ${code}"
tldr --update 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "tldr update; exit code was ${code}"

casks_outdated=`brew cask outdated --greedy --verbose | grep -v '(latest)' | cut -d' ' -f1`
delete=(webstorm phpstorm)
for del in ${delete[@]}
do
   casks_outdated=("${casks_outdated[@]/$del}")
done
brew cask upgrade `echo $casks_outdated` 2>&1 >/dev/null;		code=$?; [[ code -ne 0 ]] && echo "custom cask upgrade; exit code was ${code}"

# cleans up cached downloads (with --outdated, only cleans old downloads)
brew cleanup 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "brew cleanup; exit code was ${code}"
# checks for configuration issues
brew doctor 2>&1 >/dev/null;			code=$?; [[ code -ne 0 ]] && echo "brew doctor; exit code was ${code}"

# Local Notification
osascript -e 'display notification "" with title "System Updated"'

# Remote Notification
TEXT=$(printf "\
==============\n \
HOSTNAME: "`hostname`"\n\
WAN IP: "`dig +short myip.opendns.com @resolver1.opendns.com`"\n\
\n\n\
Update History Log:\n\
`cat ~/logs/"$(ls -rt ~/logs/ | tail -n1)"`\
")
# npx --quiet telemify "${TEXT}"

# Altenative way to send
# JSON_CONFIG="$(cat ~/.config/telemify/config.json)"
# CHAT_ID="$(echo $JSON_CONFIG | jq --raw-output .chat_id)"

# TELEGRAM_BOT_TOKEN="$(echo $JSON_CONFIG | jq --raw-output .token)" \
# npx --quiet tgb --method sendMessage --d.chat_id ${CHAT_ID} --d.text "${TEXT}"


exit 0
