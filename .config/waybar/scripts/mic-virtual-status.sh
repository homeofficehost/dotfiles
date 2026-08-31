#!/usr/bin/env bash

if pgrep -x pw-loopback > /dev/null; then
  echo '{"text": "🎤", "tooltip": "Microfone Virtual Ativo", "class": "active"}'
else
  echo '{"text": "🎙️", "tooltip": "Microfone Virtual Inativo", "class": "inactive"}'
fi
