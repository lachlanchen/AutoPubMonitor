#!/bin/bash
# queue_file_utility.sh - Utility for manually adding files to the processing queue

# Source the config file
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/autopub.config"

echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Define video file pattern
VIDEO_PATTERN=".*\.(mp4|mov|avi|flv|wmv|mkv)$"

# Initialize variables
AUTO_CONFIRM=false
PATTERN=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        *)
            PATTERN="$1"
            shift
            ;;
    esac
done

if [ -z "$PATTERN" ]; then
    echo "Usage: $0 [-y|--yes] <pattern_or_filepath>"
    echo "  -y, --yes    Auto-confirm file selection (no prompt)"
    echo "  pattern      Search pattern or full filepath"
    exit 1
fi

# Function to add a file to the queue
add_to_queue() {
    local file_path="$1"
    
    echo_with_timestamp "Adding to queue: $file_path"
    
    {
        flock -x 200
        echo "$file_path" >> "$QUEUE_LIST"
        echo_with_timestamp "Successfully added to queue: $file_path"
    } 200>"$QUEUE_LOCK"
}

# Check if the pattern is a full file path
if [ -f "$PATTERN" ]; then
    # It's a direct file path
    add_to_queue "$PATTERN"
else
    # It's a pattern, search for matching files in the AutoPublish directory
    MATCHING_FILES=()
    
    while IFS= read -r -d $'\0' file; do
        MATCHING_FILES+=("$file")
    done < <(find "$AUTOPUBLISH_DIR" -type f -regex "$VIDEO_PATTERN" -name "*${PATTERN}*" -print0)
    
    # No matching files found
    if [ ${#MATCHING_FILES[@]} -eq 0 ]; then
        echo_with_timestamp "No matching files found for pattern: $PATTERN"
        exit 1
    fi
    
    # Only one file found, add it directly if auto-confirm is true
    if [ ${#MATCHING_FILES[@]} -eq 1 ] && [ "$AUTO_CONFIRM" = true ]; then
        add_to_queue "${MATCHING_FILES[0]}"
        exit 0
    fi
    
    # Multiple files found, let the user select
    echo "Found ${#MATCHING_FILES[@]} matching files:"
    for i in "${!MATCHING_FILES[@]}"; do
        echo "$((i+1)). $(basename "${MATCHING_FILES[$i]}")"
    done
    
    if [ "$AUTO_CONFIRM" = true ]; then
        # Add all files if auto-confirm is true
        for file in "${MATCHING_FILES[@]}"; do
            add_to_queue "$file"
        done
    else
        # Prompt the user to select files
        echo "Enter the numbers of files to add (comma-separated), 'a' for all, or 'q' to quit:"
        read -r selection
        
        if [ "$selection" = "q" ]; then
            echo "Exiting without adding files."
            exit 0
        elif [ "$selection" = "a" ]; then
            for file in "${MATCHING_FILES[@]}"; do
                add_to_queue "$file"
            done
        else
            # Process comma-separated selection
            IFS=',' read -ra SELECTED <<< "$selection"
            for num in "${SELECTED[@]}"; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#MATCHING_FILES[@]}" ]; then
                    add_to_queue "${MATCHING_FILES[$((num-1))]}"
                else
                    echo "Invalid selection: $num"
                fi
            done
        fi
    fi
fi

echo_with_timestamp "Queue operation completed."