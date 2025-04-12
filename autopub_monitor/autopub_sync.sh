#!/bin/bash
# autopub_sync.sh - Synchronize files between directories

# Source the config file
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/autopub.config"

echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

echo_with_timestamp "Starting file synchronization between ${JIANGUOYUN_AUTOPUBLISH_DIR} and ${AUTOPUBLISH_DIR}"

while true; do
    # Function to check if the filename contains a date in any recognizable format
    contains_date() {
        if [[ $1 =~ [0-9]{4}-[0-9]{2}-[0-9]{2} ]] || [[ $1 =~ VID_[0-9]{4}[0-9]{2}[0-9]{2}_[0-9]{6} ]] || [[ $1 =~ [0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2} ]]; then
            return 0 # True, contains a date
        else
            return 1 # False, does not contain a date
        fi
    }

    # Check for non-zero file size, then rename files using modification time
    process_file() {
        local src_file=$1
        local file_size=$(stat --format="%s" "$src_file")
        
        if [[ "$file_size" -le 0 ]]; then
            echo_with_timestamp "File size of $src_file is 0, waiting for transfer to complete..."
            sleep 5
        else
            local filename=$(basename "$src_file")
            local extension="${filename##*.}"
            local base="${filename%.*}"
            local suffix="_COMPLETED"
            local mod_time=$(stat --format="%y" "$src_file" | cut -d'.' -f1 | tr ' :-' '_')
            
            # Check if "_COMPLETED" suffix is already present
            if [[ $filename != *"$suffix"* ]]; then
                if contains_date "$filename"; then
                    new_filename="${base}${suffix}.${extension}"
                else
                    new_filename="${base}_${mod_time}${suffix}.${extension}"
                fi
                
                local new_path=$(dirname "$src_file")/"$new_filename"
                mv "$src_file" "$new_path"
                echo_with_timestamp "Renamed $src_file to $new_path"
            fi
        fi
    }

    # Process files ensuring they have a non-zero file size
    find "${JIANGUOYUN_AUTOPUBLISH_DIR}" -type f -size +0c | while read src_file; do
        process_file "$src_file"
    done

    # Perform the rsync operation, including only files with the _COMPLETED suffix
    rsync -rt --progress --delete --whole-file --min-size=1 \
        --include="*_COMPLETED.*" --exclude="*" \
        "${JIANGUOYUN_AUTOPUBLISH_DIR}/" "${AUTOPUBLISH_DIR}/"
    
    # Wait before repeating the operation
    sleep 10
done