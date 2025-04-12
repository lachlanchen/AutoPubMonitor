#!/bin/bash
# autopub_monitor_tmux_session.sh - Manage tmux sessions for the autopub monitoring system

# Source the config file
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/autopub.config"

echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

if [ "$1" = "start" ]; then
    echo_with_timestamp "Starting all AutoPub Monitor services..."
    
    # Create the 'video-sync' session for file synchronization
    if tmux has-session -t video-sync 2>/dev/null; then
        echo_with_timestamp "Session video-sync already exists."
    else
        echo_with_timestamp "Creating video-sync tmux session..."
        tmux new-session -d -s video-sync
        tmux send-keys -t video-sync "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t video-sync "clear" C-m
        tmux send-keys -t video-sync "bash ${AUTOPUB_SYNC_SH}" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t monitor-autopub 2>/dev/null; then
        echo_with_timestamp "Creating monitor-autopub tmux session..."
        tmux new-session -d -s monitor-autopub -c "${AUTOPUBLISH_DIR}"
        tmux send-keys -t monitor-autopub "cd ${AUTOPUBLISH_DIR}" C-m
        tmux send-keys -t monitor-autopub "clear" C-m
        tmux send-keys -t monitor-autopub "${MONITOR_AUTOPUBLISH_SH}" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t process-queue 2>/dev/null; then
        echo_with_timestamp "Creating process-queue tmux session..."
        tmux new-session -d -s process-queue -c "${PROJECT_DIR}"
        tmux send-keys -t process-queue "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t process-queue "clear" C-m
        tmux send-keys -t process-queue "${PROCESS_QUEUE_SH}" C-m
    fi
    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t transcription-sync 2>/dev/null; then
        echo_with_timestamp "Creating transcription-sync tmux session..."
        tmux new-session -d -s transcription-sync
        tmux send-keys -t transcription-sync "while true; do rsync -avh --progress ${TRANSCRIPTION_DIR}/ ${JIANGUOYUN_TRANSCRIPTION_DIR}/; sleep 10; done" #C-m
    fi
    
    echo_with_timestamp "All services started successfully!"
    
elif [ "$1" = "stop" ]; then
    echo_with_timestamp "Stopping all AutoPub Monitor services..."
    
    # Stop all tmux sessions
    tmux kill-session -t video-sync 2>/dev/null
    tmux kill-session -t monitor-autopub 2>/dev/null
    tmux kill-session -t process-queue 2>/dev/null
    tmux kill-session -t transcription-sync 2>/dev/null
    
    echo_with_timestamp "All services stopped."
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi