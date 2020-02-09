##############################################################################
#Import the shell-agnostic (Bash or Zsh) environment config
##############################################################################
[ -r ~/.profile ] && source ~/.profile

##############################################################################
# History Configuration
##############################################################################
HISTSIZE=5000000               #How many lines of history to keep in memory
HISTFILE=~/.zsh_history     #Where to save history to disk
SAVEHIST=50000               #Number of history entries to save to disk
HISTDUP=erase               #Erase duplicates in the history file
# if [[ -n $TMUX ]]; then
#	setopt    appendhistory     #Append history to the history file (no overwriting)
#	setopt    sharehistory      #Share history across terminals
#	setopt    incappendhistory  #Immediately append to the history file, not just when a term is killed
# fi

