#!/bin/bash
# Toggle Hyprscrolling layout on/off
# Keeps your current JaKooLit setup and only switches general:layout

notif="$HOME/.config/swaync/images/ja.png"

# current layout (dwindle, master, scrolling, ...)
LAYOUT=$(hyprctl -j getoption general:layout | jq -r '.str')

if [ "$LAYOUT" = "scrolling" ]; then
  # turn Hyprscrolling OFF -> back to dwindle
  hyprctl keyword general:layout dwindle
  notify-send -e -u low -i "$notif" "Dwindle layout (Hyprscrolling OFF)"
else
  # turn Hyprscrolling ON
  hyprctl keyword general:layout scrolling
  notify-send -e -u low -i "$notif" "Hyprscrolling layout (ON)"
fi
