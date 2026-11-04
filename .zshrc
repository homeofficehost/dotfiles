# ~/.zshrc — um só arquivo para macOS e Linux.
# Regra: testar o recurso (command -v, -d, -x), não o SO. case $OSTYPE só se inevitável.
# Segredos ficam em ~/.zshenv; o que é só desta máquina, em ~/.zshrc.local (ambos fora do git).

# ─── Completion (cache; rebuild no máx. 1x/dia) ───────────────────────────────
typeset -U fpath
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ─── Ambiente ─────────────────────────────────────────────────────────────────
export DO_NOT_TRACK=1
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="$(command -v hx || command -v helix || command -v vim)"
export VISUAL="$EDITOR"
command -v nvim >/dev/null && export MANPAGER="$(command -v nvim) +Man!"

# Bitwarden SSH agent
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# AWS em XDG
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME/aws/config"
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME/aws/credentials"

export CRUSH_DISABLE_METRICS=1
export TMUXAI_MAX_CAPTURE_LINES=300
export TMUXAI_MAX_CONTEXT_SIZE=150000

# ─── PATH / runtimes ──────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# Python 3.9 user-site scripts (mlx_vlm.generate etc.)
[[ ":$PATH:" == *":$HOME/Library/Python/3.9/bin:"* ]] || export PATH="$HOME/Library/Python/3.9/bin:$PATH"

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

export PNPM_HOME="$HOME/.local/share/pnpm"
[[ ":$PATH:" == *":$PNPM_HOME:"* ]] || export PATH="$PNPM_HOME:$PATH"

# conda/miniforge (o que existir nesta máquina)
for _conda in "$HOME/miniforge3" "$HOME/miniconda3"; do
  [ -x "$_conda/bin/conda" ] && eval "$("$_conda/bin/conda" shell.zsh hook 2>/dev/null)" && break
done
unset _conda

# ─── Histórico ────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=500000
SAVEHIST=$HISTSIZE
setopt appendhistory extended_history inc_append_history hist_expire_dups_first \
       hist_ignore_dups hist_ignore_space hist_find_no_dups hist_verify \
       nonomatch extendedglob promptsubst

