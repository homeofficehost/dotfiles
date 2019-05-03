#!/usr/bin/env bash

source ./lib_sh/echos.sh

running "Setting custom preferences"
defaults write org.videolan.vlc AudioEffectSelectedProfile -int 0
defaults write org.videolan.vlc SUEnableAutomaticChecks -bool false
defaults write org.videolan.vlc SUSendProfileInfo -bool false
defaults write org.videolan.vlc SUHasLaunchedBefore -bool true
defaults write org.videolan.vlc VideoEffectSelectedProfile -int 0
defaults write org.videolan.vlc language -string "en"
ok

running "Disabling VLC and Quicktime history"
defaults write org.videolan.vlc NSRecentDocumentsLimit -int 0
defaults delete org.videolan.vlc LSSharedFileList
defaults delete org.videolan.vlc RecentDocuments
defaults write org.videolan.vlc LSSharedFileList RecentDocuments -dict-add MaxAmount 0

defaults write com.apple.QuickTimePlayerX NSRecentDocumentsLimit -int 0
defaults delete com.apple.QuickTimePlayerX.LSSharedFileList RecentDocuments
defaults write com.apple.QuickTimePlayerX.LSSharedFileList RecentDocuments -dict-add MaxAmount 0
ok