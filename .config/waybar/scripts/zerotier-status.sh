#!/usr/bin/env bash
# Waybar: show zerotier IP status

IP="10.147.18.173"

# Tenta fazer ping no IP (1 pacote, timeout de 2 segundos)
if ping -c 1 -W 2 "$IP" &> /dev/null; then
    # Online - emoji de check verde
    emoji="✅"
    status="online"
    tooltip="ZeroTier: Online ($IP)"
else
    # Offline - emoji de X vermelho
    emoji="❌"
    status="offline"
    tooltip="ZeroTier: Offline ($IP)"
fi

printf '{ "text": "%s %s", "tooltip": "%s", "class": "%s" }\n' "$emoji" "$IP" "$tooltip" "$status"
