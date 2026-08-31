#!/bin/bash
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin"
set -euo pipefail

# Language detection from script name or parameter
SCRIPT_NAME=$(basename "$0")
LANG=""
[[ "$SCRIPT_NAME" =~ english|en ]] && LANG="en"
[[ "$1" == "en" || "$1" == "english" ]] && { LANG="en"; shift; }

# Configuration
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_tts${LANG:+_$LANG}.pid"
LOGFILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_tts${LANG:+_$LANG}.log"
if [[ "$LANG" == "en" ]]; then
    DEFAULT_MODEL="en_US-lessac-high"
    MODEL="${HOME}/.local/share/piper/models/${PIPER_MODEL_EN:-$DEFAULT_MODEL}.onnx"
else
    DEFAULT_MODEL="pt_BR-faber-large"
    MODEL="${HOME}/.local/share/piper/models/${PIPER_MODEL:-$DEFAULT_MODEL}.onnx"
fi

# Logging
exec 2>>"$LOGFILE"
log() { printf '[%(%F %T)T] %s\n' -1 "$*" >>"$LOGFILE"; }

# Toggle: stop if running
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    log "stopping PID $(cat "$PIDFILE")"
    kill -TERM -- "-$(cat "$PIDFILE")" 2>/dev/null || true
    rm -f "$PIDFILE"
    log "stopped"
    exit 0
fi
rm -f "$PIDFILE" 2>/dev/null || true

# Start ydotool daemon and send Ctrl+C
pgrep -x ydotoold >/dev/null || { ydotoold & sleep 0.5; }
sleep 0.5 && ydotool key 29:1 46:1 46:0 29:0

# Get text from args or clipboard
t=${*:-$(wl-paste --no-newline 2>/dev/null || xclip -selection clipboard -o 2>/dev/null)}
[[ -z "$t" ]] && { log "no text provided"; exit 1; }

# Language processing
if command -v trans >/dev/null 2>&1; then
    if [[ "$LANG" == "en" ]]; then
        detected=$(trans -identify -b "$t" 2>/dev/null || echo "unknown")
        log "detected language: $detected"
        [[ "$detected" != "en" && "$detected" != "unknown" ]] && {
            t=$(trans -b :en <<<"$t" 2>/dev/null || printf %s "$t")
            log "translated from $detected to English"
        }
    else
        t=$(trans -b :pt <<<"$t" 2>/dev/null || printf %s "$t")
    fi
fi

# Start TTS
log "starting ${LANG:-pt} TTS (len=${#t})"
setsid bash -lc "printf %s \"$t\" | tr '\r\n' '  ' | piper-tts -m \"$MODEL\" -f - 2>>\"$LOGFILE\" | aplay -q -t wav - >>\"$LOGFILE\" 2>&1" </dev/null >>"$LOGFILE" 2>&1 &
echo $! >"$PIDFILE"
log "started ${LANG:-pt} TTS PID $!"
