#!/bin/bash

local_user="$2"
password_store_repo="$1"

# Function to run ansible-pull with error handling
run_ansible_pull() {
    local hostname="$1"
    local log_file="/var/log/ansible.log"

    # Clear log file or create if not exists
    > "$log_file"

    # Function to log messages
    log() {
        echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> "$log_file"
    }

    log "Starting ansible-pull for hostname: $hostname"

    if [[ -z "$hostname" ]]; then
        log "Hostname is empty. Exiting."
        exit 1
    fi

    # Validate pass command
    if ! pass show "ansible/workstation/${USER}" > /dev/null 2>&1; then
        log "Pass command failed. Make sure password is available in pass."
        exit 1
    fi

    # Run ansible-pull
    if [[ "$hostname" == *"workstation"* ]]; then
        pass show "ansible/workstation/${USER}"
        ansible-pull --url https://github.com/homeofficehost/dotfiles --vault-id "${USER}@gopass-client.py" --limit "$hostname.local"
    else
        pass show "ansible/workstation/runner"
        ansible-pull --url https://github.com/homeofficehost/dotfiles --vault-id "runner@gopass-client.py" --limit "runner"
    fi

    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log "ansible-pull command failed with exit code $exit_code"
        exit $exit_code
    else
        log "ansible-pull completed successfully"
    fi
}

# Run the ansible-pull command
run_ansible_pull "$(cat /etc/hostname)"

# Exit successfully
exit 0
