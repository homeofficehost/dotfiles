#!/bin/bash
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"

set -euo pipefail

clip="$(mktemp)"; { wl-paste -n 2>/dev/null || xclip -selection clipboard -o 2>/dev/null || xsel -ob 2>/dev/null; } >"$clip" || true; trap '{ { wl-copy 2>/dev/null || xclip -selection clipboard -i 2>/dev/null || xsel -ib 2>/dev/null; } <"$clip" || true; rm -f "$clip" 2>/dev/null || true; }' EXIT

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_tts.pid"
LOGFILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_tts.log"

# Define o modelo de voz via variável de ambiente, com fallback para o padrão
DEFAULT_MODEL="pt_BR-faber-large"
MODEL="${HOME}/.local/share/piper/models/${PIPER_MODEL:-$DEFAULT_MODEL}.onnx"

# Redireciona stderr do script para o log
exec 2>>"$LOGFILE"
log() { printf '[%(%F %T)T] %s\n' -1 "$*" >>"$LOGFILE"; }

# Se já estiver rodando, mata o grupo de processos e sai
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  log "toggle: stopping PID $(cat \"$PIDFILE\")"
  kill -TERM -- "-$(cat "$PIDFILE")" 2>/dev/null || true
  rm -f "$PIDFILE"
  log "toggle: stopped"
  exit 0
fi
rm -f "$PIDFILE" 2>/dev/null || true

# Start ydotool daemon if not running
if ! pgrep -x ydotoold > /dev/null; then
    ydotoold &
    sleep 0.5
fi

# Send Ctrl+C using correct keycodes
# 29 = Left Ctrl, 46 = C
sleep 0.5 && ydotool key 29:1 46:1 46:0 29:0

# Texto via args ou clipboard
t=${*:-$(wl-paste 2>/dev/null || xclip -selection clipboard -o 2>/dev/null)}
[[ -z "$t" ]] && { log "no text provided"; exit 1; }
# Detecta idioma e traduz: en->pt, pt->en, outros->pt
command -v trans >/dev/null 2>&1 && {
    detected_lang="$(trans -b -i <<<"$t" 2>/dev/null | cut -d' ' -f1)"
    case "$detected_lang" in
        en) target_lang="pt" ;;
        pt) target_lang="en" ;;
        *)  target_lang="pt" ;;
    esac
    t="$(trans -b ":$target_lang" <<<"$t" 2>/dev/null || printf %s "$t")"
}

log "toggle: starting TTS (len=${#t})"
# Otimiza threading: usa todos os cores disponíveis
num_threads=$(nproc)
export OMP_NUM_THREADS=$num_threads
export ONNXRUNTIME_NUM_THREADS=$num_threads
# Inicia em nova sessão para permitir kill no grupo inteiro; loga stdout/stderr
setsid bash -lc "printf %s \"$t\" | tr '\r\n' '  ' | piper-tts -m \"$MODEL\" --length-scale 0.8 --sentence-silence 0.1 --noise-scale 0.667 --noise-w 0.8 --cuda -f - 2>>\"$LOGFILE\" | aplay -q -t wav - >>\"$LOGFILE\" 2>&1" </dev/null >>"$LOGFILE" 2>&1 &
child=$!
echo $child > "$PIDFILE"
log "toggle: started PID $child"