if [[ -o zle ]]; then
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  [[ -n "$key[Up]"   ]] && bindkey -- "$key[Up]"   up-line-or-beginning-search
  [[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search
fi

[[ -o zle ]] && command -v fzf >/dev/null && source <(fzf --zsh)

# ─── Bitwarden helpers ────────────────────────────────────────────────────────
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

# Exporta variáveis de um Secure Note "shell-env" (linhas KEY=VALUE)
bw_env() {
    [ -z "$BW_SESSION" ] && { bw_unlock || return 1; }
    local env_data
    env_data=$(bw get item "shell-env" 2>/dev/null | jq -r '.notes // empty')
    [ -z "$env_data" ] && { echo "No 'shell-env' item found in Bitwarden." >&2; return 1; }
    while IFS='=' read -r key value; do
        [ -n "$key" ] && [ -n "$value" ] && export "${key}=${value}"
    done <<< "$env_data"
    echo "Environment loaded from Bitwarden."
}

# ─── Aliases ──────────────────────────────────────────────────────────────────
alias ..="cd .."
alias x="exit"
alias home="cd ~"
alias h="$EDITOR"
alias "?"="tldr"

# Git
alias add="git add"
alias commit="git commit"
alias pull="git pull"
alias push="git push"
alias stat="git status"
alias gdiff="git diff HEAD"
alias vdiff="git difftool HEAD"
alias log="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias g="lazygit"
alias lg="lazygit"

# OpenCode
alias oc='opencode'
# Modo local: sem plugins, agente enxuto (MCP do SwarmUI e skills local-*) no Ollama do devworkstation
alias ocl='opencode --pure --agent local'
alias oo='opencode'
alias cc='opencode'

# SSH shortcuts
alias panel="ssh panel.buildaut.com.au"
alias b1="ssh root@panel3.everadapt.au"

# Backup: devworkstation:~/autobkp -> /Volumes/life/autobkp (rápido, resumível: rode de novo pra continuar)
alias autobkp='rsync -aHAX --partial --append-verify --info=progress2 --human-readable --compress -e "ssh -T -o Compression=no" tg@devworkstation.local:~/autobkp/ /Volumes/life/autobkp/'

# ─── Funções ──────────────────────────────────────────────────────────────────

# Upload: gofile.io (arquivos grandes) e 0x0.st (rápido)
upload() {
  local server
  server=$(curl -s https://api.gofile.io/servers | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['servers'][0]['name'])")
  if [[ -z "$server" ]]; then
    echo "Não foi possível obter servidor do gofile.io" >&2
    return 1
  fi
  curl --progress-bar -F "file=@$1" "https://${server}.gofile.io/uploadFile"
}
upload0x0() { curl -F "file=@$1" https://0x0.st; }

# Download resiliente (retoma, segue redirect; suporte a Google Arts & Culture)
dl() {
  command -v curl >/dev/null 2>&1 || { printf 'dl: curl não encontrado\n' >&2; return 127; }
  if [ $# -eq 0 ]; then printf 'uso: dl URL [URL...]\n' >&2; return 2; fi
  local url
  for url in "$@"; do
    if [[ "$url" =~ '^https?://(www\.)?artsandculture\.google\.com(/u/[0-9]+)?/asset/' ]]; then
      local u
      u=$(printf %s "$url" | sed -E 's#/u/[0-9]+##')
      if command -v dezoomify-rs >/dev/null 2>&1; then
        local base
        base=$(printf %s "$u" | sed -E 's|.*/asset/([^/?#]+)/[A-Za-z0-9_-]+.*|\1|; s/[^A-Za-z0-9._-]+/_/g')
        dezoomify-rs -l "$u" "${base}.jpg" && continue
      fi
      local og img
      og=$(curl -fsL "$u" | tr '\n' ' ' | sed -n 's/.*<meta property="og:image" content="\([^"]*\)".*/\1/p')
      if [ -n "$og" ]; then
        img="${og%%=*}=s0"
        curl -fL --retry 5 --retry-connrefused --retry-delay 2 -C - -OJ "$img" && continue
      fi
    fi
    curl -fL --retry 5 --retry-connrefused --retry-delay 2 --remote-name --remote-time -C - "$url"
  done
}

# mosh com reconexão automática
mosh() {
  while ! command mosh "$@"; do
    sleep 5
  done
}

function watcha {
    watch -d -n 30 $(alias "$@" | cut -d\' -f2)
}

# Docker
function docker_stop {
    docker stop $(docker ps -a -q)
}
function docker_restart {
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker network rm $(docker network ls -q)
    docker-compose build
    docker-compose up -d
}
function docker_reset {
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker network rm $(docker network ls -q)
    docker volume rm $(docker volume ls -q)
    docker system prune --all --force
}

# Apaga node_modules recursivamente (padrão: dir atual)
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
alias rmnode-dev='rmnode ~/fun ~/pro ~/code ~/site ~/voicelayer'

# ─── NNN ──────────────────────────────────────────────────────────────────────
alias n="nnn"
function nnn () {
  command nnn "$@"
  if [ -f "$NNN_TMPFILE" ]; then
    . "$NNN_TMPFILE"
  fi
}
export NNN_TMPFILE="$HOME/.config/nnn/.lastd"
export NNN_OPTS="AdHoU"
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'

# ─── Prompt ───────────────────────────────────────────────────────────────────
command -v starship >/dev/null && eval "$(starship init zsh)"

# ─── Por recurso, não por SO (antes: ~/.zshrc.darwin / ~/.zshrc.linux) ────────

# PATH extra: só o que existe nesta máquina
[ -d /usr/local/anaconda3/bin ]      && export PATH="/usr/local/anaconda3/bin:$PATH"
[ -d /opt/homebrew/opt/llvm/bin ]    && export PATH="$PATH:/opt/homebrew/opt/llvm/bin"
[ -d /opt/homebrew/opt/openjdk ]     && export JAVA_HOME="/opt/homebrew/opt/openjdk" && export PATH="$JAVA_HOME/bin:$PATH"
[ -d "$HOME/.codeium/windsurf/bin" ] && export PATH="$HOME/.codeium/windsurf/bin:$PATH"
[ -f "$HOME/.local/bin/env" ]        && . "$HOME/.local/bin/env"   # uv

# Color scheme (sketchybar, borders)
if command -v sketchybar >/dev/null || command -v borders >/dev/null; then
  export BLACK=0xff181819 WHITE=0xffe2e2e3 RED=0xfffc5d7c GREEN=0xff9ed072 BLUE=0xff76cce0
  export YELLOW=0xffe7c664 ORANGE=0xfff39660 MAGENTA=0xffb39df3 GREY=0xff7f8490
  export TRANSPARENT=0x00000000 BG0=0xff2c2e34 BG1=0xff363944 BG2=0xff414550
fi

# GTK dark mode
if command -v gsettings >/dev/null; then
  export GTK_THEME=Flat-Remix-GTK-Blue-Dark
  export GTK_ICON_THEME=Flat-Remix-Blue-Dark
fi

# oh-my-zsh (onde estiver instalado)
if [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then   # só onde o OMZ está configurado
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  COMPLETION_WAITING_DOTS="true"
  DISABLE_UNTRACKED_FILES_DIRTY="true"
  HIST_STAMPS="dd/mm/yyyy"
  export CASE_SENSITIVE="false" DISABLE_UPDATE_PROMPT="true" DISABLE_AUTO_TITLE="true"
  plugins=(git archlinux compleat dirpersist dircycle zsh-autosuggestions zsh-syntax-highlighting)
  source "$ZSH/oh-my-zsh.sh"
  bindkey -v
fi

# OpenCode TTS (ElevenLabs)
if [ -x "$HOME/.config/opencode/scripts/tts-elevenlabs.sh" ]; then
  export OPENCODE_TTS_FALLBACK_SCRIPT="$HOME/.config/opencode/scripts/tts-elevenlabs.sh"
  export OPENCODE_TTS_CAN_SPEAK_URL="http://localhost:5555/api/speech/can-speak"
  export OPENCODE_TTS_ANNOUNCE_IDLE="true"
  export OPENCODE_TTS_IDLE_MESSAGE="Tarefa concluída."
fi

# ─── Aliases por ferramenta ───────────────────────────────────────────────────
if command -v lsd >/dev/null; then
  alias ls='lsd' l='ls -l' la='ls -a' lla='ls -la' lt='ls --tree'
fi
command -v spf        >/dev/null && alias sf="spf" k="spf"
command -v doko       >/dev/null && alias ld="doko"
command -v lazydocker >/dev/null && alias lddd="lazydocker"
command -v gio        >/dev/null && alias rm='gio trash'
command -v ip         >/dev/null && alias net-off='sudo ip link set enp8s0 down' net-on='sudo ip link set enp8s0 up'
command -v limpar-cache >/dev/null && alias limpa="limpar-cache" limpa-tudo="limpar-cache --sim"   # "limpa" só mostra
[ -d ~/dev ] && alias dev="cd ~/dev/"
alias emu="nvm use 16; firebase emulators:start --import=./firebase-data --export-on-exit"
# futurecommit "mensagem": commit datado de amanhã (precisa do date GNU)
date --version >/dev/null 2>&1 && alias futurecommit='export GIT_AUTHOR_DATE="$(date -d "1 day" --utc)" && export GIT_COMMITTER_DATE="$GIT_AUTHOR_DATE" && git commit -m'

# macOS: apps e utilitários
[ -d /Applications/Moji.app ] && alias moji='open -a Moji'
command -v brew   >/dev/null && alias clean='brew cleanup --prune=all; npm cache clean --force; docker system prune -f'
command -v colima >/dev/null && alias colima_reset='colima stop && colima delete && colima start'
[ -d ~/Library/Caches ] && alias rmplaywright='rm -rf ~/Library/Caches/ms-playwright && echo "Playwright cache cleared"'

# Kernel monitoring (log do macOS)
if [ -x /usr/bin/log ] && [ "$(uname -s)" = Darwin ]; then
  alias km='sudo log stream --predicate "processID == 0" --style compact | python3 ~/.config/opencode/scripts/km-interpreter.py'
  alias km-raw='sudo log stream --predicate "processID == 0" --style compact | grep -v -E "IOSurface|process_is_plugin_host"'
  alias km-err='sudo log stream --predicate "processID == 0" --style compact | grep -i "error\|panic\|fail\|assertion"'
  alias km-net='sudo log stream --predicate "processID == 0" --style compact | grep -i "tcp\|flow_entry\|wlan\|en0\|connect"'
fi

# rclone tgdevbkp (Backblaze B2)
if command -v rclone >/dev/null; then
  alias mnt-b2='rclone mount tgdevbkp:tgdevbkp ~/tgdevbkp-mount --daemon --vfs-cache-mode full'
  alias umnt-b2='sudo umount ~/tgdevbkp-mount'
  hd() {
    if mount | grep -q tgdevbkp-mount; then
      sudo umount ~/tgdevbkp-mount && echo "🟢 tgdevbkp desmontado"
    else
      rclone mount tgdevbkp:tgdevbkp ~/tgdevbkp-mount --daemon --vfs-cache-mode full && echo "🔵 tgdevbkp montado"
    fi
  }
fi

# Visualização do histórico git com gource
command -v gource >/dev/null && alias vizgit="
gource \
    -s .03 \
    -1920x1080 \
    --seconds-per-day 0.25 \
    --auto-skip-seconds .1 \
    --multi-sampling \
    --stop-at-end \
    --key \
    --highlight-users \
    --date-format "%d/%m/%y" \
    --hide mouse,filenames \
    --file-idle-time 0 \
    --max-files 0  \
    --background-colour 000000 \
    --font-size 25 \
    --output-ppm-stream - \
    --output-framerate 30 \
    --colour-images \
    --title 'Visualization' \
    | ffmpeg -y -r 30 -f image2pipe -vcodec ppm -i - -b 65536K movie.mp4"

# ─── Funções por ferramenta ───────────────────────────────────────────────────
command -v yabai >/dev/null && suyabai() {
  local sha; sha=$(shasum -a 256 /opt/homebrew/bin/yabai | awk '{print $1}')
  if [ -f /private/etc/sudoers.d/yabai ]; then
    sudo sed -i '' -e "s/sha256:[[:alnum:]]*/sha256:${sha}/" /private/etc/sudoers.d/yabai
  else
    echo "sudoers file does not exist yet"
  fi
}

# Scud Race (Supermodel)
[ -x ~/supermodel/bin/supermodel ] && scud() {
  cd ~/supermodel && ./bin/supermodel ~/roms/supermodel/scud.zip -borderless -res=2560,1440 "$@"
}

# OCR da tela
command -v screencapture >/dev/null && command -v tesseract >/dev/null && \
  ocrscreen() { local f="/private/tmp/ocr_$$.png"; screencapture -x "$f" && tesseract "$f" stdout --psm 6; rm -f "$f"; }

# Hot corners toggle (Dock do macOS)
if command -v defaults >/dev/null && [ -d /System/Library/CoreServices/Dock.app ]; then
  alias thc='toggle-hot-corners'
  toggle-hot-corners() {
    local state_file="$HOME/.config/hot-corners-state"
    local corners=(wvous-tl-corner wvous-tr-corner wvous-bl-corner wvous-br-corner)
    local modifiers=(wvous-tl-modifier wvous-tr-modifier wvous-bl-modifier wvous-br-modifier)
    local any_active=0
    for corner in "${corners[@]}"; do
      local val=$(defaults read com.apple.dock "$corner" 2>/dev/null || echo 1)
      if [[ "$val" != "1" ]]; then
        any_active=1
        break
      fi
    done
    if [[ "$any_active" -eq 1 ]]; then
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
      for corner in "${corners[@]}"; do
        defaults write com.apple.dock "$corner" -int 1
      done
      for mod in "${modifiers[@]}"; do
        defaults write com.apple.dock "$mod" -int 0
      done
      killall Dock
      echo "Hot corners disabled."
    else
      if [[ -f "$state_file" ]]; then
        while IFS='=' read -r key value; do
          [[ -n "$key" && -n "$value" ]] && defaults write com.apple.dock "$key" -int "$value"
        done < "$state_file"
        killall Dock
        echo "Hot corners restored from saved state."
      else
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
fi

# MLX / Qwen3.5 (modelos em /Volumes/life, HF_HOME no .zshenv)
MLX_MODEL="mlx-community/Qwen3.5-9B-MLX-4bit"
MLX_BIN="$HOME/.local/venvs/mlx/bin"   # venv py3.13 com mlx-vlm atual
if [ -x "$MLX_BIN/mlx_vlm.generate" ]; then
  ask()    { "$MLX_BIN/mlx_vlm.generate" --model "$MLX_MODEL" --prompt "$*" --max-tokens 500; }
  askimg() { local img="$1"; shift; "$MLX_BIN/mlx_vlm.generate" --model "$MLX_MODEL" --image "$img" --prompt "$*" --max-tokens 500; }
  alias qwen-chat='"$MLX_BIN/mlx_vlm.chat" --model "$MLX_MODEL"'
fi
# askscreen/askstream/resumir/falar-stream vivem em ~/.local/bin. Encanáveis: askstream img.png | resumir | falar-stream
command -v pbpaste >/dev/null && alias resumo='pbpaste | resumir' resumo-fala='pbpaste | resumir | falar-stream'

# Markdown → PNG (mdimg; tema em ~/.config/mdimg/dracula.css)
if command -v mdimg >/dev/null; then
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
    command -v osascript >/dev/null && osascript -e "set the clipboard to (read (POSIX file \"${output}\") as «class PNGf»)"
    echo "Salvo em: $output (copiado para a área de transferência)"
  }
  alias md2img='_md2img_convert' mdimg='_md2img_convert' md2png='_md2img_convert' mdpng='_md2img_convert' toimg='_md2img_convert' topng='_md2img_convert'
fi

# Restaura último diretório entre sessões (Linux; no Mac o Terminal já faz isso)
case "$OSTYPE" in linux*)
  chpwd_functions+=(save_current_dir)
  save_current_dir() { export SHELL_SESSION_HISTORY_DIR="$PWD"; }
  [ -n "$SHELL_SESSION_HISTORY_DIR" ] && [ -d "$SHELL_SESSION_HISTORY_DIR" ] && cd "$SHELL_SESSION_HISTORY_DIR"
;; esac

# ─── Extras opcionais ─────────────────────────────────────────────────────────
# transcritomator (transcrição local de calls) — tmon liga, tmoff desliga
if [ -x "$HOME/fun/transcritomator/scripts/ctl.sh" ]; then
  alias tmon="$HOME/fun/transcritomator/scripts/ctl.sh start" tmoff="$HOME/fun/transcritomator/scripts/ctl.sh stop"
  alias tmst="$HOME/fun/transcritomator/scripts/ctl.sh status" tmwatch="$HOME/fun/transcritomator/scripts/ctl.sh watch"
  alias tmlogs="$HOME/fun/transcritomator/scripts/ctl.sh logs"
fi
command -v rec >/dev/null && alias grav='rec'   # gravar som do computador (~/.local/bin/rec)
command -v entire >/dev/null && source <(entire completion zsh)
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"
[ -f ~/.lampada.zsh ] && source ~/.lampada.zsh   # atalhos da lâmpada
[ -f ~/.ia.zsh ]      && source ~/.ia.zsh        # atalhos de IA local (ias lista)

# ─── Só desta máquina (não rastreado) ────────────────────────────────────────
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
