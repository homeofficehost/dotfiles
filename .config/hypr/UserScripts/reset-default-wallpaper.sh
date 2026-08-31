#!/usr/bin/env bash
# ~/.config/hypr/UserScripts/reset-default-wallpaper.sh
# Kill mpvpaper and restore the default static wallpaper as per initial-boot.sh

set -euo pipefail

scriptsDir="$HOME/.config/hypr/scripts"
wallpaper="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
swww_cmd="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

# Stop any mpvpaper instances
killall -q mpvpaper || true

# If we have a remembered wallpaper, apply it with wallust + swww
if [[ -f "$wallpaper" ]]; then
  # Update colors from wallpaper
  wallust run -s "$wallpaper" >/dev/null 2>&1 || true
  # Ensure swww-daemon is running and set the image with effect
  if ! swww query >/dev/null 2>&1; then
    swww-daemon --format xrgb >/dev/null 2>&1 &
    # give the daemon a moment to start
    sleep 0.2
  fi
  $swww_cmd "$wallpaper" $effect || true
  # Trigger any extra hooks if present
  if [[ -x "$scriptsDir/WallustSwww.sh" ]]; then
    "$scriptsDir/WallustSwww.sh" >/dev/null 2>&1 &
  fi
else
  notify-send "Reset wallpaper" "Arquivo não encontrado: $wallpaper" || true
fi

