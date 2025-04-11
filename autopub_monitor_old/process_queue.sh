#!/bin/bash
# process_queue.sh - Processes files from the queue

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

# Define variables from configuration or use defaults
QUEUE_LIST="${AUTOPUB_QUEUE_LIST_PATH:-${SCRIPT_DIR}/queue_list.txt}"
LOG_DIR="${AUTOPUB_LOGS_AUTOPUB_DIR:-${SCRIPT_DIR}/logs-autopub}"
PUBLISH_SCRIPT="${AUTOPUB_AUTOPUB_SH_PATH:-${SCRIPT_DIR}/autopub.sh}"
QUEUE_LOCK="${AUTOPUB_QUEUE_LOCK_PATH:-${SCRIPT_DIR}/queue.lock}"

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
        # Uncomment this line for more verbose logging
        # echo_with_timestamp "No valid file to process. Waiting for new files in the queue..."
        sleep 1
    fi
done