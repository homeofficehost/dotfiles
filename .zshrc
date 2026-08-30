# ─── Shell startup optimization ───────────────────────────────────────────────
# Deduplicate fpath so compinit doesn't invalidate its dump due to hash changes.
typeset -U fpath

# Initialize completion system once per day; reuse the cached dump otherwise.
# This prevents Bun's completion script from triggering a slow compinit rebuild.
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

export DO_NOT_TRACK=1
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bitwarden CLI — session key (expira quando o vault trava; rode bw_unlock para renovar)
export BW_SESSION="bd9pBy2KWYlMM/QsFn8mUUj4Fkv+gS7tsuQHf+SLo4UhjPVVnDU3IfZ2UUTIBvCgMRo7b7WWVj+ClWANlAf6fQ=="

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
alias moji='open -a Moji'

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

export PATH="$HOME/miniforge3/bin:/usr/local/anaconda3/bin:$PATH:/opt/homebrew/opt/llvm/bin"

# Java (OpenJDK via Homebrew)
export JAVA_HOME="/opt/homebrew/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# ─── Aliases ──────────────────────────────────────────────────────────────────

alias panel="ssh panel.buildaut.com.au"

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

# OpenCode shortcuts
alias oc='opencode'
alias oo='opencode'
alias cc='opencode'

