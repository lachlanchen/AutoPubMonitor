#!/bin/bash
# autopub_monitor_tmux_session.sh - Manages tmux sessions for autopub monitoring

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration file if it exists
CONFIG_FILE="${SCRIPT_DIR}/autopub_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Warning: Configuration file not found at $CONFIG_FILE"
    echo "Running setup_config.sh to generate configuration..."
    bash "${SCRIPT_DIR}/setup_config.sh" --export
    
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Error: Failed to generate configuration. Using default values."
    fi
fi

# Set home directory - use the current user's home, not root
export HOME_DIR="$HOME"

# Define data directories from config or use defaults
AUTO_PUBLISH_DATA="${AUTOPUB_DATA_DIR:-${HOME_DIR}/AutoPublishDATA}"
AUTO_PUBLISH_DIR="${AUTOPUB_AUTO_PUBLISH_DIR:-${AUTO_PUBLISH_DATA}/AutoPublish}"
TRANSCRIPTION_DATA="${AUTOPUB_TRANSCRIPTION_DATA_DIR:-${AUTO_PUBLISH_DATA}/transcription_data}"

# Define script paths from config or use defaults
SYNC_SCRIPT="${AUTOPUB_SYNC_SCRIPT_PATH:-${SCRIPT_DIR}/autopub_sync.sh}"
MONITOR_SCRIPT="${AUTOPUB_MONITOR_SCRIPT_PATH:-${SCRIPT_DIR}/monitor_autopublish.sh}"
PROCESS_QUEUE_SCRIPT="${AUTOPUB_PROCESS_QUEUE_SCRIPT_PATH:-${SCRIPT_DIR}/process_queue.sh}"

# Define path for jianguoyun sync directories
JIANGUOYUN_DIR="${HOME_DIR}/jianguoyun/AutoPublishDATA"
JIANGUOYUN_TRANSCRIPTION="${JIANGUOYUN_DIR}/transcription_data"

# Ensure required directories exist
mkdir -p "${AUTO_PUBLISH_DIR}"
mkdir -p "${TRANSCRIPTION_DATA}"
mkdir -p "${JIANGUOYUN_DIR}"
mkdir -p "${JIANGUOYUN_TRANSCRIPTION}"

# Ensure all scripts are executable
chmod +x "${SYNC_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${SYNC_SCRIPT} executable"
chmod +x "${MONITOR_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${MONITOR_SCRIPT} executable"
chmod +x "${PROCESS_QUEUE_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${PROCESS_QUEUE_SCRIPT} executable"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

if [ "$1" = "start" ]; then
    echo_with_timestamp "Starting AutoPubMonitor services..."
    
    # Create the 'video-sync' session if it doesn't exist
    if tmux has-session -t video-sync 2>/dev/null; then
        echo_with_timestamp "Session video-sync already exists."
    else
        echo_with_timestamp "Starting video-sync session..."
        tmux new-session -d -s video-sync
        tmux send-keys -t video-sync "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t video-sync "clear" C-m
        tmux send-keys -t video-sync "bash ${SYNC_SCRIPT}" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t monitor-autopub 2>/dev/null; then
        echo_with_timestamp "Starting monitor-autopub session..."
        tmux new-session -d -s monitor-autopub -c "${AUTO_PUBLISH_DIR}"
        tmux send-keys -t monitor-autopub "cd ${AUTO_PUBLISH_DIR}" C-m
        tmux send-keys -t monitor-autopub "clear" C-m
        tmux send-keys -t monitor-autopub "${MONITOR_SCRIPT}" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t process-queue 2>/dev/null; then
        echo_with_timestamp "Starting process-queue session..."
        tmux new-session -d -s process-queue -c "${SCRIPT_DIR}"
        tmux send-keys -t process-queue "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t process-queue "clear" C-m
        tmux send-keys -t process-queue "${PROCESS_QUEUE_SCRIPT}" C-m
    fi
    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t transcription-sync 2>/dev/null; then
        echo_with_timestamp "Starting transcription-sync session..."
        tmux new-session -d -s transcription-sync
        tmux send-keys -t transcription-sync "while true; do rsync -avh --progress ${TRANSCRIPTION_DATA}/ ${JIANGUOYUN_TRANSCRIPTION}/; sleep 10; done" C-m
    fi
    
    echo_with_timestamp "All AutoPubMonitor services started successfully."
    echo_with_timestamp "Use 'tmux attach -t SESSION_NAME' to view a specific session:"
    echo_with_timestamp "  - video-sync: File synchronization service"
    echo_with_timestamp "  - monitor-autopub: File monitoring service"
    echo_with_timestamp "  - process-queue: Queue processing service"
    echo_with_timestamp "  - transcription-sync: Transcription data sync service"
elif [ "$1" = "stop" ]; then
    echo_with_timestamp "Stopping AutoPubMonitor services..."
    
    # Stop all tmux sessions
    for session in video-sync monitor-autopub process-queue transcription-sync; do
        if tmux has-session -t $session 2>/dev/null; then
            echo_with_timestamp "Stopping $session session..."
            tmux kill-session -t $session
        else
            echo_with_timestamp "Session $session is not running."
        fi
    done
    
    echo_with_timestamp "All AutoPubMonitor services have been stopped."
elif [ "$1" = "status" ]; then
    echo_with_timestamp "AutoPubMonitor Service Status:"
    
    for session in video-sync monitor-autopub process-queue transcription-sync; do
        if tmux has-session -t $session 2>/dev/null; then
            echo_with_timestamp "  - $session: RUNNING"
        else
            echo_with_timestamp "  - $session: STOPPED"
        fi
    done
else
    echo "Usage: $0 {start|stop|status}"
    echo
    echo "Commands:"
    echo "  start   - Start all AutoPubMonitor services"
    echo "  stop    - Stop all AutoPubMonitor services"
    echo "  status  - Check the status of all services"
    exit 1
fi
