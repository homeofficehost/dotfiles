# Tranfer github to bitbucket

git clone --mirror https://github.com/thomasgroch/dotfiles
cd dotfiles.git
git remote set-url --push origin https://thomasgroch@bitbucket.org/thomasgroch/dotfiles
git push --mirror