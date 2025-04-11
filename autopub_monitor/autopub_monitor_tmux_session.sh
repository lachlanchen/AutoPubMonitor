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

# Set home directory
export HOME_DIR=~

# Define data directories from config or use defaults
AUTO_PUBLISH_DATA="${AUTOPUB_DATA_DIR:-${HOME_DIR}/AutoPublishDATA}"
AUTO_PUBLISH_DIR="${AUTOPUB_AUTO_PUBLISH_DIR:-${AUTO_PUBLISH_DATA}/AutoPublish}"
TRANSCRIPTION_DATA="${AUTOPUB_TRANSCRIPTION_DATA_DIR:-${AUTO_PUBLISH_DATA}/transcription_data}"

# Define script paths from config or use defaults
SYNC_SCRIPT="${AUTOPUB_SYNC_SCRIPT_PATH:-${SCRIPT_DIR}/autopub_sync.sh}"
MONITOR_SCRIPT="${AUTOPUB_MONITOR_SCRIPT_PATH:-${SCRIPT_DIR}/monitor_autopublish.sh}"
PROCESS_QUEUE_SCRIPT="${AUTOPUB_PROCESS_QUEUE_SCRIPT_PATH:-${SCRIPT_DIR}/process_queue.sh}"

# Ensure required directories exist
mkdir -p "${AUTO_PUBLISH_DIR}"
mkdir -p "${TRANSCRIPTION_DATA}"

# Ensure all scripts are executable
chmod +x "${SYNC_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${SYNC_SCRIPT} executable"
chmod +x "${MONITOR_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${MONITOR_SCRIPT} executable"
chmod +x "${PROCESS_QUEUE_SCRIPT}" 2>/dev/null || echo "Warning: Cannot make ${PROCESS_QUEUE_SCRIPT} executable"

if [ "$1" = "start" ]; then
    echo "Starting AutoPubMonitor services..."
    
    # Create the 'video-sync' session if it doesn't exist
    if tmux has-session -t video-sync 2>/dev/null; then
        echo "Session video-sync already exists."
    else
        echo "Starting video-sync session..."
        tmux new-session -d -s video-sync
        tmux send-keys -t video-sync "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t video-sync "clear" C-m
        tmux send-keys -t video-sync "bash ${SYNC_SCRIPT}" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t monitor-autopub 2>/dev/null; then
        echo "Starting monitor-autopub session..."
        tmux new-session -d -s monitor-autopub -c "${AUTO_PUBLISH_DIR}"
        tmux send-keys -t monitor-autopub "cd ${AUTO_PUBLISH_DIR}" C-m
        tmux send-keys -t monitor-autopub "clear" C-m
        tmux send-keys -t monitor-autopub "${MONITOR_SCRIPT}" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t process-queue 2>/dev/null; then
        echo "Starting process-queue session..."
        tmux new-session -d -s process-queue -c "${SCRIPT_DIR}"
        tmux send-keys -t process-queue "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t process-queue "clear" C-m
        tmux send-keys -t process-queue "${PROCESS_QUEUE_SCRIPT}" C-m
    fi
    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t transcription-sync 2>/dev/null; then
        echo "Starting transcription-sync session..."
        tmux new-session -d -s transcription-sync
        tmux send-keys -t transcription-sync "while true; do rsync -avh --progress ${TRANSCRIPTION_DATA}/ ${HOME_DIR}/jianguoyun/AutoPublishDATA/transcription_data/; sleep 10; done" C-m
    fi
    
    echo "All AutoPubMonitor services started successfully."
    echo "Use 'tmux attach -t SESSION_NAME' to view a specific session:"
    echo "  - video-sync: File synchronization service"
    echo "  - monitor-autopub: File monitoring service"
    echo "  - process-queue: Queue processing service"
    echo "  - transcription-sync: Transcription data sync service"
elif [ "$1" = "stop" ]; then
    echo "Stopping AutoPubMonitor services..."
    
    # Stop all tmux sessions
    for session in video-sync monitor-autopub process-queue transcription-sync; do
        if tmux has-session -t $session 2>/dev/null; then
            echo "Stopping $session session..."
            tmux kill-session -t $session
        else
            echo "Session $session is not running."
        fi
    done
    
    echo "All AutoPubMonitor services have been stopped."
elif [ "$1" = "status" ]; then
    echo "AutoPubMonitor Service Status:"
    
    for session in video-sync monitor-autopub process-queue transcription-sync; do
        if tmux has-session -t $session 2>/dev/null; then
            echo "  - $session: RUNNING"
        else
            echo "  - $session: STOPPED"
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