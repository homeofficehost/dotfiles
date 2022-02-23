# https://blog.jonlu.ca/posts/speeding-up-zsh
# Uncomment for speed debug
# zmodload zsh/zprof


### EXPORT
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh-custom/ # Default is $ZSH/custom
export TERM="xterm-256color"                      # getting proper colors
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export EDITOR="emacsclient -t -a ''"              # $EDITOR use Emacs in terminal
export VISUAL="emacsclient -c -a emacs"           # $VISUAL use Emacs in GUI mode

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="false"

# disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"
export DISABLE_UPDATE_PROMPT="true"

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


### SET MANPAGER
### Uncomment only one of these!

### "bat" as manpager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

### "vim" as manpager
# export MANPAGER='/bin/bash -c "vim -MRn -c \"set buftype=nofile showtabline=0 ft=man ts=8 nomod nolist norelativenumber nonu noma\" -c \"normal L\" -c \"nmap q :qa<CR>\"</dev/tty <(col -b)"'

### "nvim" as manpager
# export MANPAGER="nvim -c 'set ft=man' -"

### SET VI MODE ###
# Comment this line out to enable default emacs-like bindings
bindkey -v

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

### CHANGE TITLE OF TERMINALS
case ${TERM} in
  xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|alacritty|st|konsole*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
        ;;
  screen*)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
    ;;
esac

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
plugins+=(cp)
plugins+=(tmuxinator)
plugins+=(zsh-z)
plugins+=(zsh-autosuggestions)
plugins+=(zsh-completions)
plugins+=(zsh-syntax-highlighting)
if [[ "$OS" == "Linux" ]]; then
	plugins+=(archlinux)
fi




###### Prompt
# prompt='%F{35}%* [%j] [%m:%F{75}%f%F{69}%c%f%F{35}] %F{black}%K{red}%#%f%k '

##### History

# Set history file
HISTFILE=~/.zsh_history

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


[ -r $ZSH/oh-my-zsh.sh ] && source $ZSH/oh-my-zsh.sh
[ -r $ZSH/custom/.colored_man_pages.zsh ] && source $ZSH/custom/.colored_man_pages.zsh
[ -r $ZSH/custom/tmuxinator.zsh ] && source $ZSH/custom/tmuxinator.zsh

# npx as default fallback command
# source <(npx --shell-auto-fallback zsh)

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


### Some more aliases

# root privileges
alias doas="doas --"

# navigation
up () {
  local d=""
  local limit="$1"

  # Default to limit of 1
  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi

  for ((i=1;i<=limit;i++)); do
    d="../$d"
  done

  # perform cd. Show error if cd fails
  if ! cd "$d"; then
    echo "Couldn't go up $limit dirs.";
  fi
}

# vim and emacs
alias vim="nvim"
alias em="/usr/bin/emacs -nw"
alias emacs="emacsclient -c -a 'emacs'"
alias doomsync="~/.emacs.d/bin/doom sync"
alias doomdoctor="~/.emacs.d/bin/doom doctor"
alias doomupgrade="~/.emacs.d/bin/doom upgrade"
alias doompurge="~/.emacs.d/bin/doom purge"

# Changing "ls" to "exa"
alias ls='exa -al --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing
alias l.='exa -a | egrep "^\."'

# pacman and yay
alias pacsyu='sudo pacman -Syyu'                 # update only standard pkgs
alias yaysua='yay -Sua --noconfirm'              # update only AUR pkgs (yay)
alias yaysyu='yay -Syu --noconfirm'              # update standard pkgs and AUR pkgs (yay)
alias parsua='paru -Sua --noconfirm'             # update only AUR pkgs (paru)
alias parsyu='paru -Syu --noconfirm'             # update standard pkgs and AUR pkgs (paru)
alias unlock='sudo rm /var/lib/pacman/db.lck'    # remove pacman lock
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # remove orphaned packages

# get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# adding flags
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias lynx='lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss -vikeys'
alias vifm='./.config/vifm/scripts/vifmrun'
alias ncmpcpp='ncmpcpp ncmpcpp_directory=$HOME/.config/ncmpcpp/'
alias mocp='mocp -M "$XDG_CONFIG_HOME"/moc -O MOCDir="$XDG_CONFIG_HOME"/moc'

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'

# Merge Xresources
alias merge='xrdb -merge ~/.Xresources'

# git
alias addup='git add -u'
alias addall='git add .'
alias branch='git branch'
alias checkout='git checkout'
alias clone='git clone'
alias commit='git commit -m'
alias fetch='git fetch'
alias pull='git pull origin'
alias push='git push origin'
alias stat='git status'  # 'status' is protected name so using 'stat' instead
alias tag='git tag'
alias newtag='git tag -a'

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# gpg encryption
# verify signature for isos
alias gpg-check="gpg2 --keyserver-options auto-key-retrieve --verify"
# receive the key of a developer
alias gpg-retrieve="gpg2 --keyserver-options auto-key-retrieve --receive-keys"

# youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac "
alias yta-best="youtube-dl --extract-audio --audio-format best "
alias yta-flac="youtube-dl --extract-audio --audio-format flac "
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a "
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3 "
alias yta-opus="youtube-dl --extract-audio --audio-format opus "
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis "
alias yta-wav="youtube-dl --extract-audio --audio-format wav "
alias ytv-best="youtube-dl -f bestvideo+bestaudio "

# switch between shells
# I do not recommend switching default SHELL from bash.
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# bare git repo alias for dotfiles
alias config="/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME"

# termbin
alias tb="nc termbin.com 9999"

# the terminal rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

# Unlock LBRY tips
alias tips='lbrynet txo spend --type=support --is_not_my_input --blocking'

### DTOS ###
# Copy/paste all content of /etc/dtos over to home folder. A backup of config is created. (Be careful running this!)
alias dtoscopy='[ -d ~/.config ] || mkdir ~/.config && cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S) && cp -rf /etc/dtos/* ~'
# Backup contents of /etc/dtos to a backup folder in $HOME.
alias dtosbackup='cp -Rf /etc/dtos ~/dtos-backup-$(date +%Y.%m.%d-%H.%M.%S)'


### BASH INSULTER (works in zsh though) ###
if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi

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

##### Extract Functions

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
# SAVEIFS=$IFS
# IFS=$(echo -en "\n\b")
# function extract {
#  if [ -z "$1" ]; then
#     # display usage if no parameters given
#     echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
#     echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
#  else
#     for n in "$@"
#     do
#       if [ -f "$n" ] ; then
#           case "${n%,}" in
#             *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
#                          tar xvf "$n"       ;;
#             *.lzma)      unlzma ./"$n"      ;;
#             *.bz2)       bunzip2 ./"$n"     ;;
#             *.cbr|*.rar)       unrar x -ad ./"$n" ;;
#             *.gz)        gunzip ./"$n"      ;;
#             *.cbz|*.epub|*.zip)       unzip ./"$n"       ;;
#             *.z)         uncompress ./"$n"  ;;
#             *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
#                          7z x ./"$n"        ;;
#             *.xz)        unxz ./"$n"        ;;
#             *.exe)       cabextract ./"$n"  ;;
#             *.cpio)      cpio -id < ./"$n"  ;;
#             *.cba|*.ace)      unace x ./"$n"      ;;
#             *)
#                          echo "extract: '$n' - unknown archive method"
#                          return 1
#                          ;;
#           esac
#       else
#           echo "'$n' - file does not exist"
#           return 1
#       fi
#     done
# fi
# }
# IFS=$SAVEIFS


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
# tabtab source for packages
# uninstall by removing these lines
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true
