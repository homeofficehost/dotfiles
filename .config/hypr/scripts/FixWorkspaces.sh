#!/bin/bash

# Script to reorganize workspaces on correct monitors
# Odd workspaces (1,3,5,7,9) go to DP-1 (main monitor)
# Even workspaces (2,4,6,8,10) go to HDMI-A-1 (secondary monitor)

# Move odd workspaces to DP-1
for ws in 1 3 5 7 9; do
    hyprctl dispatch moveworkspacetomonitor $ws DP-1
done

# Move even workspaces to HDMI-A-1  
for ws in 2 4 6 8 10; do
    hyprctl dispatch moveworkspacetomonitor $ws HDMI-A-1
done

# Send notification
notify-send "Workspaces Fixed" "Reorganized workspaces on correct monitors" -t 3000
