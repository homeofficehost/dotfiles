#!/usr/bin/env bash

###########################
# This fast script toggle on and off HotCorner in macOS
# --------------------------
# 
###########################
source $MY_DOTFILES/lib_sh/echos.sh

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

TL_CORNER=`defaults read com.apple.dock wvous-tl-corner`
TL_MODIFIER=`defaults read com.apple.dock wvous-tl-modifier`
TR_CORNER=`defaults read com.apple.dock wvous-tr-corner`
TR_MODIFIER=`defaults read com.apple.dock wvous-tr-modifier`
BL_CORNER=`defaults read com.apple.dock wvous-bl-corner`
BL_MODIFIER=`defaults read com.apple.dock wvous-bl-modifier`
BR_CORNER=`defaults read com.apple.dock wvous-br-corner`
BR_MODIFIER=`defaults read com.apple.dock wvous-br-modifier`

if [[ 0 -eq $TL_CORNER ]] && [[ 0 -eq $TL_MODIFIER ]] && [[ 0 -eq $TR_CORNER ]] && [[ 0 -eq $TR_MODIFIER ]] && [[ 0 -eq $BL_CORNER ]] && [[ 0 -eq $BL_MODIFIER ]] && [[ 0 -eq $BR_CORNER ]] && [[ 0 -eq $BR_MODIFIER ]]; then

	running "Top left screen corner → Launchpad"
	defaults write com.apple.dock wvous-tl-corner -int 11
	defaults write com.apple.dock wvous-tl-modifier -int 0;ok

	running "Top right screen corner → Mission Control"
	defaults write com.apple.dock wvous-tr-corner -int 2
	defaults write com.apple.dock wvous-tr-modifier -int 0;ok

	running "Bottom left screen corner → Start screen saver"
	defaults write com.apple.dock wvous-bl-corner -int 5
	defaults write com.apple.dock wvous-bl-modifier -int 0;ok

	running "Bottom right screen corner → Desktop"
	defaults write com.apple.dock wvous-br-corner -int 4
	defaults write com.apple.dock wvous-br-modifier -int 0;ok

else
	running "Turning off screen corner"
	defaults write com.apple.dock wvous-tl-corner -int 0
	defaults write com.apple.dock wvous-tl-modifier -int 0
	defaults write com.apple.dock wvous-tr-corner -int 0
	defaults write com.apple.dock wvous-tr-modifier -int 0
	defaults write com.apple.dock wvous-bl-corner -int 0
	defaults write com.apple.dock wvous-bl-modifier -int 0
	defaults write com.apple.dock wvous-br-corner -int 0
	defaults write com.apple.dock wvous-br-modifier -int 0;ok
fi

running "Kill affected applications"
for app in "Dock"; do
	killall "${app}" &> /dev/null
done;ok
