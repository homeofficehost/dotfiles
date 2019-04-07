#!/usr/bin/env bash

###########################
# This script setups misc apps with sensitive defaults
# --------------------------
###########################
source ./lib_sh/echos.sh

running "Setting default directory for Kap - An open-source screen recorder built with web technology"
defaults write com.wulkano.kap NSNavLastRootDirectory -string "~/Desktop";ok

