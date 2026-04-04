export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bitwarden CLI — unlock session
bw_unlock() {
    local session
    session=$(bw unlock --raw 2>/dev/null)
    if [ -n "$session" ]; then
        export BW_SESSION="$session"
        echo "Bitwarden unlocked."
    else
        echo "Bitwarden unlock failed." >&2
        return 1
    fi
}

# Load environment secrets from Bitwarden
# Create a Secure Note in Bitwarden named "shell-env" with notes like:
#   MY_API_KEY=the-value
#   ANOTHER_SECRET=other-value
# Then call bw_env to export them all.
bw_env() {
    if [ -z "$BW_SESSION" ]; then
        bw_unlock || return 1
    fi
    local env_data
    env_data=$(bw get item "shell-env" 2>/dev/null | jq -r '.notes // empty')
    if [ -z "$env_data" ]; then
        echo "No 'shell-env' item found in Bitwarden." >&2
        return 1
    fi
    while IFS='=' read -r key value; do
        if [ -n "$key" ] && [ -n "$value" ]; then
            export "${key}=${value}"
        fi
    done <<< "$env_data"
    echo "Environment loaded from Bitwarden."
}

# OpenCode TTS Plugin - ElevenLabs
export OPENCODE_TTS_FALLBACK_SCRIPT="$HOME/.config/opencode/scripts/tts-elevenlabs.sh"
export OPENCODE_TTS_CAN_SPEAK_URL="http://localhost:5555/api/speech/can-speak"
export OPENCODE_TTS_ANNOUNCE_IDLE="true"
export OPENCODE_TTS_IDLE_MESSAGE="Tarefa concluída."

# ─── Exports ──────────────────────────────────────────────────────────────────

# Color Scheme (used by sketchybar, borders, etc.)
export BLACK=0xff181819
export WHITE=0xffe2e2e3
export RED=0xfffc5d7c
export GREEN=0xff9ed072
export BLUE=0xff76cce0
export YELLOW=0xffe7c664
export ORANGE=0xfff39660
export MAGENTA=0xffb39df3
export GREY=0xff7f8490
export TRANSPARENT=0x00000000
export BG0=0xff2c2e34
export BG1=0xff363944
export BG2=0xff414550

# Editor
export EDITOR="$(which hx)"
export VISUAL="$(which hx)"
export MANPAGER="$(which nvim) +Man!"
export XDG_CONFIG_HOME="$HOME/.config"

# ─── PATH ─────────────────────────────────────────────────────────────────────

export PATH="$HOME/miniforge3/bin:/usr/local/anaconda3/bin:$PATH:$(brew --prefix)/opt/llvm/bin"

# ─── Aliases ──────────────────────────────────────────────────────────────────

# Common dirs
alias home="cd ~"

# System
alias ..="cd .."
alias x="exit"

# Git
alias add="git add"
alias commit="git commit"
alias pull="git pull"
alias stat="git status"
alias gdiff="git diff HEAD"
alias vdiff="git difftool HEAD"
alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias push="git push"
alias g="lazygit"

# ─── Functions ────────────────────────────────────────────────────────────────

alias n="nnn"
function nnn () {
  command nnn "$@"
  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
  fi
}

function kill () {
  command kill -KILL $(pidof "$@")
}

function suyabai () {
  SHA256=$(shasum -a 256 /opt/homebrew/bin/yabai | awk "{print \$1;}")
  if [ -f "/private/etc/sudoers.d/yabai" ]; then
    sudo sed -i '' -e 's/sha256:[[:alnum:]]*/sha256:'${SHA256}'/' /private/etc/sudoers.d/yabai
  else
    echo "sudoers file does not exist yet"
  fi
}

# ─── NNN Config ───────────────────────────────────────────────────────────────

export NNN_TMPFILE="$HOME/.config/nnn/.lastd"
export NNN_OPTS="AdHoU"
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'

# ─── Evals ────────────────────────────────────────────────────────────────────

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ─── Sources ──────────────────────────────────────────────────────────────────

source "$HOME/.cargo/env"
source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
