#!/bin/bash

# Directory to observe
OBSERVE_DIR="/home/lachlan/AutoPublishDATA/AutoPublish"
QUEUE_PIPE="/home/lachlan/Projects/autopub_monitor/queue.pipe"

# Confirmation flag
SKIP_CONFIRMATION=false

# Helper function to queue file
queue_file() {
    local file_path=$1
    echo "$file_path" > "$QUEUE_PIPE" &
    echo "Queued: $file_path"
}

# Process flags
while getopts "y" opt; do
    case $opt in
        y) SKIP_CONFIRMATION=true ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
    esac
done
shift $((OPTIND -1))

# Check if any IDs are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [-y] pattern_or_full_path"
    exit 1
fi

# Support full paths or patterns
input="$1"
if [[ "$input" == *"/"* ]]; then
    # If the input contains a slash, treat it as a full path
    if [ -f "$input" ]; then
        queue_file "$input"
    else
        echo "File does not exist: $input"
        exit 1
    fi
else
    # Use find to handle patterns and special characters
    mapfile -t matches < <(find "$OBSERVE_DIR" -type f -iname "*$input*")

    # Check for no matches
    if [ ${#matches[@]} -eq 0 ]; then
        echo "No files matched."
        exit 0
    fi

    # Function to handle file selection and queuing
    handle_queueing() {
        if [ "$SKIP_CONFIRMATION" = true ] || [ ${#matches[@]} -eq 1 ]; then
            queue_file "${matches[0]}"
        else
            echo "Multiple files matched. Please select the file(s) to queue (comma-separated numbers):"
            local i=1
            for f in "${matches[@]}"; do
                echo "$i) $f"
                ((i++))
            done
            read -p "#? " selection
            IFS=',' read -r -a selections <<< "$selection"
            for sel in "${selections[@]}"; do
                # Validate selection
                if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le ${#matches[@]} ]; then
                    queue_file "${matches[$sel-1]}"
                else
                    echo "Invalid selection: $sel"
                fi
            done
        fi
    }

    # Queue files based on confirmation requirement
    handle_queueing
fi

# Background any ongoing jobs
disown -a

