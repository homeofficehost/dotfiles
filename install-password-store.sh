#!/usr/bin/env bash

###########################
# This script init and restore personal password-store repo solution
# @author Thomas Letsch Groch
###########################

# trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

# include library helpers for colorized
source ./lib_sh/echos.sh

ask.transcrypt.password(){
    while [ -z "$response" ]; do
        read -r -p "What is your password for decrypt transcrypt? " response
    done
}
ask.username.on(){
    while [ -z "$response" ]; do
        read -r -p "What is your username on $1? " response
    done
    echo $response
}
ask.custom.repo(){
    while [ -z "$response" ]; do
        read -r -p "Where is password-store git repository? (must be a clonable git URL) " response
    done
    echo $response
}
ask.provider() {
	PS3=$1

	options=("Gitlab")
	options+=("GitHub")
	options+=("Bitbucket")
	# options+=("KeyBase")
	options+=("Custom")
	options+=("Quit")

	select opt in "${options[@]}"; do
	    case $opt in
	        "Gitlab")
	            http_url_to_repo="https://gitlab.com/$(ask.username.on $opt)/password-store.git"
	            break
	            ;;
	        "GitHub")
	            http_url_to_repo="https://github.com/$(ask.username.on $opt)/password-store.git"
	            break
	            ;;
	        "Bitbucket")
				username=$(ask.username.on $opt)
	            http_url_to_repo="https://${username}@bitbucket.org/${username}/password-store.git"
	            break
	            ;;
	        "Custom")
	            echo "Ok, using $opt" >&2
	            http_url_to_repo=$(ask.custom.repo)
	            break
	            ;;
	        "Quit")
	            echo "Quitting.." >&2
	            exit 0;;
	        *) echo "invalid option $REPLY" >&2;exit 1;
	    esac
	done
	echo $http_url_to_repo
}

bot "Hi! I'm going to configure password-store on your system.\nYou supposed use gpg-suite to generate and have GPG already imported.\nHere I go..."

# # TODO: Import GPG keypair.
# $ gpg --import pubkey.asc
# $ gpg --allow-secret-key-import --import privkey.asc

gpg_email=$(gpg --list-keys --fingerprint | grep uid | awk -F"[<>]" '{print $2}')

echo -e "The best I can make out, your GPG email address is $COL_YELLOW$gpg_email$COL_RESET"
read -r -p "Is this correct? (Y|n) [default=Y] " response
response=${response:-Y}

if [[ $response =~ ^(no|n|N) ]];then
	read -r -p "What is your GPG email? " gpg_email
	if [[ ! $gpg_email ]];then
		error "you must provide an email to configure .gitconfig"
		exit 1
	fi
fi

read -r -p "(I)nitialize or (R)estore [default=R] " response
response=${response:-Y}
if [[ $response =~ (i|I) ]];then
	
	bot "Ok, Initializing.."
	http_url_to_repo=$(ask.provider 'Where should password-store repo should be created? ')

    trap 'action "$BASH_COMMAND"' DEBUG
	pass init "${gpg_email}"
	cd /Users/$(whoami)/.password-store

	trap 'action "$BASH_COMMAND"' DEBUG
	pass git init
	trap 'action "$BASH_COMMAND"' DEBUG
	pass git remote add origin $http_url_to_repo
	ok
	bot 'Password-store repository initialized.'

	bot "Configure encryption"
	transcrypt -c aes-256-cbc
	cat > .gitattributes << EOF
	*.gpg filter=crypt diff=crypt
	*.key filter=crypt diff=crypt
	*.properties filter=crypt diff=crypt
	*.jks filter=crypt diff=crypt
	EOF
	ok
	bot "Please SAVE YOUR PASSWORD!"

    trap 'action "$BASH_COMMAND"' DEBUG
	pass generate Others/example.com 15;ok
	bot "Example password added."

    trap 'action "$BASH_COMMAND"' DEBUG
	git add . && git commit -m "Initial password-store commit" && git push -u origin master
	bot "Password-store repository are now live"

else

	bot "Ok, Restoring.."

	http_url_to_repo=$(ask.provider 'Where is your password-store repo? ')

	# clone
	trap 'action "$BASH_COMMAND"' DEBUG
	git clone $http_url_to_repo /Users/$(whoami)/.password-store

	# decrypt
	trap 'action "$BASH_COMMAND"' DEBUG
	transcrypt -c aes-256-cbc -p "$(ask.transcrypt.password)"

fi
