export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bitwarden CLI — unlock session
bw_unlock() {
    local session
    session=$(bw unlock --raw 2>/dev/null)
    if [ -n "$session" ]; then
        export BW_SESSION="$session"
        echo "Bitwarden unlocked."
    else
        echo "Bitwarden unlock failed." >&2
        return 1
    fi
}

# Load environment secrets from Bitwarden
# Create a Secure Note in Bitwarden named "shell-env" with notes like:
#   MY_API_KEY=the-value
#   ANOTHER_SECRET=other-value
# Then call bw_env to export them all.
bw_env() {
    if [ -z "$BW_SESSION" ]; then
        bw_unlock || return 1
    fi
    local env_data
    env_data=$(bw get item "shell-env" 2>/dev/null | jq -r '.notes // empty')
    if [ -z "$env_data" ]; then
        echo "No 'shell-env' item found in Bitwarden." >&2
        return 1
    fi
    while IFS='=' read -r key value; do
        if [ -n "$key" ] && [ -n "$value" ]; then
            export "${key}=${value}"
        fi
    done <<< "$env_data"
    echo "Environment loaded from Bitwarden."
}

# OpenCode TTS Plugin - ElevenLabs
export OPENCODE_TTS_FALLBACK_SCRIPT="$HOME/.config/opencode/scripts/tts-elevenlabs.sh"
export OPENCODE_TTS_CAN_SPEAK_URL="http://localhost:5555/api/speech/can-speak"
export OPENCODE_TTS_ANNOUNCE_IDLE="true"
export OPENCODE_TTS_IDLE_MESSAGE="Tarefa concluída."
