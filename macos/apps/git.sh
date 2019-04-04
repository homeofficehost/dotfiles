#!/usr/bin/env bash

###########################
# This script setups git config on your system with sensitive defaults
# @author Thomas Letsch Groch
# --------------------------
# TODO: configure based on keychain data
###########################

local FULL_NAME=`git config --global user.name`
local EMAIL=`git config --global user.email`
local GITHUB_USERNAME=`git config --global github.user`
local EDITOR=`git config --global core.editor`

if [[ -n "$FULL_NAME" ]]; then
	fullname=`osascript -e "long user name of (system info)"`
	if [[ -n "$fullname" ]];then
		lastname=$(echo $fullname | awk '{print $2}');
		firstname=$(echo $fullname | awk '{print $1}');
	fi
	if [[ -z $firstname ]]; then
		firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
	fi
	if [[ -z $lastname ]]; then
		lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
	fi
	if [[ ! "$firstname" ]];then
		response='n'
	else
		bot "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
		read -r -p "Is this correct? (y|N) [default=N] " response
		response=${response:-N}
	fi
	if [[ $response =~ ^(no|n|N) ]];then
		read -r -p "What is your first name? " firstname
		read -r -p "What is your last name? " lastname
	fi
	FULL_NAME="$firstname $lastname"

	git config --global user.name "${FULL_NAME}"
fi

if [[ -n "$EMAIL" ]]; then
	email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`
	bot "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
	read -r -p "Is this correct? (y|N) [default=N] " response
	response=${response:-N}
	if [[ $response =~ ^(no|n|N) ]];then
	    while [ -z "$email" ]; do
	        read -r -p "What is your email? " email
	    done
	fi
	EMAIL=$email

	git config --global user.email "${EMAIL}"
fi

if [[ -n "$GITHUB_USERNAME" ]]; then
	while [ -z "$GITHUB_USERNAME" ]; do
		read -r -p "What is your GitHub username? " GITHUB_USERNAME
	done

	git config --global github.user "${GITHUB_USERNAME}"
fi

git config --global color.ui true

git config --global gpg.program $(which gpg)
git config --global core.filemode true
git config --global core.editor $VISUAL
git config --global core.excludesfile '~/.gitignore'

git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

git config --global color.diff auto
git config --global color.status auto
git config --global color.branch auto
git config --global color.diff-highlight.oldNormal    "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal    "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"

git config --global diff.color true
git config --global color.diff.meta       "yellow"
git config --global color.diff.frag       "magenta bold"
git config --global color.diff.commit     "yellow bold"
git config --global color.diff.old        "red bold"
git config --global color.diff.new        "green bold"
git config --global color.diff.whitespace "red reverse"

git config --global push.default matching
git config --global format.signoff true
git config --global alias.reset 'reset --soft HEAD^'
git config --global alias.graph 'log --graph --oneline --decorate'

if which meld &>/dev/null; then
	git config --global diff.guitool meld
	git config --global merge.tool meld
elif which kdiff3 &>/dev/null; then
	git config --global diff.guitool kdiff3
	git config --global merge.tool kdiff3
fi
