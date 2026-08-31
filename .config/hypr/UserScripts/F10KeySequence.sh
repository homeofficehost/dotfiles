#!/bin/bash
# F10 -> ydotool F11 -> espera 0.1s -> fullscreen

echo "[DEBUG] Enviando F11 via ydotool..."
# Usar ydotool para apertar F11 (código 87) com delay maior
YDOTOOL_SOCKET=/tmp/.ydotool_socket ydotool key --key-delay 50 87:1 87:0

echo "[DEBUG] Aguardando 0.2s..."
# Esperar um pouco mais
sleep 0.2

echo "[DEBUG] Executando fullscreen..."
# Colocar em fullscreen usando hyprctl
hyprctl dispatch fullscreen
