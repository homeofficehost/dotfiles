#!/usr/bin/env bash
# ~/.config/hypr/UserScripts/set-video-wallpaper.sh
# Set a different video wallpaper per monitor using mpvpaper.
#
# Features:
# - Enumerates Hyprland monitors
# - Assigns distinct videos per monitor (mapping via MONITOR_VIDEOS or random)
# - Restarts mpvpaper cleanly to avoid overlapping instances
# - Dry-run mode for safe verification
#
# Usage:
#   set-video-wallpaper.sh [--dry-run]
#   Environment:
#     WALLPAPER_DIR      Directory containing videos (default: "$HOME/Videos/Wallpapers")
#     MONITOR_VIDEOS     Optional mapping: "eDP-1=/path/a.mp4;HDMI-A-1=/path/b.webm"
#     MPV_ARGS           Extra mpv args (default: optimized for low CPU)
#
# Requirements: hyprctl, jq, mpvpaper, mpv

set -euo pipefail

# Parse args
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Config
export WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Videos/Wallpapers}"
# Low-CPU defaults for mpv under mpvpaper
MPV_ARGS_DEFAULT=(
  "--no-config"                # ignore heavy user mpv.conf
  "--loop-file=inf"
  "--no-audio"
  "--no-sub"
  "--hwdec=auto-safe"          # prefer hw decode (nvdec/vaapi/vdpau)
  "--vo=gpu-next"
  "--gpu-context=wayland"      # Wayland GL context (widely compatible)
  "--video-sync=display-desync"
  "--interpolation=no"
  "--deband=no"
  "--scale=bilinear" "--cscale=bilinear" "--dscale=bilinear"
  "--framedrop=vo"
  "--vd-lavc-fast=yes"
  "--vf=fps=30"                # cap FPS for wallpaper
)
# Allow MPV_ARGS as a single string; split into array if provided
if [[ -n "${MPV_ARGS:-}" ]]; then
  # shellcheck disable=SC2206
  MPV_ARGS=(${MPV_ARGS})
else
  MPV_ARGS=(${MPV_ARGS_DEFAULT[@]})
fi

# Ensure dependencies
need() { command -v "$1" >/dev/null 2>&1 || { echo "Error: missing dependency: $1" >&2; exit 1; }; }
need hyprctl
need mpvpaper
need jq

# Collect videos
VIDEO_EXTS=("mp4" "mkv" "webm" "mov" "avi" "flv")
VIDEO_FILES=()
if [[ -d "$WALLPAPER_DIR" ]]; then
  # Build find predicate safely without embedding quotes in patterns
  FIND_PRED=()
  for ext in "${VIDEO_EXTS[@]}"; do
    FIND_PRED+=( -iname "*.${ext}" -o )
  done
  # Remove trailing -o
  if (( ${#FIND_PRED[@]} > 0 )); then
    unset 'FIND_PRED[${#FIND_PRED[@]}-1]'
  fi
  while IFS= read -r -d '' file; do
    VIDEO_FILES+=("$file")
  done < <(find "$WALLPAPER_DIR" -type f \( "${FIND_PRED[@]}" \) -print0)
fi

if [[ ${#VIDEO_FILES[@]} -eq 0 && -z "${MONITOR_VIDEOS:-}" ]]; then
  echo "No videos found in $WALLPAPER_DIR and MONITOR_VIDEOS not provided." >&2
  exit 1
fi

# Get monitors
readarray -t MONITORS < <(hyprctl -j monitors | jq -r '.[] | select(.disabled==false) | .name')
if [[ ${#MONITORS[@]} -eq 0 ]]; then
  echo "No enabled monitors found via hyprctl." >&2
  exit 1
fi

# Build monitor->video mapping
# Priority: MONITOR_VIDEOS env mapping, else random assignment from VIDEO_FILES

declare -A MAP
if [[ -n "${MONITOR_VIDEOS:-}" ]]; then
  IFS=';' read -r -a pairs <<< "$MONITOR_VIDEOS"
  for p in "${pairs[@]}"; do
    [[ -z "$p" ]] && continue
    mon="${p%%=*}"
    vid="${p#*=}"
    if [[ -z "$mon" || -z "$vid" ]]; then
      echo "Skipping invalid mapping entry: $p" >&2
      continue
    fi
    if [[ ! -f "$vid" ]]; then
      echo "Warning: mapped file not found for $mon: $vid" >&2
    fi
    MAP["$mon"]="$vid"
  done
fi

# For any monitors without explicit mapping, assign randomly
unmapped=()
for m in "${MONITORS[@]}"; do
  if [[ -z "${MAP[$m]:-}" ]]; then
    unmapped+=("$m")
  fi
done

if (( ${#unmapped[@]} > 0 )); then
  if (( ${#VIDEO_FILES[@]} == 0 )); then
    echo "Cannot auto-assign videos: VIDEO_FILES is empty and no MONITOR_VIDEOS specified for ${#unmapped[@]} monitor(s)." >&2
    exit 1
  fi
  # Shuffle VIDEO_FILES
  mapfile -t SHUFFLED < <(printf '%s
' "${VIDEO_FILES[@]}" | shuf)
  # Assign without replacement, then reuse if needed
  idx=0
  for m in "${unmapped[@]}"; do
    MAP["$m"]="${SHUFFLED[$idx]}"
    idx=$((idx+1))
    if (( idx >= ${#SHUFFLED[@]} )); then idx=0; fi
  done
fi

# Stop other wallpaper daemons to avoid overlay
stop_cmds=(
  "killall mpvpaper"
  "pkill -x hyprpaper"
  "pkill -x swaybg"
  "swww kill"
  "pkill -x swww-daemon"
)
for sc in "${stop_cmds[@]}"; do
  if $DRY_RUN; then
    echo "DRY-RUN: $sc"
  else
    bash -lc "$sc" 2>/dev/null || true
  fi
done

# Launch per monitor
for m in "${MONITORS[@]}"; do
  vid="${MAP[$m]:-}"
  if [[ -z "$vid" ]]; then
    echo "Skipping $m: no video mapped" >&2
    continue
  fi
  if [[ ! -f "$vid" ]]; then
    echo "Warning: $m mapped to missing file: $vid" >&2
  fi
  cmd=(mpvpaper -o "${MPV_ARGS[*]}" "$m" "$vid")
  if $DRY_RUN; then
    echo "DRY-RUN: ${cmd[*]}"
  else
    "${cmd[@]}" &
    disown || true
  fi
  echo "Set $m -> $vid"
done

exit 0
