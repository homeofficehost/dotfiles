#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# source https://wiki.archlinux.org/title/Hyprland#Using_a_script_to_change_wallpaper_every_X_minutes

# This script will randomly go through the files of a directory, setting it
# up as the wallpaper at regular intervals
#
# NOTE: this script uses bash (not POSIX shell) for the RANDOM variable

wallust_refresh=$HOME/.config/hypr/scripts/RefreshNoWaybar.sh

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

if [[ $# -lt 1 ]] || [[ ! -d $1   ]]; then
	echo "Usage:
	$0 <dir containing images>"
	exit 1
fi

# Edit below to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_TYPE=simple

# This controls (in seconds) when to switch to the next image
INTERVAL=1800

# Abort if video wallpaper (mpvpaper) is active
if pgrep -x mpvpaper >/dev/null; then
    echo "mpvpaper detected; aborting WallpaperAutoChange to avoid overriding video wallpaper."
    exit 0
fi

while true; do
    # If mpvpaper becomes active at any time, stop this script to avoid overriding video wallpaper
    if pgrep -x mpvpaper >/dev/null; then
        echo "mpvpaper detected; stopping WallpaperAutoChange loop."
        exit 0
    fi

	find "$1" \
		| while read -r img; do
			echo "$((RANDOM % 1000)):$img"
		done \
		| sort -n | cut -d':' -f2- \
		| while read -r img; do
			# Skip applying image if mpvpaper is running (extra safety)
			if pgrep -x mpvpaper >/dev/null; then
				# stop entire script cleanly by killing parent shell of this subshell
				# but simplest is to just exit here; outer loop will also exit on next iteration check
				exit 0
			fi
			swww img -o "$focused_monitor" "$img"
			$wallust_refresh
			sleep "$INTERVAL"
			
		done
done
