#!/bin/bash
# CPU Temperature Monitor for Hyprland
# Plays subtle sounds when CPU temperature changes by 1°C

# Configuration
TEMP_SENSOR="/sys/class/hwmon/hwmon1/temp1_input"  # k10temp (AMD CPU)
SOUND_UP="/home/tg/.config/hypr/scripts/sounds/temp_up.wav"
SOUND_DOWN="/home/tg/.config/hypr/scripts/sounds/temp_down.wav"
POLL_INTERVAL=1  # seconds between checks
VOLUME="0.6"     # volume level (0.0 to 1.0)
THRESHOLD=1      # minimum degrees difference to trigger
WINDOW_SIZE=5    # moving average window (5 readings × 2s = 10s)

# State file to persist temperature across restarts
STATE_FILE="/tmp/cpu-temp-monitor-state"

# Get current temperature in whole degrees Celsius
get_temp() {
    local millidegrees
    millidegrees=$(cat "$TEMP_SENSOR" 2>/dev/null)
    if [[ -n "$millidegrees" ]]; then
        echo $((millidegrees / 1000))
    else
        echo "0"
    fi
}

# Play sound with volume control
play_sound() {
    local sound_file="$1"
    if [[ -f "$sound_file" ]]; then
        pw-play --volume="$VOLUME" "$sound_file" 2>/dev/null &
    fi
}

# Generate sound files if they don't exist
generate_sounds() {
    if [[ ! -f "$SOUND_UP" ]]; then
        # Higher pitch "blip" for temperature rising (880Hz, very short)
        ffmpeg -y -f lavfi -i "sine=frequency=880:duration=0.08" \
            -af "afade=t=in:st=0:d=0.02,afade=t=out:st=0.05:d=0.03,volume=0.5" \
            "$SOUND_UP" 2>/dev/null
    fi
    
    if [[ ! -f "$SOUND_DOWN" ]]; then
        # Lower pitch "blip" for temperature dropping (440Hz, very short)
        ffmpeg -y -f lavfi -i "sine=frequency=440:duration=0.08" \
            -af "afade=t=in:st=0:d=0.02,afade=t=out:st=0.05:d=0.03,volume=0.5" \
            "$SOUND_DOWN" 2>/dev/null
    fi
}

# Main loop
main() {
    echo "CPU Temperature Monitor started"
    echo "Sensor: $TEMP_SENSOR"
    
    # Generate sounds if needed
    generate_sounds
    
    # Initialize last temperature
    local last_temp
    if [[ -f "$STATE_FILE" ]]; then
        last_temp=$(cat "$STATE_FILE")
    else
        last_temp=$(get_temp)
    fi
    
    echo "Initial temperature: ${last_temp}°C"
    echo "Threshold: ${THRESHOLD}°C, Window: ${WINDOW_SIZE} readings ($((WINDOW_SIZE * POLL_INTERVAL))s)"
    
    # Initialize readings array with current temp
    local readings=()
    for ((i=0; i<WINDOW_SIZE; i++)); do
        readings+=("$last_temp")
    done
    local read_index=0
    local last_avg=$last_temp
    
    while true; do
        local current_temp
        current_temp=$(get_temp)
        
        # Update circular buffer
        readings[$read_index]=$current_temp
        read_index=$(( (read_index + 1) % WINDOW_SIZE ))
        
        # Calculate moving average
        local sum=0
        for temp in "${readings[@]}"; do
            sum=$((sum + temp))
        done
        local current_avg=$((sum / WINDOW_SIZE))
        
        local diff=$((current_avg - last_avg))
        
        # Check if average is more than THRESHOLD above last announced
        if [[ $diff -gt $THRESHOLD ]]; then
            echo "$(date '+%H:%M:%S') Temperature UP: ${last_avg}°C → ${current_avg}°C (avg +${diff}°C)"
            play_sound "$SOUND_UP"
            last_avg=$current_avg
            echo "$last_avg" > "$STATE_FILE"
        # Check if average is less than THRESHOLD below last announced
        elif [[ $diff -lt -$THRESHOLD ]]; then
            echo "$(date '+%H:%M:%S') Temperature DOWN: ${last_avg}°C → ${current_avg}°C (avg ${diff}°C)"
            play_sound "$SOUND_DOWN"
            last_avg=$current_avg
            echo "$last_avg" > "$STATE_FILE"
        fi
        
        sleep "$POLL_INTERVAL"
    done
}

# Handle cleanup on exit
cleanup() {
    echo "CPU Temperature Monitor stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Run main loop
main
