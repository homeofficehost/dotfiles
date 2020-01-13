#############################################################
# Generic configuration that applies to all shells
#############################################################

source ~/.shellvars
source ~/.shellfn
source ~/.shellpaths
source ~/.shellaliases

GPG_TTY=$(tty)
export GPG_TTY

# Uncomment to enable integration
# test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
