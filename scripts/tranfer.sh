# Tranfer github to bitbucket
git clone --mirror https://github.com/thomasgroch/dotfiles
cd dotfiles.git
git remote set-url --push origin https://thomasgroch@bitbucket.org/thomasgroch/dotfiles
git push --mirror

# Tranfer bitbucket to gitlab
git clone --mirror https://thomasgroch@bitbucket.org/thomasgroch/dotfiles
cd dotfiles.git
git remote set-url --push origin https://gitlab.com/thomas.groch/dotfiles
git push --mirror

# Tranfer gitlab to github
git clone --mirror https://gitlab.com/thomas.groch/my-awesome-portfolio
cd my-awesome-portfolio.git
git remote set-url --push origin https://github.com/thomasgroch/my-awesome-portfolio
git push --mirror
