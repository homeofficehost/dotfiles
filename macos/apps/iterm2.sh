#!/usr/bin/env bash

source ./lib_sh/echos.sh

running "Reseting iterm configuration"
defaults delete com.googlecode.iterm2;ok

running "Open the app so the preference files get initialized"
open -g "/Applications/iTerm.app" && sleep 2;ok

running "Disable warning when quitting iterm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false
defaults write com.googlecode.iterm2 OnlyWhenMoreTabs -int 0
defaults write com.googlecode.iterm2 TabStyleWithAutomaticOption -int 1;ok

running "Quitting iTerm2"
sleep 3 && osascript -e 'quit app "iTerm"';ok

running "Show tab bar in FullScreen"
defaults write com.googlecode.iterm2 ShowFullScreenTabBar -bool true;ok

running "Use Native full screen windows"
defaults write com.googlecode.iterm2 UseLionStyleFullscreen -int 0;ok

running "Ajusting Dimming Amount"
defaults write com.googlecode.iterm2 DimOnlyText -bool true
defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -string "0.6";ok

running "Hide menubar In fullscreen"
defaults write com.googlecode.iterm2 HideMenuBarInFullscreen -int 1;ok

running "Hide from Dock and AppSwitcher"
defaults write com.googlecode.iterm2 HideFromDockAndAppSwitcher -int 1;ok

running "Stretch tabs to fill bar"
defaults write com.googlecode.iterm2 StretchTabsToFillBar -bool true;ok

running "Disable automatic checks"
defaults write com.googlecode.iterm2 SUEnableAutomaticChecks -bool false;ok

running "Open tmux windows as tabs in existing window"
defaults write com.googlecode.iterm2 OpenTmuxWindowsIn -int 2;ok

running "Disable fullscreen transparency"
defaults write com.googlecode.iterm2 DisableFullscreenTransparency -int 1;ok

running "Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false;ok

running "hide tab title bars"
defaults write com.googlecode.iterm2 HideTab -bool true;ok

running "hide pane titles in split panes"
defaults write com.googlecode.iterm2 ShowPaneTitles -bool false;ok

running "animate split-terminal dimming"
defaults write com.googlecode.iterm2 AnimateDimming -bool true
defaults write com.googlecode.iterm2 HotkeyChar -int 0
defaults write com.googlecode.iterm2 HotkeyCode -int 50;ok

running "Setting focus follows mouse"
defaults write com.googlecode.iterm2 FocusFollowsMouse -int 1;ok

running "Setting default hotkey show/hide iterm with \`"
defaults write com.googlecode.iterm2 Hotkey -bool true
defaults write com.googlecode.iterm2 HotkeyModifiers -int 256;ok

running "Make iTerm2 load new tabs in the same directory"
/usr/libexec/PlistBuddy -c "set \"New Bookmarks\":0:\"Custom Directory\" Recycle" ~/Library/Preferences/com.googlecode.iterm2.plist;ok


running "Set font to Menlo Regular 18px"
/usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Normal Font' Hack-Regular 18" ~/Library/Preferences/com.googlecode.iTerm2.plist
/usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Non Ascii Font' RobotoMono-Regular 18" ~/Library/Preferences/com.googlecode.iTerm2.plist;ok

# Change the name of the bookmark to tmux
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Name' tmux" ~/Library/Preferences/com.googlecode.iTerm2.plist

# # Set up a trigger to generate notifications
# /usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:'Triggers': dict" ~/Library/Preferences/com.googlecode.iTerm2.plist
# /usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:'Triggers':0:'regex' string ##TERMINAL_NOTIFY:([^#]*)##" ~/Library/Preferences/com.googlecode.iTerm2.plist
# /usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:'Triggers':0:'action' string GrowlTrigger" ~/Library/Preferences/com.googlecode.iTerm2.plist
# /usr/libexec/PlistBuddy -c "Add 'New Bookmarks':0:'Triggers':0:'parameter' string iTerm command: \\\\1" ~/Library/Preferences/com.googlecode.iTerm2.plist

# # Reuse previous session directory
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Custom Directory' Recycle" ~/Library/Preferences/com.googlecode.iTerm2.plist

# # Unlimited Scrollback
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Unlimited Scrollback' true" ~/Library/Preferences/com.googlecode.iTerm2.plist

# # Mute bell
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Silence Bell' true" ~/Library/Preferences/com.googlecode.iTerm2.plist

# Import Solarized Theme
# /usr/libexec/PlistBuddy -c "Add 'Custom Color Presets':'Solarized Dark' dict" ~/Library/Preferences/com.googlecode.iTerm2.plist
# /usr/libexec/PlistBuddy -c "Merge '$(pwd)/$(dirname $0)/iterm2/Solarized Dark.itermcolors' 'Custom Color Presets':'Solarized Dark'" ~/Library/Preferences/com.googlecode.iTerm2.plist

# Import Base16 - chalk Theme
# /usr/libexec/PlistBuddy -c "Add 'Custom Color Presets':'Base16 Chalk Dark' dict" ~/Library/Preferences/com.googlecode.iTerm2.plist
# /usr/libexec/PlistBuddy -c "Merge '$(pwd)/$(dirname $0)/iterm2/Base16 Chalk Dark.itermcolors' 'Custom Color Presets':'Base16 Chalk Dark'" ~/Library/Preferences/com.googlecode.iTerm2.plist

# Apply Solarized Theme in default profile
# for color in \
#   "Ansi 0 Color" "Ansi 1 Color" "Ansi 2 Color" "Ansi 3 Color" "Ansi 4 Color" \
#   "Ansi 5 Color" "Ansi 6 Color" "Ansi 7 Color" "Ansi 8 Color" "Ansi 9 Color" \
#   "Ansi 10 Color" "Ansi 11 Color" "Ansi 12 Color" "Ansi 13 Color" "Ansi 14 Color" \
#   "Ansi 15 Color" "Background Color" "Bold Color" "Cursor Color" "Cursor Text Color" \
#   "Foreground Color" "Selected Text Color" "Selection Color"; do

#   /usr/libexec/PlistBuddy -c "Delete :'New Bookmarks':0:'$color'" ~/Library/Preferences/com.googlecode.iterm2.plist
# done
# /usr/libexec/PlistBuddy -c "Merge '$(pwd)/$(dirname $0)/iterm2/Base16 Chalk Dark.itermcolors' 'New Bookmarks':0" ~/Library/Preferences/com.googlecode.iterm2.plist

# Set ANSI black color bright to 74,74,74 (needed for Solarized Dark)
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Ansi 8 Color':'Blue Component' 74" ~/Library/Preferences/com.googlecode.iterm2.plist
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Ansi 8 Color':'Red Component' 74" ~/Library/Preferences/com.googlecode.iterm2.plist
# /usr/libexec/PlistBuddy -c "Set 'New Bookmarks':0:'Ansi 8 Color':'Green Component' 74" ~/Library/Preferences/com.googlecode.iterm2.plist

# Add shortcut to Dock
# defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

# reset the preferences cache
# killall cfprefsd
