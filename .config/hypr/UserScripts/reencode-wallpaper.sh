#!/usr/bin/env bash
# Re-encode a video for low-CPU wallpaper playback with mpv/mpvpaper.
# Produces an H.264 8-bit yuv420p, 30 fps file at target width, preserving aspect ratio.
# Auto-picks encoder: nvenc (NVIDIA) > vaapi (Intel/AMD) > libx264.
#
# Usage:
#   reencode-wallpaper.sh input.mp4 [target_width]
# Examples:
#   reencode-wallpaper.sh in.webm 1920
#   reencode-wallpaper.sh in.mov       # defaults to 1920

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <input> [target_width]" >&2
  exit 1
fi

IN="$1"
W="${2:-1920}"
BASE="$(basename -- "$IN")"
NAME="${BASE%.*}"
OUT_DIR="$HOME/Videos/Wallpapers/encoded"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/${NAME}_${W}w_30fps_h264.mp4"

if [[ ! -f "$IN" ]]; then
  echo "Input not found: $IN" >&2
  exit 1
fi

# Detect encoder availability
has() { command -v "$1" >/dev/null 2>&1; }
enc="libx264"
# Try to detect NVIDIA NVENC support in ffmpeg build
if ffmpeg -hide_banner -encoders 2>/dev/null | grep -qE '\b(h264_nvenc)\b'; then
  enc="h264_nvenc"
elif ffmpeg -hide_banner -encoders 2>/dev/null | grep -qE '\b(h264_vaapi)\b'; then
  enc="h264_vaapi"
fi

vf_scale="scale=${W}:-2:flags=lanczos,fps=30"

case "$enc" in
  h264_nvenc)
    echo "Encoding with NVIDIA NVENC -> $OUT"
    ffmpeg -y -v error -i "$IN" -vf "$vf_scale,format=yuv420p" \
      -c:v h264_nvenc -preset p5 -tune hq -rc vbr -cq 23 -b:v 0 \
      -pix_fmt yuv420p -movflags +faststart -an "$OUT"
    ;;
  h264_vaapi)
    echo "Encoding with VAAPI -> $OUT"
    ffmpeg -y -v error -hwaccel vaapi -hwaccel_output_format vaapi -i "$IN" \
      -vf "format=nv12,hwupload,$vf_scale" -c:v h264_vaapi -qp 22 \
      -movflags +faststart -an "$OUT"
    ;;
  *)
    echo "Encoding with libx264 (CPU) -> $OUT"
    ffmpeg -y -v error -i "$IN" -vf "$vf_scale" -c:v libx264 -preset veryfast -crf 23 \
      -pix_fmt yuv420p -movflags +faststart -an "$OUT"
    ;;
 esac

echo "Done: $OUT"