# Upload file to gofile.io (supports large files)
upload() {
  local server
  server=$(curl -s https://api.gofile.io/servers | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['servers'][0]['name'])")
  if [[ -z "$server" ]]; then
    echo "Não foi possível obter servidor do gofile.io" >&2
    return 1
  fi
  curl --progress-bar -F "file=@$1" "https://${server}.gofile.io/uploadFile"
}

# Kernel monitoring (live, filtered)
alias km='sudo log stream --predicate "processID == 0" --style compact | python3 ~/.config/opencode/scripts/km-interpreter.py'

# Kernel raw (technical, no interpreter)
alias km-raw='sudo log stream --predicate "processID == 0" --style compact | grep -v -E "IOSurface|process_is_plugin_host"'

# Kernel errors only
alias km-err='sudo log stream --predicate "processID == 0" --style compact | grep -i "error\|panic\|fail\|assertion"'

# Kernel network only
alias km-net='sudo log stream --predicate "processID == 0" --style compact | grep -i "tcp\|flow_entry\|wlan\|en0\|connect"'

# ─── Functions ────────────────────────────────────────────────────────────────

alias n="nnn"
function nnn () {
  command nnn "$@"
  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
  fi
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
#eval "$(zoxide init --cmd cd zsh)"

# ─── Sources ──────────────────────────────────────────────────────────────────

#source "$HOME/.cargo/env"
#source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
#source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# API keys ficam no ~/.zshenv (fora do git)

# Added by Windsurf
export PATH="/Users/tg/.codeium/windsurf/bin:$PATH"

# ─── Cleanup Aliases ────────────────────────────────────────────────────────────

# Recursively delete node_modules in N directories (default: current dir)
rmnode() {
  local dirs=("${@:-.}")
  local total_kb=0
  local size_kb
  for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
      echo "Directory not found: $dir" >&2
      continue
    fi
    while IFS= read -r -d '' nm; do
      size_kb=$(du -sk "$nm" 2>/dev/null | cut -f1)
      total_kb=$((total_kb + size_kb))
      rm -rf "$nm"
      if [ "$size_kb" -ge 1024 ]; then
        echo "Removed: $nm ($((size_kb / 1024)) MB)"
      else
        echo "Removed: $nm (${size_kb} KB)"
      fi
    done < <(find "$dir" -type d -name "node_modules" -prune -print0)
  done
  if [ "$total_kb" -ge 1024 ]; then
    echo "Total freed: $((total_kb / 1024)) MB"
  else
    echo "Total freed: ${total_kb} KB"
  fi
}

# rmnode across the usual project directories
alias rmnode-dev='rmnode ~/fun ~/pro ~/code ~/site ~/voicelayer'

# Delete Playwright browser cache
alias rmplaywright='rm -rf ~/Library/Caches/ms-playwright && echo "Playwright cache cleared"'

# Scud Race (Supermodel)
scud() {
  cd ~/supermodel && ./bin/supermodel ~/roms/supermodel/scud.zip -borderless -res=2560,1440 "$@"
}

# Alias para limpeza automática de caches
alias clean='brew cleanup --prune=all; npm cache clean --force; docker system prune -f'

# Colima reset (stop, delete VM, restart)
alias colima_reset='colima stop && colima delete && colima start'

# ─── Hot Corners Toggle ───────────────────────────────────────────────────────

# Toggle hot corners on/off, preserving original settings
alias thc='toggle-hot-corners'

toggle-hot-corners() {
  local state_file="$HOME/.config/hot-corners-state"
  local corners=(wvous-tl-corner wvous-tr-corner wvous-bl-corner wvous-br-corner)
  local modifiers=(wvous-tl-modifier wvous-tr-modifier wvous-bl-modifier wvous-br-modifier)
  
  # Check if any corner is currently active (value != 1 means active)
  local any_active=0
  for corner in "${corners[@]}"; do
    local val=$(defaults read com.apple.dock "$corner" 2>/dev/null || echo 1)
    if [[ "$val" != "1" ]]; then
      any_active=1
      break
    fi
  done
  
  if [[ "$any_active" -eq 1 ]]; then
    # Currently active — save state and disable all
    mkdir -p "$(dirname "$state_file")"
    : > "$state_file"
    for corner in "${corners[@]}"; do
      local val=$(defaults read com.apple.dock "$corner" 2>/dev/null || echo 1)
      echo "${corner}=${val}" >> "$state_file"
    done
    for mod in "${modifiers[@]}"; do
      local val=$(defaults read com.apple.dock "$mod" 2>/dev/null || echo 0)
      echo "${mod}=${val}" >> "$state_file"
    done
    
    # Disable all corners
    for corner in "${corners[@]}"; do
      defaults write com.apple.dock "$corner" -int 1
    done
    for mod in "${modifiers[@]}"; do
      defaults write com.apple.dock "$mod" -int 0
    done
    
    killall Dock
    echo "Hot corners disabled."
  else
    # Currently disabled — restore from state file or set sensible defaults
    if [[ -f "$state_file" ]]; then
      while IFS='=' read -r key value; do
        [[ -n "$key" && -n "$value" ]] && defaults write com.apple.dock "$key" -int "$value"
      done < "$state_file"
      killall Dock
      echo "Hot corners restored from saved state."
    else
      # No saved state — set sensible defaults
      defaults write com.apple.dock wvous-tl-corner -int 2
      defaults write com.apple.dock wvous-tr-corner -int 2
      defaults write com.apple.dock wvous-bl-corner -int 6
      defaults write com.apple.dock wvous-br-corner -int 6
      for mod in "${modifiers[@]}"; do
        defaults write com.apple.dock "$mod" -int 0
      done
      killall Dock
      echo "Hot corners enabled with defaults (Mission Control top, Launchpad bottom)."
    fi
  fi
}

# bun completions
[ -s "/Users/tg/.bun/_bun" ] && source "/Users/tg/.bun/_bun"

# rclone tgdevbkp (Backblaze B2) helpers
alias mnt-b2='/usr/local/bin/rclone mount tgdevbkp:tgdevbkp /Users/tg/tgdevbkp-mount --daemon --vfs-cache-mode full'
alias umnt-b2='sudo umount /Users/tg/tgdevbkp-mount'
hd() {
  if mount | grep -q tgdevbkp-mount; then
    sudo umount /Users/tg/tgdevbkp-mount
    echo "🟢 tgdevbkp desmontado"
  else
    /usr/local/bin/rclone mount tgdevbkp:tgdevbkp /Users/tg/tgdevbkp-mount --daemon --vfs-cache-mode full
    echo "🔵 tgdevbkp montado"
  fi
}

# OpenClaw Completion
[ -f "/Users/tg/.openclaw/completions/openclaw.zsh" ] && source "/Users/tg/.openclaw/completions/openclaw.zsh"

# ─── OCR Screen ────────────────────────────────────────────────────────────────


ocrscreen() { local f="/private/tmp/ocr_$$.png"; screencapture -x "$f" && tesseract "$f" stdout --psm 6; rm -f "$f"; }

# ─── SSH via Bitwarden (convencao gopass-style) ───────────────────────────────
# Convencao: senhas SSH ficam em itens Login nomeados "ssh/<hostname>"
#   ex.: item "ssh/core.thomasdev.xyz" (username=root) -> `ssh core.thomasdev.xyz`
#        preenche a senha automaticamente via sshpass.
# Sem item no cofre -> comportamento normal do ssh.
# ssh() {
#     local host arg skip_next=0 pw
#     # Encontra o destino: primeiro arg que nao e flag nem valor de flag
#     for arg in "$@"; do
#         if [ "$skip_next" -eq 1 ]; then skip_next=0; continue; fi
#         case "$arg" in
#             -i|-l|-p|-o|-F|-J|-L|-R|-D|-b|-c|-m|-S|-W|-w) skip_next=1 ;;
#             -*) ;;
#             *) host="$arg"; break ;;
#         esac
#     done
#     host="${host##*@}"  # remove user@
#     if [ -n "$host" ]; then
#         pw=$(bw get password "ssh/$host" 2>/dev/null)
#         # Se falhou e nao ha sessao, tenta desbloquear e repetir uma vez
#         if [ -z "$pw" ] && [ -z "$BW_SESSION" ]; then
#             bw_unlock >/dev/null 2>&1 && pw=$(bw get password "ssh/$host" 2>/dev/null)
#         fi
#         if [ -n "$pw" ]; then
#             SSHPASS="$pw" command sshpass -e ssh "$@"
#             return
#         fi
#     fi
#     command ssh "$@"
# }

# ─── MLX / Qwen3.5 ──────────────────────────────────────────────────────────
# Modelo em /Volumes/life/ai-models (HF_HOME setado no .zshenv)

MLX_MODEL="mlx-community/Qwen3.5-9B-MLX-4bit"

# Pergunta rápida via texto: ask "qual a capital do brasil?"
ask() {
  mlx_vlm.generate --model "$MLX_MODEL" --prompt "$*" --max-tokens 500
}

# Pergunta sobre uma imagem: askimg foto.png "o que tem nessa imagem?"
askimg() {
  local img="$1"; shift
  mlx_vlm.generate --model "$MLX_MODEL" --image "$img" --prompt "$*" --max-tokens 500
}

# Chat interativo (mantém contexto entre mensagens)
alias qwen-chat='mlx_vlm.chat --model "$MLX_MODEL"'

# ─── Markdown para Imagem ───────────────────────────────────────────────────
# Converte um .md em .png (tema escuro Dracula, largura fixa de 950px), salva
# ao lado do arquivo original e copia pro clipboard.
# Requer: npm install -g mdimg (https://github.com/LolipopJ/mdimg)
# Tema em ~/.config/mdimg/dracula.css

_md2img_convert() {
  local input="$1"
  if [[ -z "$input" || ! -f "$input" ]]; then
    echo "Uso: md2img <arquivo.md>" >&2
    return 1
  fi

  local output="${input%.md}.png"
  local chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

  if [[ -z "$PUPPETEER_EXECUTABLE_PATH" && -x "$chrome" ]]; then
    export PUPPETEER_EXECUTABLE_PATH="$chrome"
  fi

  local theme_css="$HOME/.config/mdimg/dracula.css"

  if ! command mdimg -i "$input" -o "$output" -w 950 --cssText "$(cat "$theme_css")" --theme dark; then
    echo "Falha ao converter. A ferramenta 'mdimg' está instalada? (npm install -g mdimg)" >&2
    return 1
  fi

  osascript -e "set the clipboard to (read (POSIX file \"${output}\") as «class PNGf»)"

  echo "Salvo em: $output (copiado para a área de transferência)"
}

alias md2img='_md2img_convert'
alias mdimg='_md2img_convert'
alias md2png='_md2img_convert'
alias mdpng='_md2img_convert'
alias toimg='_md2img_convert'
alias topng='_md2img_convert'
