#!/bin/bash
# Toggle CPU Temperature Monitor on/off

SCRIPT_NAME="cpu-temp-monitor.sh"
SCRIPT_PATH="/home/tg/.config/hypr/scripts/$SCRIPT_NAME"

# Check if already running
if pgrep -f "$SCRIPT_NAME" > /dev/null; then
    # Stop the monitor
    pkill -f "$SCRIPT_NAME"
    notify-send -t 2000 "CPU Temp Monitor" "Disabled" -i temperature-cold
else
    # Start the monitor
    "$SCRIPT_PATH" &
    disown
    notify-send -t 2000 "CPU Temp Monitor" "Enabled" -i temperature-warm
fi
