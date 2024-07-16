#!/bin/bash

LOCAL_USER=$2
# Restore pass
PASSWORD_STORE_REPO=$1

chown $LOCAL_USER:$LOCAL_USER ~/.ssh/tgroch_id_rsa
chown $LOCAL_USER:$LOCAL_USER ~/.ssh

chmod 700 ~/.ssh
chmod 600 ~/.ssh/tgroch_id_rsa
ssh-add ~/.ssh/tgroch_id_rsa

# Clone password store
if [[ ! -e ~/.password-store ]]; then
	git clone "$PASSWORD_STORE_REPO" ~/.password-store
fi

# Install Homebrew if not installed on macOS
if [[ $(uname) == "Darwin" ]] && ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install pass
if ! command -v pass &> /dev/null; then
    if command -v brew &> /dev/null; then
        brew install pass
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm pass
    elif command -v apt &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y pass
    else
        echo "Unsupported package manager. Please install 'pass' manually."
    fi
fi

# Install Ansible
if ! command -v ansible-pull &> /dev/null; then
    if [[ $(uname) == "Darwin" ]] && command -v brew &> /dev/null; then
        brew install ansible
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm ansible
    elif command -v apt &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y ansible
    else
        echo "Unsupported package manager. Please install 'ansible' manually."
    fi
fi

sudo pacman -S --noconfirm xclip

# Update system
if command -v brew &> /dev/null; then
    echo "Updating Homebrew..."
    brew update
    brew upgrade
    brew cleanup
elif command -v pacman &> /dev/null; then
    sudo sed -i "s/#ParallelDownloads = 5/ParallelDownloads = 50/g" /etc/pacman.conf
    sudo sed -i "s/#Color/Color/g" /etc/pacman.conf
    sudo pacman -Syyu --noconfirm
elif command -v apt &> /dev/null; then
    sudo apt-get update
    sudo apt-get upgrade -y
fi

cd "/run/media/${LOCAL_USER}/SAFE/safe/gpg/"
./01-cat_pass.sh
./02-import_gpg_key.sh

sudo touch /var/log/ansible.log
sudo chown $USER:$USER /var/log/ansible.log

# Restore ansible
curl -Lks -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/homeofficehost/dotfiles/master/ansible.sh $PASSWORD_STORE_REPO $LOCAL_USER | /bin/bash
