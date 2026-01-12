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
    SESSION_NAME="autopub-monitor"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo_with_timestamp "Session ${SESSION_NAME} already exists."
    else
        echo_with_timestamp "Creating ${SESSION_NAME} tmux session..."
        tmux new-session -d -s "$SESSION_NAME" -n autopub
        sleep 2

        # Layout: sync | monitor
        #         process | manual
        tmux split-window -h -t "$SESSION_NAME":0
        tmux split-window -v -t "$SESSION_NAME":0.0
        tmux split-window -v -t "$SESSION_NAME":0.1

        # Top-left: sync
        tmux send-keys -t "$SESSION_NAME":0.0 "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t "$SESSION_NAME":0.0 "clear" C-m
        tmux send-keys -t "$SESSION_NAME":0.0 "bash ${AUTOPUB_SYNC_SH}" C-m

        # Top-right: monitor
        tmux send-keys -t "$SESSION_NAME":0.1 "cd ${AUTOPUBLISH_DIR}" C-m
        tmux send-keys -t "$SESSION_NAME":0.1 "clear" C-m
        tmux send-keys -t "$SESSION_NAME":0.1 "${MONITOR_AUTOPUBLISH_SH}" C-m

        # Bottom-left: process queue
        tmux send-keys -t "$SESSION_NAME":0.2 "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t "$SESSION_NAME":0.2 "clear" C-m
        tmux send-keys -t "$SESSION_NAME":0.2 "${PROCESS_QUEUE_SH}" C-m

        # Bottom-right: manual
        tmux send-keys -t "$SESSION_NAME":0.3 "cd ${PROJECT_DIR}" C-m
        tmux send-keys -t "$SESSION_NAME":0.3 "source ~/.bashrc" C-m
        tmux send-keys -t "$SESSION_NAME":0.3 "conda activate lazyedit" C-m
        tmux send-keys -t "$SESSION_NAME":0.3 "python ${AUTOPUB_PY} --use-cache --use-translation-cache --use-metadata-cache --force" C-m
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
    
    # Stop the combined tmux session
    tmux kill-session -t autopub-monitor 2>/dev/null

    # Stop legacy tmux sessions if they exist
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
