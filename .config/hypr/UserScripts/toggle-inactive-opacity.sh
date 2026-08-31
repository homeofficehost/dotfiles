#!/usr/bin/env bash
set -euo pipefail

UC="$HOME/.config/hypr/UserConfigs"
T="$UC/WindowRules-opacity.conf"
O="$UC/WindowRules-opacity-opaque.conf"
R="$UC/WindowRules-opacity-transparent.conf"

[[ "$(readlink -f "$T" || echo)" = "$(readlink -f "$O" || echo)" ]] && ln -sf "$R" "$T" || ln -sf "$O" "$T"

hyprctl reload

