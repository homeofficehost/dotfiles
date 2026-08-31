#!/bin/bash

# Screen Recording Script for Hyprland
# Usage: ScreenRecord.sh [--region|--fullscreen|--all-monitors|--region-audio|--fullscreen-audio]

RECORDINGS_DIR="$HOME/Videos/Recordings"
PID_FILE="/tmp/hyprland_recording.pid"

# Create recordings directory if it doesn't exist
mkdir -p "$RECORDINGS_DIR"

# Function to stop recording
stop_recording() {
    if [[ -f "$PID_FILE" ]]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            notify-send "Screen Recording" "Recording stopped and saved to $RECORDINGS_DIR"
        else
            rm -f "$PID_FILE"
            notify-send "Screen Recording" "No active recording found"
        fi
    else
        notify-send "Screen Recording" "No active recording found"
    fi
}

# Check if recording is already active
if [[ -f "$PID_FILE" ]]; then
    stop_recording
    exit 0
fi

# Generate filename with timestamp
FILENAME="screen_record_$(date +%Y%m%d_%H%M%S).mp4"
FILEPATH="$RECORDINGS_DIR/$FILENAME"

case "$1" in
    "--region")
        # Record selected region
        notify-send "Screen Recording" "Select region to record. Press SUPER+V again to stop."
        GEOMETRY=$(slurp)
        if [[ -n "$GEOMETRY" ]]; then
            wf-recorder -g "$GEOMETRY" -f "$FILEPATH" &
            echo $! > "$PID_FILE"
        fi
        ;;
    "--fullscreen")
        # Record current monitor
        notify-send "Screen Recording" "Recording current monitor. Press SUPER+SHIFT+V again to stop."
        MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
        wf-recorder -o "$MONITOR" -f "$FILEPATH" &
        echo $! > "$PID_FILE"
        ;;
    "--all-monitors")
        # Record all monitors
        notify-send "Screen Recording" "Recording all monitors. Press SUPER+CTRL+V again to stop."
        wf-recorder -f "$FILEPATH" &
        echo $! > "$PID_FILE"
        ;;
    "--region-audio")
        # Record selected region with audio
        notify-send "Screen Recording" "Select region to record with audio. Press SUPER+SHIFT+C again to stop."
        GEOMETRY=$(slurp)
        if [[ -n "$GEOMETRY" ]]; then
            wf-recorder -g "$GEOMETRY" --audio -f "$FILEPATH" &
            echo $! > "$PID_FILE"
        fi
        ;;
    "--fullscreen-audio")
        # Record fullscreen with audio
        notify-send "Screen Recording" "Recording fullscreen with audio. Press SUPER+CTRL+SHIFT+C again to stop."
        wf-recorder --audio -f "$FILEPATH" &
        echo $! > "$PID_FILE"
        ;;
    *)
        echo "Usage: $0 [--region|--fullscreen|--all-monitors|--region-audio|--fullscreen-audio]"
        exit 1
        ;;
esac
