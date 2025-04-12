#!/bin/bash
# monitor_autopublish.sh - Watch for new files in the AutoPublish directory

# Source the config file
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/autopub.config"

echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

echo_with_timestamp "Watching directory: $AUTOPUBLISH_DIR for new files or files moved here."
touch "${QUEUE_LIST}"
touch "${TEMP_QUEUE}"
touch "${CHECKED_LIST}"
touch "${QUEUE_LOCK}"

check_and_queue_file() {
    local full_path=$1

    # Check if file has been checked and found invalid before
    if grep -Fxq "$full_path" "${CHECKED_LIST}"; then
        echo_with_timestamp "File $full_path has been checked and is invalid. Skipping."
        return
    fi

    local file_size=$(stat -c %s "$full_path")

    if [ "$file_size" -eq 0 ] || ! ffprobe -v error -show_entries format=filename -of default=noprint_wrappers=1:nokey=1 "$full_path" > /dev/null; then
        sleep 3 # Wait before moving to TEMP_QUEUE
        handle_potential_conflict_file "$full_path"
    else
        queue_file "$full_path"
    fi
}

queue_file() {
    local file_path=$1
    local sleep_time=$(( RANDOM % 30 + 1 ))  # Random sleep between 1 and 30 seconds
    sleep $sleep_time
    echo_with_timestamp "File $file_path passed checks after a random sleep of $sleep_time seconds. Adding to queue."

    # Lock the queue list, write the file path, and unlock
    (
        flock -x 200
        echo "$file_path" >> "$QUEUE_LIST"
    ) 200>"$QUEUE_LOCK"
}

handle_potential_conflict_file() {
    local original_file_path=$1
    local directory=$(dirname -- "$original_file_path")
    local base_name=$(basename -- "$original_file_path")
    local name_without_ext="${base_name%.*}"
    local prefix=$(echo "$name_without_ext" | sed -E 's/_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}$//')

    # Search for conflict files, considering variable timestamp and NSConflict marker
    for file in "$directory"/*; do
        if [[ "$file" =~ ${prefix}-NSConflict-.* ]] && ffprobe -v error -show_entries format=filename -of default=noprint_wrappers=1:nokey=1 "$file" > /dev/null; then
            echo_with_timestamp "Valid conflict version found: $file. Original file $original_file_path will be skipped from further processing."
            # Mark original file as checked (invalid)
            echo "$original_file_path" >> "${CHECKED_LIST}"
            return
        fi
    done

    # No valid conflict found, and original file is invalid, move it to TEMP_QUEUE
    echo_with_timestamp "No valid conflict found. Original file $original_file_path is invalid. Moving to TEMP_QUEUE."
    echo "$original_file_path" >> "$TEMP_QUEUE"
}

monitor_temp_queue() {
    while true; do
        if [ ! -s "$TEMP_QUEUE" ]; then
            sleep 5
            continue
        fi

        cp "$TEMP_QUEUE" "${TEMP_QUEUE}_copy"
        > "$TEMP_QUEUE"

        while IFS= read -r line; do
            if [ -f "$line" ]; then
                check_and_queue_file "$line"
            fi
        done < "${TEMP_QUEUE}_copy"
        rm "${TEMP_QUEUE}_copy"
    done
}

monitor_temp_queue &

inotifywait -m -e close_write -e moved_to "$AUTOPUBLISH_DIR" |
while read -r directory events filename; do
    if [[ "$filename" =~ ^\..*\..*\..*$ ]]; then
        echo_with_timestamp "Skipping temporary or system file: $filename"
        continue
    fi

    full_path="${directory}${filename}"
    echo_with_timestamp "Significant change detected: $full_path"
    check_and_queue_file "$full_path"
done