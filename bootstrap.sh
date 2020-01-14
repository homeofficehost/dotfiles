# where $BARE_DOTFILES directory is a git bare repository.
BARE_DOTFILES=$HOME/.bare-dotfiles
BARE_DOTFILES_BACKUP=$HOME/.bare-dotfiles-bkp
BARE_DOTFILES_TMP=$HOME/.bare-dotfiles-tmp


[[ ! -e .gitmodules ]] && git clone --separate-git-dir=$BARE_DOTFILES https://github.com/thomasgroch/dotfiles.git $BARE_DOTFILES_TMP && \
	cp $BARE_DOTFILES_TMP/.gitmodules $HOME
rm -rf $BARE_DOTFILES_TMP

[[ ! -e $BARE_DOTFILES ]] && git clone --bare https://github.com/thomasgroch/dotfiles.git $BARE_DOTFILES
# alias dotfiles="git --git-dir=$BARE_DOTFILES --work-tree=$HOME"
function dotfiles {
   /usr/bin/git --git-dir=$BARE_DOTFILES --work-tree=$HOME $@
}

mkdir -p $BARE_DOTFILES_BACKUP

# dotfiles remote add origin https://github.com/thomasgroch/dotfiles.git
# dotfiles checkout --track bare/bare
# dotfiles checkout bare
# dotfiles branch --set-upstream-to=origin/bare bare

dotfiles checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
  else
    echo "Backing up pre-existing dot files.";
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $BARE_DOTFILES_BACKUP/{}
fi;
dotfiles checkout

dotfiles config --local status.showUntrackedFiles no
[[ ! -h .git ]] && ln -s $BARE_DOTFILES .git

bash ./install.sh

# dotfiles remote set-url origin 
# password-store-installer
# rsync --recursive --verbose --exclude '.git' dotfiles-tmp/ $HOME/
# rm --recursive dotfiles-tmp
