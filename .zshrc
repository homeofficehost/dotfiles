# https://blog.jonlu.ca/posts/speeding-up-zsh
# Uncomment for speed debug
# zmodload zsh/zprof

# Enable shell integration in tmux
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# export ZSH_THEME="powerlevel9k/powerlevel9k"
# export ZSH_THEME="robbyrussell"
# export ZSH_THEME="spaceship"

# Powerlevel9k Settings
# if you want to use this, change your non-ascii font to Droid Sans Mono for Awesome
# POWERLEVEL9K_MODE='awesome-patched'
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
# https://github.com/bhilburn/powerlevel9k#customizing-prompt-segments
# https://github.com/bhilburn/powerlevel9k/wiki/Stylizing-Your-Prompt
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir nvm vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status history time)
#
# colorcode test
# for code ({000..255}) print -P -- "$code: %F{$code}This is how your text would look like%f"
# POWERLEVEL9K_NVM_FOREGROUND='000'
# POWERLEVEL9K_NVM_BACKGROUND='072'
# POWERLEVEL9K_SHOW_CHANGESET=true

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="false"

export DISABLE_UPDATE_PROMPT="true"

# disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# disable autosetting terminal title.
export DISABLE_AUTO_TITLE="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# ZSH_CUSTOM=$HOME/oh-my-zsh-custom

# Which plugins would you like to load? (plugins can be found in ~/oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)
plugins+=(ssh-agent)
plugins+=(gpg-agent)
plugins+=(gnu-utils)
plugins+=(pass)
plugins+=(k)
plugins+=(yarn)
# plugins+=(gitfast) # heavy load
plugins+=(fasd)
plugins+=(git-extras)
plugins+=(brew)
plugins+=(sudo)
# plugins+=(composer)
plugins+=(docker)
plugins+=(docker-machine)
plugins+=(laravel5)
plugins+=(sublime)
plugins+=(httpie)
plugins+=(ansible)
plugins+=(compleat)
plugins+=(dirpersist)
plugins+=(dircycle) # cycle your directory stack {left,right} using Ctrl+Shift+Left/Right.
plugins+=(copyfile)
plugins+=(colorize)
plugins+=(history)
plugins+=(osx)
plugins+=(cp)
plugins+=(tmuxinator)
plugins+=(zsh-z)
plugins+=(zsh-autosuggestions)
plugins+=(zsh-completions)
plugins+=(zsh-syntax-highlighting)
if [[ "$OS" == "Linux" ]]; then
	plugins+=(archlinux)
fi

