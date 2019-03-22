#!/bin/sh

source ~/.shellvars
source ~/.shellpaths

# ruby gem nightly updates
gem update --verbose

# brew nightly updates
brew update
brew upgrade

# brew cask
brew cask upgrade

# mas updates
mas upgrade

# Others
tldr --update

# Local Notification
osascript -e 'display notification "" with title "System Updated"'

# Remote Notification
TEXT=$(printf "\
==============\n \
HOSTNAME: "`hostname`"\n\
WAN IP: "`dig +short myip.opendns.com @resolver1.opendns.com`"\n\
\n\
Update History Log:\n\
`cat ~/logs/"$(ls -rt ~/logs/ | tail -n1)"`\
")
npx --quiet telemify "${TEXT}"

# Altenative way to send
# JSON_CONFIG="$(cat ~/.config/telemify/config.json)"
# CHAT_ID="$(echo $JSON_CONFIG | jq --raw-output .chat_id)"

# TELEGRAM_BOT_TOKEN="$(echo $JSON_CONFIG | jq --raw-output .token)" \
# npx --quiet tgb --method sendMessage --d.chat_id ${CHAT_ID} --d.text "${TEXT}"


exit 0
