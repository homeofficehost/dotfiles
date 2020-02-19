#!/usr/bin/env bash

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Not running on Mac OS X. Aborting!"
  exit 1
fi

source ./lib_sh/echos.sh
source ./lib_sh/requirers.sh

bot "Hi! I'm going to install tooling and tweak your system settings."

# Ask for the administrator password upfront
bot "I need you to enter your sudo password. so I can install some things."
if ! sudo grep -q "%wheel   ALL=(ALL) NOPASSWD: ALL # dotfiles" "/etc/sudoers"; then
  sudo -v
  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
fi

# Changing the System Language
read -t 7 -r -p "Change OS language? (y|N) [or wait 7 seconds for default=N] " response; echo ;
response=${response:-N}
if [[ $response =~ (yes|y|Y) ]];then
    sudo languagesetup
    bot "Reboot to take effect."
fi

################################################
bot "Standard System Changes"
################################################

running "Set standby delay to 24 hours (default is 1 hour)"
sudo pmset -a standbydelay 86400;ok

running "Never go into computer sleep mode"
sudo systemsetup -setcomputersleep Off > /dev/null;ok

running "Disabling Screen Saver (System Preferences > Desktop & Screen Saver > Start after: Never)"
defaults -currentHost write com.apple.screensaver idleTime -int 0;ok

read -t 7 -r -p "Would you like to add/change the message on login window? (y|N) [or wait 7 seconds for default=N] " response; echo ;
response=${response:-N}
if [[ $response =~ (yes|y|Y) ]];then
  read -t 7 -r -p "What message to use? [or wait 7 seconds for default=''] " LOGIN_MESSAGE
  LOGIN_MESSAGE=${LOGIN_MESSAGE:-''}
  # Add a message to the login window
  sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "${LOGIN_MESSAGE}";ok
fi

running "Allow Apps from Anywhere in macOS Sierra Gatekeeper"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false;ok

read -t 7 -r -p "(Re)install ad-blocking /etc/hosts file from someonewhocares.org? (y|N) [or wait 7 seconds for default=Y] " response; echo ;
response=${response:-Y}
if [[ $response =~ (yes|y|Y) ]];then
    running "Installing hosts file"
    action "cp /etc/hosts /etc/hosts.backup"
    sudo cp /etc/hosts /etc/hosts.backup

    action "cp ./configs/hosts /etc/hosts"
    sudo cp ./configs/hosts /etc/hosts
    ok "Your /etc/hosts file has been updated. Last version is saved in /etc/hosts.backup"
fi

brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  running "Installing homebrew CLI"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  if [[ $? != 0 ]]; then
    error "unable to install homebrew, script $0 abort!"
    exit 2
  fi
fi

read -t 7 -r -p "Do you like to upgrade any outdated packages? (y|N) [or wait 7 seconds for default=N] " response; echo ;
response=${response:-N}
if [[ $response =~ ^(y|yes|Y) ]];then
  # Upgrade any already-installed formulae
  running "update system packages script..."
  . ./update.sh
  ok "system updated..."
else
  ok "skipped system's packages update.";
fi

action "Prevent Homebrew from gathering analytics"
brew analytics off;ok

# skip those GUI clients, git command-line all the way
require_brew git
# update zsh to latest
require_brew zsh
# update ruby to latest
# use versions of packages installed with homebrew
RUBY_CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl` --with-readline-dir=`brew --prefix readline` --with-libyaml-dir=`brew --prefix libyaml`"
require_brew ruby
# set zsh as the user login shell
CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  bot "setting newer homebrew zsh (/usr/local/bin/zsh) as your shell (password required)"
  # sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  # chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  ok
fi

running "Installing zsh custom plugins"
warn $ZSH_CUSTOM
mkdir -p $ZSH_CUSTOM/plugins/

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/supercrabtree/k.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git "${ZSH_CUSTOM}/themes/powerlevel9k"
fi
ok

## TODO: REFACT

# bot "Creating symlinks for project dotfiles..."
# pushd homedir > /dev/null 2>&1
# now=$(date +"%Y.%m.%d.%H.%M.%S")

# shopt -s dotglob
# for file in *; do
#   if [[ $file == "." || $file == ".." ]]; then
#     continue
#   fi
#   running "~/$file"
#   # if the file exists:
#   if [[ -e ~/$file ]]; then
#       mkdir -p ~/.dotfiles_backup/$now
#       cp ~/$file ~/.dotfiles_backup/$now/$file
#       rm -f ~/$file
#       echo "backup saved as ~/.dotfiles_backup/$now/$file"
#   fi
#   # symlink might still exist
#   unlink ~/$file > /dev/null 2>&1
#   # create the link
#   ln -s ~/.dotfiles/homedir/$file ~/$file
#   echo -en '\tlinked';ok
# done

# popd > /dev/null 2>&1
##

bot "Configuring brew global packages"
response_retry_install=y
while [[ $response_retry_install =~ (yes|y|Y) ]]; do
    running "Accepting xcode build license"
    sudo xcodebuild -license accept;ok

    running "installing brew bundle..."
    brew bundle --verbose;ok

    running "checking brew bundle..."
    brew bundle check >& /dev/null
    if [ $? -eq 0 ]; then
      response_retry_install=N
      ok "Full brew bundle successfully installed."
    else
      warn "brew bundle check exited with error code"
      bot "Often some programs are not installed."
      read -t 7 -r -p "Would you like to try again brew bundle? (y|N) [or wait 7 seconds for default=y]" response_retry_install; echo ;
      response_retry_install=${response_retry_install:-Y}
    fi
done

MD5_NEWWP=$(md5 img/wallpaper.jpg | awk '{print $4}')
MD5_OLDWP=$(md5 $(npx wallpaper-cli) | awk '{print $4}')
if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
  read -t 7 -r -p "Do you want to update desktop wallpaper? (y|N) [or wait 7 seconds for default=Y] " response; echo ;
  response=${response:-Y}
  if [[ $response =~ (yes|y|Y) ]]; then
    running "updating wallpaper image"
    rm -rf ~/Library/Application Support/Dock/desktoppicture.db
    sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
    sleep 7 # Wait a bit to make sure the os recreation
    npx --quiet wallpaper-cli img/wallpaper.jpg;ok
  fi
fi

# composer global require laravel/valet

bot "Configuring npm global packages"
action "npm config set prefix ~/.local"
mkdir -p "${HOME}/.local"
npm config set prefix ~/.local;ok

###############################################################################
bot "Git and NPM Settings"
###############################################################################

# . ./macos/apps/git.sh
# action "Remove keychain from storing your password from git credentials"
# git config --system --unset credential.helper;ok

bot "TTS (text-to-speech) voices"
read -t 7 -r -p "Would you like to install voices? (y|N) [or wait 7 seconds for default=N] " response; echo ;
response=${response:-N}
if [[ $response =~ (yes|y|Y) ]];then
  npx --quiet voices -m
  ok
fi

###############################################################################
# Golang                                                                      #
###############################################################################
if [ -z "$(which go)" ]; then
  echo "Golang not available. Skipping!"
else
  bot "Install Golang packages"
  go get -u github.com/ramya-rao-a/go-outline
  go get -u github.com/nsf/gocode
  go get -u github.com/uudashr/gopkgs/cmd/gopkgs
  go get -u github.com/acroca/go-symbols
  go get -u golang.org/x/tools/cmd/guru
  go get -u golang.org/x/tools/cmd/gorename
  go get -u github.com/rogpeppe/godef
  go get -u sourcegraph.com/sqs/goreturns
  go get -u github.com/golang/lint/golint
  go get -u github.com/kardianos/govendor
  go get -u go.coder.com/sshcode
  ok
fi

bot "Installing vim plugins"
vim +PluginInstall +qall ## > /dev/null 2>&1
ok

bot "Installing fonts"
./fonts/install.sh;ok

# Ensure some directories permissions
if [[ -d "/Library/Ruby/Gems/2.0.0" ]]; then
  running "Fixing Ruby Gems Directory Permissions"
  sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
  ok
fi


###############################################################################
bot "Setting macOS sensitive default settings"
###############################################################################

. ./scripts/init-macos.sh

###############################################################################
bot "iTerm2"
###############################################################################

# running "Installing the Solarized Light theme for iTerm (opening file)"
# open "./configs/Solarized Light.itermcolors";ok
# running "Installing the Patched Solarized Dark theme for iTerm (opening file)"
# open "./configs/Solarized Dark Patch.itermcolors";ok
if [[ "${TERM_PROGRAM}" == "Apple_Terminal" ]]; then
  . ./macos/apps/iterm2.sh
else
  warn "You are using iTerm, so I will not configure it."
fi

###############################################################################
bot "CCleaner"
###############################################################################

. ./macos/apps/ccleaner.sh

###############################################################################
bot "Fork"
###############################################################################

. ./macos/apps/fork.sh

###############################################################################
bot "VLC"
###############################################################################

. ./macos/apps/vlc.sh

###############################################################################
bot "Others"
###############################################################################

. ./macos/apps/others.sh

###############################################################################
bot "Developer default settings"
###############################################################################
git clone "${PASSWORD_STORE_REMOTE_URL}.git" $HOME/.password-store
# netlify --telemetry-disable
# Installation of is.sh. A fancy alternative for old good test command.
# yarn global add carbon-now-cli
# yarn global add is.sh
touch $HOME/.hushlogin
mkdir -p $HOME/.ssh
mkdir -p $MY_TEMP

mkdir -p $HOME/pi/.bin/

# Fix mariadb start bug
mkdir -p /usr/local/etc/my.cnf.d

# Disable docker Crash Reporting
touch ~/.docker/machine/no-error-report

###############################################################################
bot "Developer workspace"
###############################################################################

if [[ -d $HOME/.password-store ]]; then
bot "Tip: Use gpg-suite to {manage,generate,import} GPG easy there."

  read -t 7 -r -p "Would you like to setup gpg keys? (y|N) [or wait 7 seconds for default=N] " response; echo ;
  response=${response:-N}
  if [[ $response =~ (yes|y|Y) ]];then
    # Setup create/restore keys
    password-store-installer
  fi
fi

git config --global credential.helper osxkeychain

running "Adding nightly cron software updates"
crontab ~/.crontab

running "Fixing a known PHP 7.3 bug"
cat > /usr/local/etc/php/7.3/conf.d/zzz-myphp.ini << EOF
; My php.ini settings
; Fix for Bug #77260 PCRE "JIT compilation failed" error
[Pcre]
pcre.jit=0
EOF
ok

running "Updating composer keys public keys"
releases_key=$(curl -Ls https://composer.github.io/releases.pub)
snapshots_key="$(curl -Ls https://composer.github.io/snapshots.pub)"
expect << EOF
  spawn composer self-update --update-keys
  sleep 1
  expect "Enter Dev / Snapshot Public Key (including lines with -----):"
  send -- "$releases_key"
  send "\r"
  expect "Enter Tags Public Key (including lines with -----):"
  send -- "${snapshots_key}\r"
  send "\r"
  expect eof
EOF
ok

running "Restore Launchpad apps Organization"
expect << EOF
  spawn lporg load /Users/$(whoami)/.launchpad.yaml $1
  expect "Backup your current Launchpad settings?"
  send "n\r"
  expect eof
EOF
ok

# running "Downloading anticaptcha chromium extension"
# pushd macos/apps/chromium-extensions > /dev/null 2>&1
# curl -O https://antcpt.com/downloads/anticaptcha/chrome/anticaptcha-plugin_v0.3008.crx && open anticaptcha-plugin_v0.3008.crx;ok
# popd > /dev/null 2>&1

running "Create dev folder in home directory"
mkdir -p ~/dev;ok

running "Create blog folder in home directory"
mkdir -p ~/blog;ok

running "Create logs folder in home directory"
mkdir -p ~/logs;ok

if [[ -r $(which bb) ]]; then
  cd $HOME/dev && mkdir -p temp && cd temp && \
    git clone https://github.com/artyfarty/bb-osx.git && cd bb-osx
  LIBMIKMOD_PATH=$(brew --prefix)/Cellar/libmikmod
  LIBMIKMOD_PATH="$LIBMIKMOD_PATH/$(ls -t $LIBMIKMOD_PATH* | head -1)/"
  ./configure --with-libmkmod-exec-prefix=$LIBMIKMOD_PATH --with-libmikmod-prefix=$LIBMIKMOD_PATH
  make; make install
  cd $HOME/dev && rm -Rf temp
fi
###############################################################################
# pushd /bin/ > /dev/null 2>&1
# [ -r /bin/pass-git-helper ] && sudo ln -s $(which pass-git-helper) pass-git-helper
# [ -r /bin/gpg ] && sudo ln -s $(which gpg) gpg
# popd > /dev/null 2>&1
###############################################################################

running "KeyboardMaestro: Disable Welcome Window"
defaults read com.stairways.keyboardmaestro.editor DisplayWelcomeWindow -bool false;ok

###############################################################################
bot "The End"
###############################################################################
npx --quiet okimdone
bot "Woot! All done. Killing this terminal and launch iTerm"
sleep 2

###############################################################################
# Kill affected applications                                                  #
###############################################################################
bot "Done. Note that some of these changes require a logout/restart to take effect. I will kill affected applications (so they can reboot)...."

read -n 1 -s -r -p "Press any key to continue"

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Mail" "Messages" \
  "Opera" "Photos" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" "Spectacle" \
  "Transmission" "iCal"; do
  killall "${app}" > /dev/null 2>&1
done