# ~/.zshrc — núcleo comum (macOS + Linux)
# Específico de cada SO fica em ~/.zshrc.darwin / ~/.zshrc.linux (final do arquivo).
# Segredos ficam em ~/.zshenv (fora do git).

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

# ─── Overlay por SO ───────────────────────────────────────────────────────────
case "$OSTYPE" in
  darwin*) [ -r ~/.zshrc.darwin ] && source ~/.zshrc.darwin ;;
  linux*)  [ -r ~/.zshrc.linux ]  && source ~/.zshrc.linux ;;
esac

# transcritomator (transcrição local de calls) — tmon liga, tmoff desliga
alias tmon="$HOME/fun/transcritomator/scripts/ctl.sh start"
alias tmoff="$HOME/fun/transcritomator/scripts/ctl.sh stop"
alias tmst="$HOME/fun/transcritomator/scripts/ctl.sh status"
alias tmwatch="$HOME/fun/transcritomator/scripts/ctl.sh watch"
alias tmlogs="$HOME/fun/transcritomator/scripts/ctl.sh logs"


# Entire CLI shell completion
autoload -Uz compinit && compinit && source <(entire completion zsh)

[ -f ~/.lampada.zsh ] && source ~/.lampada.zsh  # atalhos da lâmpada

# Gravar som do computador (script ~/.local/bin/rec)
alias grav='rec'

# Tradução offline (Argos Translate). Uso: traduz "texto"  |  traduz < arquivo.txt  |  traduz-en "text" (EN -> PT)
traduz() { printf %s "${*:-$(cat)}" | argos-translate --from-lang pt --to-lang en 2>/dev/null; echo; }
traduz-en() { printf %s "${*:-$(cat)}" | argos-translate --from-lang en --to-lang pt 2>/dev/null; echo; }
# Added by Kiro CLI
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="${PATH:+$PATH:}$HOME/.local/bin" ;; esac
[ -f ~/.ia.zsh ] && source ~/.ia.zsh  # atalhos de IA local (ias lista)
[ -f ~/.busca.zsh ] && source ~/.busca.zsh  # busca em texto com rg (busca lista)
