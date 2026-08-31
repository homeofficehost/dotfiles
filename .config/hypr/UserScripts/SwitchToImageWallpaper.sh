#!/usr/bin/env bash
# Switch to image wallpaper mode: stop mpvpaper, (re)start swww and apply an image
# Priority of image source:
# 1) ~/.config/hypr/wallpaper_effects/.wallpaper_current if exists
# 2) Random image from ~/Pictures/wallpapers

set -euo pipefail

# Kill video wallpaper if running
if pgrep -x mpvpaper >/dev/null; then
  pkill -x mpvpaper || true
fi

# Ensure swww-daemon is running
if ! pgrep -x swww-daemon >/dev/null; then
  swww-daemon --format xrgb &
  # Give it a moment to initialize
  sleep 0.3
fi

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
SWWW_PARAMS="--transition-fps 60 --transition-type simple"

# Preferred current wallpaper (if set by previous flows)
current_wall="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

pick_random_image() {
  find -L "$HOME/Pictures/wallpapers" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
    -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" \) | shuf -n 1
}

image_to_apply=""
if [[ -f "$current_wall" ]]; then
  image_to_apply="$current_wall"
else
  image_to_apply="$(pick_random_image || true)"
fi

if [[ -z "${image_to_apply:-}" ]]; then
  notify-send -u low -i "$HOME/.config/swaync/images/ja.png" "Wallpaper" "Nenhuma imagem encontrada em ~/Pictures/wallpapers"
  exit 0
fi

# Apply image
swww img -o "$focused_monitor" "$image_to_apply" $SWWW_PARAMS

# Update colors and refresh UI
if [[ -x "$HOME/.config/hypr/scripts/WallustSwww.sh" ]]; then
  "$HOME/.config/hypr/scripts/WallustSwww.sh" &
fi
if [[ -x "$HOME/.config/hypr/scripts/Refresh.sh" ]]; then
  sleep 0.5
  "$HOME/.config/hypr/scripts/Refresh.sh" &
fi

notify-send -u low -i "$HOME/.config/swaync/images/ja.png" "Wallpaper" "Modo imagem ativado"

