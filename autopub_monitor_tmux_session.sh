#!/bin/bash
# autopub_monitor_tmux_session.sh - Manages tmux sessions for autopub monitoring

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set home directory
export HOME_DIR=~

# Define data directories
AUTO_PUBLISH_DATA="${HOME_DIR}/AutoPublishDATA"
AUTO_PUBLISH_DIR="${AUTO_PUBLISH_DATA}/AutoPublish"
TRANSCRIPTION_DATA="${AUTO_PUBLISH_DATA}/transcription_data"

# Ensure required directories exist
mkdir -p "${AUTO_PUBLISH_DIR}"
mkdir -p "${TRANSCRIPTION_DATA}"

if [ "$1" = "start" ]; then
    # Create the 'video-sync' session if it doesn't exist
    if tmux has-session -t video-sync 2>/dev/null; then
        echo "Session video-sync already exists."
    else
        tmux new-session -d -s video-sync
        tmux send-keys -t video-sync "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t video-sync "clear" C-m
        tmux send-keys -t video-sync "bash ${SCRIPT_DIR}/autopub_sync.sh" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t monitor-autopub 2>/dev/null; then
        tmux new-session -d -s monitor-autopub -c "${AUTO_PUBLISH_DIR}"
        tmux send-keys -t monitor-autopub "cd ${AUTO_PUBLISH_DIR}" C-m
        tmux send-keys -t monitor-autopub "clear" C-m
        tmux send-keys -t monitor-autopub "${SCRIPT_DIR}/monitor_autopublish.sh" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t process-queue 2>/dev/null; then
        tmux new-session -d -s process-queue -c "${SCRIPT_DIR}"
        tmux send-keys -t process-queue "cd ${SCRIPT_DIR}" C-m
        tmux send-keys -t process-queue "clear" C-m
        tmux send-keys -t process-queue "${SCRIPT_DIR}/process_queue.sh" C-m
    fi
    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t transcription-sync 2>/dev/null; then
        tmux new-session -d -s transcription-sync
        tmux send-keys -t transcription-sync "while true; do rsync -avh --progress ${TRANSCRIPTION_DATA}/ ${HOME_DIR}/jianguoyun/AutoPublishDATA/transcription_data/; sleep 10; done" C-m
    fi
elif [ "$1" = "stop" ]; then
    # Stop all tmux sessions
    tmux kill-session -t video-sync 2>/dev/null
    tmux kill-session -t monitor-autopub 2>/dev/null
    tmux kill-session -t process-queue 2>/dev/null
    tmux kill-session -t transcription-sync 2>/dev/null
    echo "All autopub-monitor tmux sessions have been stopped."
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi