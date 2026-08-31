#!/bin/bash
# Simple Kimi AI usage bar for waybar with progress bar

TOKEN_FILE="$HOME/.config/kimi-usage/token"

# Get token
if [ -n "$KIMI_TOKEN" ]; then
    TOKEN="$KIMI_TOKEN"
elif [ -f "$TOKEN_FILE" ]; then
    TOKEN=$(cat "$TOKEN_FILE")
else
    echo '{"text":"🤖 No token","tooltip":"Set KIMI_TOKEN or run: mkdir -p ~/.config/kimi-usage && echo YOUR_TOKEN > ~/.config/kimi-usage/token","class":"critical"}'
    exit 0
fi

# Make API request
RESPONSE=$(curl -s --compressed -X POST \
    'https://www.kimi.com/apiv2/kimi.gateway.billing.v1.BillingService/GetUsages' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:147.0) Gecko/20100101 Firefox/147.0' \
    -H 'Accept: application/json' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Accept-Encoding: gzip, deflate, br, zstd' \
    -H 'Referer: https://www.kimi.com/code/console?from=kfc_overview_topbar' \
    -H "authorization: Bearer $TOKEN" \
    -H 'connect-protocol-version: 1' \
    -H 'content-type: application/json' \
    -H 'r-timezone: America/Sao_Paulo' \
    -H 'x-language: en-US' \
    -H 'x-msh-platform: web' \
    -H 'x-msh-version: 1.0.0' \
    -H 'Origin: https://www.kimi.com' \
    --data-raw '{"scope":["FEATURE_CODING"]}' 2>/dev/null)

# Check if response is valid
if [ -z "$RESPONSE" ] || ! echo "$RESPONSE" | grep -q '"usages"'; then
    echo '{"text":"🤖 Error","tooltip":"Failed to fetch usage data","class":"critical"}'
    exit 0
fi

# Parse values (using simple string manipulation)
USED=$(echo "$RESPONSE" | grep -o '"used":"[^"]*"' | head -1 | cut -d'"' -f4)
LIMIT=$(echo "$RESPONSE" | grep -o '"limit":"[^"]*"' | head -1 | cut -d'"' -f4)
REMAINING=$(echo "$RESPONSE" | grep -o '"remaining":"[^"]*"' | head -1 | cut -d'"' -f4)
RESET=$(echo "$RESPONSE" | grep -o '"resetTime":"[^"]*"' | head -1 | cut -d'"' -f4)

# Default values if parsing fails
[ -z "$USED" ] && USED="0"
[ -z "$LIMIT" ] && LIMIT="0"

# Calculate percentage
if [ "$LIMIT" -gt 0 ] 2>/dev/null; then
    PERCENT=$((USED * 100 / LIMIT))
else
    PERCENT=0
fi

# Create progress bar (10 segments)
FILLED=$((PERCENT / 10))
EMPTY=$((10 - FILLED))

# Build bar with Unicode blocks
BAR=""
for ((i=0; i<FILLED; i++)); do
    BAR="${BAR}█"
done
for ((i=0; i<EMPTY; i++)); do
    BAR="${BAR}░"
done

# Determine class
if [ "$PERCENT" -ge 90 ]; then
    CLASS="critical"
elif [ "$PERCENT" -ge 70 ]; then
    CLASS="warning"
else
    CLASS="normal"
fi

# Calculate human-readable time until reset
TIME_LEFT=""
if [ -n "$RESET" ]; then
    # Convert ISO 8601 to epoch seconds
    RESET_EPOCH=$(date -d "$RESET" +%s 2>/dev/null)
    NOW_EPOCH=$(date +%s)
    
    if [ -n "$RESET_EPOCH" ] && [ "$RESET_EPOCH" -gt "$NOW_EPOCH" ] 2>/dev/null; then
        DIFF=$((RESET_EPOCH - NOW_EPOCH))
        
        # Format as human readable
        if [ $DIFF -ge 3600 ]; then
            HOURS=$((DIFF / 3600))
            MINS=$(((DIFF % 3600) / 60))
            TIME_LEFT="${HOURS}h ${MINS}m"
        elif [ $DIFF -ge 60 ]; then
            MINS=$((DIFF / 60))
            SECS=$((DIFF % 60))
            TIME_LEFT="${MINS}m ${SECS}s"
        else
            TIME_LEFT="${DIFF}s"
        fi
    fi
fi

# Format tooltip
TOOLTIP="Kimi AI Usage\n$BAR $PERCENT%\nUsed: $USED/$LIMIT"
[ -n "$REMAINING" ] && TOOLTIP="$TOOLTIP\nRemaining: $REMAINING"
[ -n "$TIME_LEFT" ] && TOOLTIP="$TOOLTIP\nResets in: $TIME_LEFT"

# Output JSON for waybar
echo "{\"text\":\"$BAR $PERCENT%\",\"tooltip\":\"$TOOLTIP\",\"class\":\"$CLASS\",\"percentage\":$PERCENT}"
