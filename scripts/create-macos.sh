#!/bin/sh

###########################
# This script create macOS installer with sensitive defaults
###########################
source $MY_DOTFILES/lib_sh/echos.sh

volumeName=${1:-'Untitled'}
installerPath=${2:-'/Applications/Install\ macOS\ Sierra.app'}

bot "Creating MacOS Sierra on USB: /Volumes/$volumeName"
bot "Installer path: ${installerPath}"

running "Checking macOS High Sierra 10.13.1 SHA256"
echo ""
shasum -a 256 "${installerPath}/Contents/SharedSupport/InstallESD.dmg" | grep adaf1b7cd4feade63cecacd134a80c93ac75ed0af5f45a53f646adab30e56d52
if [ $? -eq 0 ]; then
	ok
	running "Installing.."
	read -t 7 -n 1 -s -r -p "Press any key to continue (or wait 7 seconds)"
	sudo "${installerPath}/Contents/Resources/createinstallmedia" --volume "/Volumes/${volumeName}" --applicationpath "${installerPath}"
	# tail -F /var/log/install.log
	if [ $? -eq 0 ]; then
		ok "Success!"
	else
		error 'copy fail'
		exit 1
	fi
else
	error 'check fail'
	exit 1
fi

exit 0