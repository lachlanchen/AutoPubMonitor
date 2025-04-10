#!/bin/bash

# Define variables
QUEUE_LIST="/home/lachlan/Projects/autopub_monitor/queue_list.txt"
LOG_DIR="/home/lachlan/Projects/autopub_monitor/logs-autopub"
PUBLISH_SCRIPT="/home/lachlan/Projects/autopub_monitor/autopub.sh"
QUEUE_LOCK="/home/lachlan/Projects/autopub_monitor/queue.lock"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Ensure the log directory and list file exist
mkdir -p "${LOG_DIR}"
touch "${QUEUE_LIST}"
touch "${QUEUE_LOCK}"
echo_with_timestamp "Starting process_queue.sh script..."

# Main loop to process files from the queue
echo_with_timestamp "Entering main processing loop..."
while true; do
    TIMESTAMP=$(date +%s)
    TMP_FILE="/tmp/queue_path_$TIMESTAMP.txt"
    {
        flock -x 200
        if [ -s "$QUEUE_LIST" ]; then
            full_path=$(head -n 1 "$QUEUE_LIST")
            echo "$full_path" > "$TMP_FILE"
            echo_with_timestamp "Read from queue inside lock: $full_path"
        else
            echo "" > "$TMP_FILE"
        fi
    } 200>"$QUEUE_LOCK"

    full_path=$(cat "$TMP_FILE")
    echo_with_timestamp "Variable full_path after lock: $full_path"
    
    if [ -n "$full_path" ]; then
        echo_with_timestamp "Processing: ${full_path}"
        bash "$PUBLISH_SCRIPT" "${full_path}" &>> "${LOG_DIR}/autopub.log"
        result=$?
        if [ $result -eq 0 ]; then
            echo_with_timestamp "Processing completed for: ${full_path}"
            {
                flock -x 200
                sed -i '1d' "$QUEUE_LIST"
                echo_with_timestamp "Removed from queue: $full_path"
            } 200>"$QUEUE_LOCK"
        else
            echo_with_timestamp "Processing failed for: ${full_path} with error code $result"
        fi
        
        rm "$TMP_FILE"
    else
        # echo_with_timestamp "No valid file to process. Waiting for new files in the queue..."
        sleep 1
    fi

done
