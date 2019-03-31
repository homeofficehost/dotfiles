#!/usr/bin/env bash

source ./lib_sh/echos.sh

running "Setting custom preferences"
defaults write com.DanPristupov.Fork NSNavLastRootDirectory -string "~/dev"
defaults write com.DanPristupov.Fork "TB Display Mode" -int 2
defaults write com.DanPristupov.Fork "NSWindow Frame ForkWindow" -string "0 37 1440 863 0 0 1440 900 "
defaults write com.DanPristupov.Fork "NSWindow Frame PreferencesWindowFrameAutoSaveName" -string "445 233 550 607 0 0 1440 900 "
ok

running "Disable automatic checks"
defaults write com.DanPristupov.Fork SUEnableAutomaticChecks -bool false
defaults write com.DanPristupov.Fork appearance -int 1
defaults write com.DanPristupov.Fork diffFontName -string "RobotoMono-Regular"
defaults write com.DanPristupov.Fork diffFontSize -int 18
defaults write com.DanPristupov.Fork disableAnonymousUsageReports -int 1
defaults write com.DanPristupov.Fork externalDiffTool -int 6
defaults write com.DanPristupov.Fork mergeToo -int 6
ok