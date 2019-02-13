#!/usr/bin/env bash

local volumeName=$1
# Set default: "Untitled"
if ! [ "$volumeName" != "" ]
then
	local volumeName="Untitled"
fi
echo "Creatings MacOS Sierra on USB: /Volumes/$volumeName";
sudo /Applications/Install\ macOS\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/"$volumeName" --applicationpath /Applications/Install\ macOS\ Sierra.app