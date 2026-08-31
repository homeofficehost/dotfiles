#!/usr/bin/env bash
# ~/.config/hypr/UserScripts/set-image-wallpaper.sh
# Stop video wallpapers and set an image wallpaper on all monitors.
# Uses swww if available, else falls back to hyprpaper.
#
# Usage: set-image-wallpaper.sh [--dry-run]
# Env:
#   IMAGE_WALLPAPER_DIR  Directory with images (default: "$HOME/Pictures/Wallpapers")
#   IMG_ARGS             Extra args to pass to swww img (e.g., "--transition-type any")
#
set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Config
export IMAGE_WALLPAPER_DIR="${IMAGE_WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
IMG_EXTS=(jpg jpeg png webp bmp)

# Ensure hyprctl
command -v hyprctl >/dev/null 2>&1 || { echo "Error: hyprctl not found" >&2; exit 1; }

# Collect images
IMAGES=()
if [[ -d "$IMAGE_WALLPAPER_DIR" ]]; then
  PRED=()
  for e in "${IMG_EXTS[@]}"; do PRED+=( -iname "*.${e}" -o ); done
  unset 'PRED[${#PRED[@]}-1]' || true
  while IFS= read -r -d '' f; do IMAGES+=("$f"); done < <(find "$IMAGE_WALLPAPER_DIR" -type f \( "${PRED[@]}" \) -print0)
fi

if (( ${#IMAGES[@]} == 0 )); then
  echo "No images found in $IMAGE_WALLPAPER_DIR" >&2
  exit 1
fi

# Pick one image randomly (simple default)
IMG=$(printf '%s
' "${IMAGES[@]}" | shuf -n1)

# Stop video wallpaper
stop_cmds=(
  "mpvpaper -k"
)
for sc in "${stop_cmds[@]}"; do
  if $DRY_RUN; then echo "DRY-RUN: $sc"; else bash -lc "$sc" 2>/dev/null || true; fi
done

# Determine tool: swww preferred, else hyprpaper
if command -v swww >/dev/null 2>&1; then
  # ensure swww daemon
  if $DRY_RUN; then
    echo "DRY-RUN: swww init"
  else
    swww init 2>/dev/null || true
  fi
  # Enumerate outputs (monitor names)
  mapfile -t MONS < <(hyprctl -j monitors | jq -r '.[] | select(.disabled==false) | .name')
  for m in "${MONS[@]}"; do
    cmd=(swww img "$IMG" --outputs "$m")
    # add extra args if any
    if [[ -n "${IMG_ARGS:-}" ]]; then
      # shellcheck disable=SC2206
      ARGS=(${IMG_ARGS})
      cmd+=("${ARGS[@]}")
    fi
    if $DRY_RUN; then echo "DRY-RUN: ${cmd[*]}"; else "${cmd[@]}"; fi
  done
  echo "Applied image wallpaper $IMG to ${#MONS[@]} monitor(s) via swww"
else
  # fallback to hyprpaper minimal config (single image for all monitors)
  command -v hyprpaper >/dev/null 2>&1 || { echo "Error: neither swww nor hyprpaper found" >&2; exit 1; }
  # Write a temp config mapping same image to all monitors
  mapfile -t MONS < <(hyprctl -j monitors | jq -r '.[] | select(.disabled==false) | .name')
  TMP=$(mktemp)
  printf "preload = %s\n" "$IMG" > "$TMP"
  for m in "${MONS[@]}"; do
    printf "wallpaper = %s,%s\n" "$m" "$IMG" >> "$TMP"
  done
  # kill existing hyprpaper
  if $DRY_RUN; then echo "DRY-RUN: pkill -x hyprpaper"; else pkill -x hyprpaper 2>/dev/null || true; fi
  # start hyprpaper with tmp config
  if $DRY_RUN; then
    echo "DRY-RUN: hyprpaper -c $TMP"
  else
    hyprpaper -c "$TMP" & disown || true
  fi
  echo "Applied image wallpaper $IMG to ${#MONS[@]} monitor(s) via hyprpaper"
fi

