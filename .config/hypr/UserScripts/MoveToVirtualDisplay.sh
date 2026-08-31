#!/usr/bin/env bash
# Move active window to the headless virtual display workspace
# Usage: MoveToVirtualDisplay.sh [--silent]

VIRT_NAME="HEADLESS-1"
WS=$(hyprctl monitors -j | jq -r --arg name "$VIRT_NAME" '.[] | select(.name == $name) | .activeWorkspace.id')

if [[ -z "$WS" ]]; then
    notify-send "Virtual Display" "Nenhum display virtual ativo. Use SUPER+F7 primeiro." -t 2000
    exit 1
fi

if [[ "$1" == "--silent" ]]; then
    hyprctl dispatch movetoworkspacesilent "$WS"
else
    hyprctl dispatch movetoworkspace "$WS"
fi
