#!/bin/bash
# Waybar module for CPU Temperature Monitor status

if pgrep -f "cpu-temp-monitor.sh" > /dev/null; then
    echo '{"text": "🌡️", "tooltip": "CPU Temp Monitor: Active", "class": "active"}'
else
    echo '{"text": "❄️", "tooltip": "CPU Temp Monitor: Inactive", "class": "inactive"}'
fi
