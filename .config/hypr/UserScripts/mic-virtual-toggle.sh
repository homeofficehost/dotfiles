#!/usr/bin/env bash

# Desliga tudo se já estiver ativo
if pgrep -x pw-loopback > /dev/null; then
  pkill pw-loopback
  echo "Microfone virtual desligado"
  exit 0
fi

# Cria o loopback
pw-loopback \
  --capture-props='media.class=Audio/Sink' \
  --playback-props='media.class=Audio/Source node.name=mic_virtual' &

sleep 1

# Define como microfone padrão
MIC_ID=$(wpctl status | grep -i "mic_virtual" | grep "Audio/Source" | head -n1 | grep -oP '\d+' | head -n1)
[ -n "$MIC_ID" ] && wpctl set-default "$MIC_ID"

# Captura janela ativa e redireciona seu áudio
ACTIVE_PID=$(hyprctl activewindow -j | jq -r '.pid')
if [ -n "$ACTIVE_PID" ] && [ "$ACTIVE_PID" != "null" ]; then
  SINK_ID=$(wpctl status | grep "input.pw-loopback" | grep -oP '\d+' | head -n1)
  STREAM_ID=$(wpctl status | grep -A100 "Streams:" | grep "$ACTIVE_PID" | grep -oP '^\s*\d+' | tr -d ' ' | head -n1)
  
  if [ -n "$SINK_ID" ] && [ -n "$STREAM_ID" ]; then
    wpctl set-default "$SINK_ID"
    pactl move-sink-input "$STREAM_ID" "$SINK_ID"
    echo "Áudio da janela ativa redirecionado (PID: $ACTIVE_PID)"
  fi
fi
