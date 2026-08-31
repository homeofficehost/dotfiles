#!/usr/bin/env bash
# Toggle headless virtual display (create/remove)
# Uses a fixed name so it's always predictable, and auto-launches wl-mirror.

VIRT_RES="1920x1080"

# Check if any headless display already exists
VIRT_NAME=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("HEADLESS")) | .name' | head -1)

if [[ -n "$VIRT_NAME" ]]; then
    # Kill wl-mirror first, then remove the display
    pkill -f 'wl-mirror.*HEADLESS' 2>/dev/null
    hyprctl output remove "$VIRT_NAME"
    notify-send "Virtual Display" "Removed $VIRT_NAME" -t 2000
else
    # Remember monitors before creation
    BEFORE=$(hyprctl monitors -j | jq -r '.[].name' | sort)

    hyprctl output create headless
    sleep 0.5

    # Detect the new monitor name by diffing
    AFTER=$(hyprctl monitors -j | jq -r '.[].name' | sort)
    VIRT_NAME=$(comm -13 <(echo "$BEFORE") <(echo "$AFTER") | head -1)

    if [[ -z "$VIRT_NAME" ]]; then
        notify-send "Virtual Display" "Falha ao criar display virtual" -t 2000
        exit 1
    fi

    hyprctl keyword monitor "$VIRT_NAME,${VIRT_RES},auto,1"
    sleep 0.3

    # Focus main monitor so wl-mirror window opens there, not on the virtual display
    hyprctl dispatch focusmonitor DP-1
    sleep 0.2

    # Launch wl-mirror in the background
    nohup wl-mirror "$VIRT_NAME" >/dev/null 2>&1 &
    disown
    notify-send "Virtual Display" "Created $VIRT_NAME + wl-mirror" -t 2000
fi
