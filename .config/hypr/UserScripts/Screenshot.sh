#!/bin/bash

# Screenshot Script for Hyprland
# Usage: Screenshot.sh [--region|--fullscreen|--window|--region-clipboard|--fullscreen-clipboard|--window-clipboard]

SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOTS_DIR"

# Generate filename with timestamp
FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
FILEPATH="$SCREENSHOTS_DIR/$FILENAME"

case "$1" in
    "--region")
        # Screenshot selected region
        grim -g "$(slurp)" "$FILEPATH"
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Region screenshot saved to $FILEPATH"
        fi
        ;;
    "--fullscreen")
        # Screenshot fullscreen
        grim "$FILEPATH"
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Fullscreen screenshot saved to $FILEPATH"
        fi
        ;;
    "--window")
        # Screenshot active window
        WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$WINDOW_GEOMETRY" "$FILEPATH"
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Window screenshot saved to $FILEPATH"
        fi
        ;;
    "--region-clipboard")
        # Screenshot selected region to clipboard
        grim -g "$(slurp)" - | wl-copy
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Region screenshot copied to clipboard"
        fi
        ;;
    "--fullscreen-clipboard")
        # Screenshot fullscreen to clipboard
        grim - | wl-copy
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Fullscreen screenshot copied to clipboard"
        fi
        ;;
    "--window-clipboard")
        # Screenshot active window to clipboard
        WINDOW_GEOMETRY=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$WINDOW_GEOMETRY" - | wl-copy
        if [[ $? -eq 0 ]]; then
            notify-send "Screenshot" "Window screenshot copied to clipboard"
        fi
        ;;
    *)
        echo "Usage: $0 [--region|--fullscreen|--window|--region-clipboard|--fullscreen-clipboard|--window-clipboard]"
        exit 1
        ;;
esac
