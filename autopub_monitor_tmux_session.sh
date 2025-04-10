#!/bin/bash

export HOME_DIR=~

if [ "$1" = "start" ]; then
    # Create the 'autopub-sync' session and execute the rsync command within it
    if tmux has-session -t video-sync 2>/dev/null; then
        echo "Session video-sync already exists."
    else
        tmux new-session -d -s video-sync
        # tmux send-keys -t video-sync "cd $HOME_DIR && rsync -avh --progress $HOME_DIR/jianguoyun/AutoPublishDATA/ $HOME_DIR/AutoPublishDATA/" C-m
        # tmux send-keys -t video-sync "while true; do rsync -avh --delete --progress $HOME_DIR/jianguoyun/AutoPublishDATA/AutoPublish/ $HOME_DIR/AutoPublishDATA/AutoPublish/; sleep 10; done" C-m
        # tmux send-keys -t video-sync "while true; do rsync -avh --progress $HOME_DIR/jianguoyun/AutoPublishDATA/AutoPublish/ $HOME_DIR/AutoPublishDATA/AutoPublish/; sleep 10; done" C-m
        # tmux send-keys -t video-sync "while true; do rsync -rtvvv --progress /home/lachlan/jianguoyun/AutoPublishDATA/AutoPublish/ /home/lachlan/AutoPublishDATA/AutoPublish/; sleep 10; done" C-m
        # tmux send-keys -t video-sync "while true; do rsync -rt --progress --whole-file /home/lachlan/jianguoyun/AutoPublishDATA/AutoPublish/ /home/lachlan/AutoPublishDATA/AutoPublish/; sleep 10; done" C-m
        tmux send-keys -t video-sync "cd /home/lachlan/Projects/autopub_monitor/" C-m
        tmux send-keys -t video-sync "clear" C-m
        tmux send-keys -t video-sync "bash /home/lachlan/Projects/autopub_monitor/autopub_sync.sh" C-m
    fi

    # Start or ensure the monitor-autopub session is running
    if ! tmux has-session -t monitor-autopub 2>/dev/null; then
        tmux new-session -d -s monitor-autopub -c /home/lachlan/AutoPublishDATA/AutoPublish
        tmux send-keys -t monitor-autopub "cd /home/lachlan/AutoPublishDATA/AutoPublish" C-m
        tmux send-keys -t monitor-autopub "clear" C-m
        tmux send-keys -t monitor-autopub "/home/lachlan/ProjectsLFS/autopub_monitor/monitor_autopublish.sh" C-m
    fi

    # Start or ensure the process-queue session is running
    if ! tmux has-session -t process-queue 2>/dev/null; then
        tmux new-session -d -s process-queue -c /home/lachlan/ProjectsLFS/autopub_monitor
        tmux send-keys -t process-queue "cd /home/lachlan/ProjectsLFS/autopub_monitor" C-m
        tmux send-keys -t process-queue "clear" C-m
        tmux send-keys -t process-queue "./process_queue.sh" C-m
    fi

    
    # Create the 'transcription-sync' session for syncing transcription_data directory
    if ! tmux has-session -t transcription-sync 2>/dev/null; then
        tmux new-session -d -s transcription-sync
        tmux send-keys -t transcription-sync "while true; do rsync -avh --progress $HOME_DIR/AutoPublishDATA/transcription_data/ $HOME_DIR/jianguoyun/AutoPublishDATA/transcription_data/; sleep 10; done"
    fi
elif [ "$1" = "stop" ]; then
    # Stop the monitor-autopub and process-queue tmux sessions
    tmux kill-session -t video-sync 2>/dev/null
    tmux kill-session -t monitor-autopub 2>/dev/null
    tmux kill-session -t process-queue 2>/dev/null
    tmux kill-session -t transcription-sync 2>/dev/null
else
    echo "Usage: $0 {start|stop}"
    exit 1
fi

