#!/usr/bin/env bash

volumeName=${1:-'Untitled'}

echo "Creatings MacOS Sierra on USB: /Volumes/$volumeName";
read -n 1 -s -r -p "Press any key to continue"
sudo /Applications/Install\ macOS\ Sierra.app/Contents/Resources/createinstallmedia --volume /Volumes/"$volumeName" --applicationpath /Applications/Install\ macOS\ Sierra.app