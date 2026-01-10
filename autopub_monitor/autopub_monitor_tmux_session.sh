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

    MANUAL_SESSION="am-manual"
    
    # Create the 'video-sync' session for file synchronization
    if tmux has-session -t am-video-sync 2>/dev/null; then
        echo_with_timestamp "Session am-video-sync already exists."
    else
        echo_with_timestamp "Creating am-video-sync tmux session..."
        tmux new-session -d -s am-video-sync
        tmux send-keys -t am-video-sync "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t am-video-sync "clear" C-m
        tmux send-keys -t am-video-sync "bash ${AUTOPUB_SYNC_SH}" C-m
    fi

    # Manual processing session (moved from create_tmux_session.sh)
    if tmux has-session -t "$MANUAL_SESSION" 2>/dev/null; then
        echo_with_timestamp "Session ${MANUAL_SESSION} already exists."
    else
        echo_with_timestamp "Creating ${MANUAL_SESSION} tmux session..."
        tmux new-session -d -s "$MANUAL_SESSION"
        tmux send-keys -t "$MANUAL_SESSION" "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t "$MANUAL_SESSION" "source ~/.bashrc" C-m
        tmux send-keys -t "$MANUAL_SESSION" "conda activate lazyedit" C-m
        tmux send-keys -t "$MANUAL_SESSION" "python ${AUTOPUB_PY} --use-cache --use-translation-cache --use-metadata-cache --force" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t am-monitor 2>/dev/null; then
        echo_with_timestamp "Creating am-monitor tmux session..."
        tmux new-session -d -s am-monitor -c "${AUTOPUBLISH_DIR}"
        tmux send-keys -t am-monitor "cd ${AUTOPUBLISH_DIR}" C-m
        tmux send-keys -t am-monitor "clear" C-m
        tmux send-keys -t am-monitor "${MONITOR_AUTOPUBLISH_SH}" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t am-process-queue 2>/dev/null; then
        echo_with_timestamp "Creating am-process-queue tmux session..."
        tmux new-session -d -s am-process-queue -c "${PROJECT_DIR}"
        tmux send-keys -t am-process-queue "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t am-process-queue "clear" C-m
        tmux send-keys -t am-process-queue "${PROCESS_QUEUE_SH}" C-m
    fi
    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t am-transcription-sync 2>/dev/null; then
        echo_with_timestamp "Creating am-transcription-sync tmux session..."
        tmux new-session -d -s am-transcription-sync
        tmux send-keys -t am-transcription-sync "while true; do rsync -avh --progress ${TRANSCRIPTION_DIR}/ ${JIANGUOYUN_TRANSCRIPTION_DIR}/; sleep 10; done" #C-m
    fi
    
    echo_with_timestamp "All services started successfully!"
    
elif [ "$1" = "stop" ]; then
    echo_with_timestamp "Stopping all AutoPub Monitor services..."
    
    # Stop all tmux sessions
    tmux kill-session -t am-video-sync 2>/dev/null
    tmux kill-session -t am-monitor 2>/dev/null
    tmux kill-session -t am-process-queue 2>/dev/null
    tmux kill-session -t am-transcription-sync 2>/dev/null
    tmux kill-session -t am-manual 2>/dev/null
    
    echo_with_timestamp "All services stopped."
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi
