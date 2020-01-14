# where $BARE_DOTFILES directory is a git bare repository.
BARE_DOTFILES=$HOME/.bare-dotfiles
ln -s $BARE_DOTFILES .git
# git init --bare $BARE_DOTFILES
git clone --separate-git-dir=$BARE_DOTFILES https://github.com/thomasgroch/dotfiles.git $HOME
alias dotfiles="git --git-dir=$BARE_DOTFILES --work-tree=$HOME"
dotfiles remote add origin https://github.com/thomasgroch/dotfiles.git
dotfiles config status.showUntrackedFiles no
bash ./install.sh
# dotfiles remote set-url origin 
# password-store-installer
# rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
# rm --recursive dotfiles-tmp
