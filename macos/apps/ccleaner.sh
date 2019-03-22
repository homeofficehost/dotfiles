#!/usr/bin/env bash

source ./lib_sh/echos.sh

running "Reseting iterm configuration"
defaults delete com.piriform.ccleaner;ok

running "Open the app so the preference files get initialized"
open -g "/Applications/CCleaner.app" && sleep 4;ok

running "Quitting ccleaner"
sleep 2 && osascript -e 'quit app "CCleaner"';ok

# ----------
running "Setting up ccleaner"
defaults write com.piriform.ccleaner "AutoCheckForUpdatesEnabled" -bool false
defaults write com.piriform.ccleaner "Amethyst" -bool false
defaults write com.piriform.ccleaner "App Store" -bool false
defaults write com.piriform.ccleaner "Brave Browser" -bool false
defaults write com.piriform.ccleaner "CUSTOM_FILES_AND_FOLDERS_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "Discord" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_BROWSING_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_COOKIES_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_DOWNLOAD_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_FORMS_AND_SEARCH_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_SAVED_PASSWORDS_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_SESSION_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "FIREFOX_BROWSER_SITE_PREFERENCES_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "Keka" -bool false
defaults write com.piriform.ccleaner "Keybase" -bool false
defaults write com.piriform.ccleaner "NoSQLBooster for MongoDB" -bool false
defaults write com.piriform.ccleaner "Numi" -bool false
defaults write com.piriform.ccleaner "OPERA_BROWSER_COOKIES_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "OPERA_BROWSER_INTERNET_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "OPERA_BROWSER_SAVED_PASSWORDS_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "OPERA_BROWSER_SESSION_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SAFARI_BROWSER_BROWSING_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SAFARI_BROWSER_COOKIES_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SAFARI_BROWSER_DOWNLOAD_HISTORY_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SAFARI_BROWSER_SESSION_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SRWare Iron" -bool false
defaults write com.piriform.ccleaner "SYSTEM_FONT_REGISTRY_CACHE_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SYSTEM_MONITORING_ENABLED" -bool false
defaults write com.piriform.ccleaner "SYSTEM_UNNEEDED_LANGUAGES_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "SYSTEM_USER_DOWNLOADS_FEATURE_ID" -bool false
defaults write com.piriform.ccleaner "Spectacle" -bool false
defaults write com.piriform.ccleaner "Sublime Text" -bool false
defaults write com.piriform.ccleaner "Tower" -bool false
defaults write com.piriform.ccleaner "Transmission" -bool false
defaults write com.piriform.ccleaner "Volt" -bool false
defaults write com.piriform.ccleaner "WebStorm" -bool false

defaults write com.piriform.ccleaner "FIREFOX_BROWSER_CACHE_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "MISCELLANEOUS_CACHES_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "OPERA_BROWSER_APPLICATION_CACHE_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "OPERA_BROWSER_INTERNET_CACHE_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "Quick Look" -bool true
defaults write com.piriform.ccleaner "QuickTime Player" -bool true
defaults write com.piriform.ccleaner "SAFARI_BROWSER_CACHE_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_DIRECTORY_SERVICE_CACHE_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_LOGS_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_RECENT_APPLICATIONS_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_RECENT_DOCUMENTS_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_RECENT_PLACES_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_RECENT_SERVERS_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "SYSTEM_TRASH_FEATURE_ID" -bool true
defaults write com.piriform.ccleaner "isNotFirstRun" -bool true;ok

defaults write com.piriform.ccleaner "windowHeight" -int 850
defaults write com.piriform.ccleaner "windowPosX" -int 170
defaults write com.piriform.ccleaner "windowPosY" -int 40
defaults write com.piriform.ccleaner "windowWidth" -int 1100

# ----------


