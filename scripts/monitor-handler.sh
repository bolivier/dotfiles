#!/bin/bash

# Hyprland Monitor Event Handler
# Automatically handles monitor disconnect/reconnect events
# - Restarts EWW bar when external monitor reconnects
# - Prevents automatic workspace switching

LOG_FILE="$HOME/code/dotfiles/monitor-handler.log"
EXTERNAL_MONITOR="DP-3"  # Your external monitor name
CURRENT_WORKSPACE=""

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to get current workspace
get_current_workspace() {
    hyprctl activewindow -j | jq -r '.workspace.id' 2>/dev/null || echo "1"
}

# Function to restart eww bar
restart_eww() {
    log_message "Restarting EWW bar..."
    pkill eww 2>/dev/null
    sleep 0.5
    eww open bar
    log_message "EWW bar restarted"
}

# Check if required tools are available
check_dependencies() {
    if ! command -v socat >/dev/null 2>&1; then
        log_message "ERROR: socat not found. Please install socat."
        exit 1
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        log_message "WARNING: jq not found. Workspace preservation may not work correctly."
    fi
    
    if ! command -v eww >/dev/null 2>&1; then
        log_message "ERROR: eww not found. Please install eww."
        exit 1
    fi
}

# Main event handler function
handle_hyprland_event() {
    local event="$1"
    
    # Monitor added event
    if [[ $event =~ ^monitoradded\>\>(.+)$ ]]; then
        local monitor_name="${BASH_REMATCH[1]}"
        log_message "Monitor added: $monitor_name"
        
        # If external monitor reconnected
        if [[ "$monitor_name" == "$EXTERNAL_MONITOR" ]]; then
            log_message "External monitor $EXTERNAL_MONITOR reconnected"
            
            # Store current workspace before any changes
            CURRENT_WORKSPACE=$(get_current_workspace)
            log_message "Current workspace: $CURRENT_WORKSPACE"
            
            # Restart EWW bar
            restart_eww
            
            # Stay on current workspace if we have it
            if [[ -n "$CURRENT_WORKSPACE" && "$CURRENT_WORKSPACE" != "null" ]]; then
                sleep 1  # Give time for workspace changes to settle
                hyprctl dispatch workspace "$CURRENT_WORKSPACE" 2>/dev/null
                log_message "Switched back to workspace $CURRENT_WORKSPACE"
            fi
        fi
    fi
    
    # Monitor removed event
    if [[ $event =~ ^monitorremoved\>\>(.+)$ ]]; then
        local monitor_name="${BASH_REMATCH[1]}"
        log_message "Monitor removed: $monitor_name"
        
        if [[ "$monitor_name" == "$EXTERNAL_MONITOR" ]]; then
            log_message "External monitor $EXTERNAL_MONITOR disconnected"
            # Store current workspace for when monitor reconnects
            CURRENT_WORKSPACE=$(get_current_workspace)
            log_message "Stored current workspace: $CURRENT_WORKSPACE"
        fi
    fi
}

# Main function
main() {
    # Check if HYPRLAND_INSTANCE_SIGNATURE is set
    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        log_message "ERROR: HYPRLAND_INSTANCE_SIGNATURE environment variable not found"
        log_message "Make sure you're running this from within a Hyprland session"
        exit 1
    fi
    
    # Construct socket path
    SOCKET_PATH="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    
    # Check if socket exists
    if [ ! -S "$SOCKET_PATH" ]; then
        log_message "ERROR: Hyprland event socket not found at $SOCKET_PATH"
        exit 1
    fi
    
    # Check dependencies
    check_dependencies
    
    log_message "Starting Hyprland monitor handler..."
    log_message "Monitoring external monitor: $EXTERNAL_MONITOR"
    log_message "Socket path: $SOCKET_PATH"
    
    # Listen to Hyprland events
    while true; do
        socat -u "UNIX-CONNECT:$SOCKET_PATH" STDOUT | while IFS= read -r line; do
            handle_hyprland_event "$line"
        done
        
        # If we reach here, socat exited. Log and restart after delay
        log_message "Connection lost, reconnecting in 5 seconds..."
        sleep 5
    done
}

# Handle script termination gracefully
trap 'log_message "Monitor handler stopped"; exit 0' SIGTERM SIGINT

# Start the handler
main "$@"