#!/bin/bash

# Get the current active window's workspace
current_workspace=$(hyprctl activewindow -j | jq -r '.workspace.name // empty')

# Check if the active window is in the special workspace
if [[ "$current_workspace" == "special:special" ]]; then
    # Window is minimized, unminimize it (move to current visible workspace)
    hyprctl dispatch movetoworkspace +0
else
    # Window is not minimized, minimize it (move to special workspace)
    hyprctl dispatch movetoworkspace special
fi
