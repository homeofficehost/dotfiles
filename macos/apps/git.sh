#!/usr/bin/env bash

###########################
# This script setups git config on your system with sensitive defaults
# --------------------------
# TODO: configure based on keychain data
###########################
source ./lib_sh/echos.sh


FULL_NAME=`git config --global user.name`
EMAIL=`git config --global user.email`
GITHUB_USERNAME=`git config --global github.user`
EDITOR=`git config --global core.editor`

if [[ -z "$FULL_NAME" ]]; then
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

if [[ -z "${EMAIL}" ]]; then
	email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`
	bot "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
	read -r -p "Is this correct? (y|N) [default=N] " response
	response=${response:-N}
	if [[ $response =~ ^(no|n|N) ]];then
	    while [ -z "$email" ]; do
	        read -r -p "What is your email? " email
	    done
	fi
	EMAIL="${email}"

	git config --global user.email "${EMAIL}"
fi

if [[ -z "$GITHUB_USERNAME" ]]; then
	while [ -z "$GITHUB_USERNAME" ]; do
		read -r -p "What is your GitHub username? " GITHUB_USERNAME
	done

	git config --global github.user "${GITHUB_USERNAME}"
fi

running "Setting git configurations"
git config --global color.ui true

git config --global gpg.program $(which gpg)
git config --global core.filemode true
git config --global core.editor "${VISUAL:-'subl -n -w'}"
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

# Git Submodules To Auto-Pull
git config --add fetch.recurseSubmodules true
git config alias.pull '!f(){ git pull "$@" && git submodule update --init --recursive; }; f'

if which meld &>/dev/null; then
	git config --global diff.guitool meld
	git config --global merge.tool meld
elif which kdiff3 &>/dev/null; then
	git config --global diff.guitool kdiff3
	git config --global merge.tool kdiff3
fi
ok

if [[ ! -e ~/.git-templates/hooks/post-commit ]];then
	bot "Setting up gitshots"
	read -t 7 -r -p "Do you want to install or remove? (y|N|r) [or wait 7 seconds for default=N] " response
	response=${response:-N}
	if [[ $response =~ (yes|y|Y) ]];then
		running "Enable git templates for gitshots"
		git config --global init.templatedir '~/.git-templates';ok

		running "Creating directories global git hooks and gitshots photos"
		mkdir -p ~/.git-templates/hooks/
		mkdir -p ~/.gitshots;ok

		running "Installing gitshots"
		cp ./configs/gitshot-post-commit-template.sh ~/.git-templates/hooks/post-commit;ok

		running "Making sure the hook is executable"
		chmod a+x ~/.git-templates/hooks/post-commit;ok
	elif [[ $response =~ (remove|r|R) ]];then
		if [[ -e ~/.git-templates/hooks/post-commit ]];then
			running "Removing gitshots"
			rm ~/.git-templates/hooks/post-commit;ok
		fi
	fi
fi

bot "Configuring npm"
action "always pin versions (no surprises, consistent dev/build machines)"
npm config set save-exact true

NPM_FULL_NAME=`npm get init.author.name`
NPM_EMAIL=`npm get init.author.email`
NPM_GITHUB_USERNAME=`npm get init.author.url`
NPM_LICENSE=`npm get init.license`
NPM_VERSION=`npm get init.version`

if [[ -z "$NPM_FULL_NAME" ]] || [[ -z "$NPM_EMAIL" ]] || [[ -z "$NPM_GITHUB_USERNAME" ]] || [[ -z "$NPM_LICENSE" ]] || [[ -z "$NPM_VERSION" ]]; then
	read -t 7 -r -p "Would you like to setup npm with your account? (y|N) [or wait 7 seconds for default=N] " response
	response=${response:-N}
	if [[ $response =~ (yes|y|Y) ]];then
		running "Configuring npm account"

	    while [ -z "$EMAIL" ]; do
	        read -r -p "What is your email? " EMAIL
	    done
		while [ -z "$FULL_NAME" ]; do
	        read -r -p "What is your full name? " FULL_NAME
	    done

		read -r -p "What is your website url? (https://example.com/) " URL
		npm set init.author.name "${FULL_NAME}"
		npm set init.author.email "${EMAIL}"
		npm set init.author.url "${URL}"
		npm set init.license "MIT"
		npm set init.version "1.0.0"
		ok
	fi
fi
