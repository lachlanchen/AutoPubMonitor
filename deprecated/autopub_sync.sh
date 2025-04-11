#!/bin/bash

src="/home/lachlan/jianguoyun/AutoPublishDATA/AutoPublish/"
dst="/home/lachlan/AutoPublishDATA/AutoPublish/"

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
            echo "File size of $src_file is 0, waiting for transfer to complete..."
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
                echo "Renamed $src_file to $new_path"
            else
                # echo "$filename already has the $suffix suffix."
                :
            fi
        fi
    }

    # Process files ensuring they have a non-zero file size
    find "$src" -type f -size +0c | while read src_file; do
        process_file "$src_file"
    done

    # Perform the rsync operation, including only files with the _COMPLETED suffix
    rsync -rt --progress --delete --whole-file --min-size=1 --include="*_COMPLETED.*" --exclude="*" "$src" "$dst"
    
    # Wait before repeating the operation
    sleep 10
done