[ -r $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh
[ -r $ZSH/custom/.colored_man_pages.zsh ] && source $ZSH/custom/.colored_man_pages.zsh
[ -r $ZSH/custom/tmuxinator.zsh ] && source $ZSH/custom/tmuxinator.zsh

# npx as default fallback command
# source <(npx --shell-auto-fallback zsh)


# User configuration
# fastolx autocomplete:script zsh > $MY_TEMP/temp && chmod +x $MY_TEMP/temp && source $MY_TEMP/temp && rm $MY_TEMP/temp

# Advanced Tab completion
autoload -Uz compinit && compinit
# Now can be use code that calls compdef
# [ -z "$TMUX" ] && { exec /usr/local/bin/tmux -CC new-session -A -s main && exit;}
# The -A flag makes new-session behave like
	# attach-session if session-name already exists

# tmux -CC attach || tmux -CC

# if [[ -z $TMUX ]]; then
# 	echo 'no tmux'
# else
# 	echo "yes tmux: ${TMUX}"
# fi
# Is this needed?
# if [[ -z $TMUX ]]; then
	[ -r $HOME/.profile ] && source $HOME/.profile
# fi

export MANPATH="$USR_PATH/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

if [[ "$OS" == "Linux" ]]; then
	# Compilation flags
	export ARCHFLAGS="-arch x86_64"
fi

setopt list_ambiguous

# if (command which -s yarn) npm () {
#   case $@ in
#     *-g*|root*) command npm $@;;
#     install*) (($# > 1)) && yarn add ${@[2,#]} || yarn install;;
#     *) yarn $@;;
#   esac
# }
# [ $ZSH_EVAL_CONTEXT = toplevel ] && npm $@


if test -z $GOPASSCMD; then
   # allows to source zshrc twice
   export GOPASSCMD=$(which gopass)

	[ -n $GOPASSCMD ] && [ -d PASSWORD_STORE_DIR ] && source <($GOPASSCMD completion zsh | head -n -1 | tail -n +2)
	compdef _gopass gopass
fi

alias zsh_is_loading="zsh -o SOURCE_TRACE"

if [ -x "$(command -v rbenv)" ]; then
	# make rbenv load automatically when open Terminal
	eval "$(rbenv init -)"
fi

if [ -x "$(command -v pyenv)" ]; then
	eval "$(pyenv init -)"
fi

if [ -x "$(command -v starship)" ]; then
	eval "$(starship init zsh)"
fi

if [ -x "$(command -v colorls)" ]; then
	source $(dirname $(gem which colorls))/tab_complete.sh
fi


###### Prompt
# prompt='%F{35}%* [%j] [%m:%F{75}%f%F{69}%c%f%F{35}] %F{black}%K{red}%#%f%k '

##### History

# Set history file
HISTFILE=~/.zhistory

# Set history size
HISTSIZE=500000

# Set the number of lines in $HISTFILE
SAVEHIST="${HISTSIZE}"

# # Enable history search with up and down arrows
# autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search

# [[ -n "$key[Up]"   ]] && bindkey -- "$key[Up]"   up-line-or-beginning-search
# [[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search


##### Aliases
# alias ..='cd ..'
# alias ...='cd ../../../'
# alias ....='cd ../../../../'
# alias back='cd $OLDPWD'
# alias c='clear'
# alias cd..='cd ..'
# alias cp='cp -iv'
# alias chmod="chmod -c"
# alias chown="chown -c"
# alias e="vim -O "
# alias E="vim -o "
# alias egrep='egrep --colour=auto'
# alias extip='curl icanhazip.com'
# alias grep='grep --color=auto'
# alias l.='ls -lhFa --time-style=long-iso --color=auto'
# alias ll='ls'
# alias ln='ln -iv'
# alias ls='ls -lhF --color=auto --human-readable --time-style=long-iso --classify'
# alias lsmount='mount |column -t'
# alias mkdir='mkdir -pv'
# alias mv='mv -iv'
# alias ports='netstat -tulanp'
# alias h='history -i'
# alias history='history -i'
# alias j='jobs -l'
# alias rm='rm -iv'
# alias rmdir='rmdir -v'
# alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
# alias ssha='eval $(ssh-agent) && ssh-add'
# alias svim='sudo vim'
# alias tn=' tmux new -s'
# alias wget='wget -c'

if command -v colordiff > /dev/null 2>&1; then
    alias diff="colordiff -Nuar"
else
    alias diff="diff -Nuar"
fi

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# Safetynets
# do not delete / or prompt if deleting more than 3 files at a time #
# alias rm='rm -I --preserve-root'

# package management
# alias update='sudo apt-get update'
# alias upgrade='sudo apt-get update && sudo apt-get dist-upgrade'
# alias install='sudo apt-get install'

##### Functions

# Easily extract archives
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjvf $1    ;;
      *.tar.gz)    tar xzvf $1    ;;
      *.bz2)       bzip2 -d $1    ;;
      *.rar)       unrar2dir $1    ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1    ;;
      *.tgz)       tar xzf $1    ;;
      *.zip)       unzip2dir $1     ;;
      *.Z)         uncompress $1    ;;
      *.7z)        7z x $1    ;;
      *.ace)       unace x $1    ;;
      *)           echo "'$1' cannot be extracted via extract()"   ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


##### shopt

# save timestamp of command and duration
setopt extended_history

# Add commands as they are typed, don't wait until shell exit
setopt inc_append_history

# when trimming history, lose oldest duplicates first
setopt hist_expire_dups_first

# Do not write events to history that are duplicates of previous events
setopt hist_ignore_dups

# remove command line from history list when first character on the line is a space
setopt hist_ignore_space

# When searching history don't display results already cycled through twice
setopt hist_find_no_dups

# don't execute, just expand history
setopt hist_verify

# Stop annoying error when using asterisk in shell commands (i.e. scp server:*.txt .)
setopt nonomatch

# extended globbing, awesome!
setopt extendedGlob

# Turn on command substitution in the prompt (and parameter expansion and arithmetic expansion).
setopt promptsubst

# Uncomment for speed debug
# zprof