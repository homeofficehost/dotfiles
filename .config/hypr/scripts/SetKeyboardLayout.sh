#!/bin/bash

# Force US International with dead keys layout
hyprctl keyword input:kb_layout us
hyprctl keyword input:kb_variant intl
hyprctl keyword input:kb_options ""

# Send notification
notify-send "Keyboard Layout" "Forced to US International with dead keys" -t 2000
