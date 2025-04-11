#!/usr/bin/env python3
# autopub.py - Video processing and publishing system

import os
import csv
import re
import json
import argparse
import requests
from datetime import datetime
from pathlib import Path
import subprocess
import sys

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Import config
sys.path.append(SCRIPT_DIR)
try:
    from config import CONFIG, init_system
except ImportError:
    print("Error: Cannot import config module.")
    print("Make sure config.py is in the same directory as this script.")
    sys.exit(1)

# Re-initialize system to ensure all directories and files exist
init_system()

# Import local modules
try:
    from process_video import VideoProcessor
    from selenium.webdriver.chrome.service import Service
except ImportError as e:
    print(f"Error importing required modules: {e}")
    print("Make sure all required packages are installed.")
    sys.exit(1)

# Get paths from config
logs_folder_path = CONFIG["logs_dir"]
autopublish_folder_path = CONFIG["auto_publish_dir"]
videos_db_path = CONFIG["videos_db_path"]
processed_path = CONFIG["processed_path"]
transcription_path = CONFIG["transcription_data_dir"]

# Function to read CSV and get a list of filenames
def read_csv(csv_path):
    with open(csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        return [row[0] for row in reader]

# Function to check if a file is listed in a CSV, and if not, add it
def update_csv_if_new(file_path, csv_path):
    existing_files = read_csv(csv_path)
    if file_path not in existing_files:
        with open(csv_path, 'a', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow([file_path])

# Function to process the file, generate zip, and send to lazyingart server
def process_and_publish_file(
    file_path, 
    publish_xhs, publish_bilibili, publish_douyin, publish_shipinhao, publish_y2b, 
    test_mode, 
    use_cache,
    use_translation_cache=False,
    use_metadata_cache=False
):
    upload_url = CONFIG["upload_url"]
    process_url = CONFIG["process_url"]
    publish_url = CONFIG["publish_url"]
    
    # Create an instance of VideoProcessor and process the video
    print("Processing file...")
    processor = VideoProcessor(upload_url, process_url, file_path, transcription_path)
    zip_file_path = processor.process_video(
        use_cache=use_cache,
        use_translation_cache=use_translation_cache,
        use_metadata_cache=use_metadata_cache
    )

    if zip_file_path:
        # Send zip file to lazyingart server for publishing
        with open(zip_file_path, 'rb') as f:
            files = {'file': (os.path.basename(zip_file_path), f)}
            data = {
                'publish_xhs': str(publish_xhs).lower(),
                'publish_bilibili': str(publish_bilibili).lower(),
                'publish_douyin': str(publish_douyin).lower(),
                'publish_shipinhao': str(publish_shipinhao).lower(),
                'publish_y2b': str(publish_y2b).lower(),
                'test': str(test_mode).lower(),
                'filename': os.path.basename(zip_file_path),
            }
            print(f"Publishing {zip_file_path}")
            response = requests.post(publish_url, files=files, data=data)
            print(f"Response: {response.text}")
    else:
        print(f"Failed to process video: {file_path}")

if __name__ == "__main__":
    # Lock file is now relative to script directory
    lock_file_path = os.path.join(SCRIPT_DIR, "autopub.lock")
    bash_script_path = CONFIG["autopub_sh_path"]

    # Check if lock file exists, if not, create it
    if not os.path.exists(lock_file_path):
        open(lock_file_path, 'a').close()

    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--pub-xhs', action='store_true', help="Publish on XiaoHongShu")
    parser.add_argument('--pub-bilibili', action='store_true', help="Publish on Bilibili")
    parser.add_argument('--pub-douyin', action='store_true', help="Publish on DouYin")
    parser.add_argument('--pub-shipinhao', action='store_true', help="Publish on ShiPinHao")
    parser.add_argument('--pub-y2b', action='store_true', help="Publish on YouTube")
    parser.add_argument('--no-pub', action='store_true', help="Don't publish anywhere")
    parser.add_argument('--test', action='store_true', help="Run in test mode")
    parser.add_argument('--use-cache', action='store_true', help="Use cache")
    parser.add_argument('--use-translation-cache', action='store_true', help="Use translation cache")
    parser.add_argument('--use-metadata-cache', action='store_true', help="Use metadata cache")
    parser.add_argument('--force', action='store', type=str, help="Force update the file followed by the --force argument")
    parser.add_argument('--path', action='store', type=str, help="Process only the file at this path")
    args = parser.parse_args()

    # Determine publishing platforms based on provided arguments
    # If none of the publish_xxx flags are provided, default to values in config
    default_platforms = CONFIG["default_publish_platforms"]
    
    if not any([args.pub_xhs, args.pub_bilibili, args.pub_douyin, args.pub_y2b, args.pub_shipinhao]):
        publish_xhs = default_platforms["publish_xhs"]
        publish_bilibili = default_platforms["publish_bilibili"]
        publish_douyin = default_platforms["publish_douyin"]
        publish_shipinhao = default_platforms["publish_shipinhao"]
        publish_y2b = default_platforms["publish_y2b"]
    else:
        publish_xhs = args.pub_xhs
        publish_bilibili = args.pub_bilibili
        publish_douyin = args.pub_douyin
        publish_shipinhao = args.pub_shipinhao
        publish_y2b = args.pub_y2b

    if args.no_pub:
        publish_xhs = False
        publish_bilibili = False
        publish_douyin = False
        publish_shipinhao = False
        publish_y2b = False

    test_mode = args.test
    use_cache = args.use_cache
    force_filename = args.force
    
    if not (force_filename is None):
        force_filename = force_filename.strip()
    else:
        force_filename = ""
    
    force_files = force_filename.split(",")
    use_translation_cache = args.use_translation_cache
    use_metadata_cache = args.use_metadata_cache

    current_datetime = datetime.now()
    log_filename = f"{current_datetime.strftime('%Y-%m-%d %H-%M-%S')}.txt"
    log_file_path = os.path.join(logs_folder_path, log_filename)

    # Define video file pattern based on extensions in config
    extensions = "|".join(CONFIG["video_file_extensions"])
    video_file_pattern = re.compile(rf'.+\.({extensions})$', re.IGNORECASE)
    
    # Single file mode
    if args.path:
        filename = os.path.basename(args.path)
        if video_file_pattern.match(filename):
            processed_files = read_csv(processed_path)
            if filename not in processed_files or force_filename:
                print("process and publish file: ", args.path)
                process_and_publish_file(
                    args.path,
                    publish_xhs=publish_xhs,
                    publish_bilibili=publish_bilibili,
                    publish_douyin=publish_douyin,
                    publish_y2b=publish_y2b,
                    publish_shipinhao=publish_shipinhao,
                    test_mode=test_mode,
                    use_cache=use_cache,
                    use_translation_cache=use_translation_cache,
                    use_metadata_cache=use_metadata_cache
                )
                update_csv_if_new(filename, processed_path)
        else:
            print(f"The file {filename} does not match the video file pattern or has already been processed.")
    else:
        # Check each file in the autopublish folder
        for filename in os.listdir(autopublish_folder_path):
            if filename.startswith("preprocessed"):
                update_csv_if_new(filename, processed_path)
                continue

            if video_file_pattern.match(filename):
                file_path = os.path.join(autopublish_folder_path, filename)
                if os.path.isfile(file_path):
                    # Check and update videos_db.csv
                    update_csv_if_new(filename, videos_db_path)
                    
                    processed_files = read_csv(processed_path)
                    # If not processed, process the file and update processed.csv
                    if ((force_files and any(force_file.strip() in filename for force_file in force_files)) or 
                        (filename and filename in force_files)) or (not force_filename and filename not in processed_files):
                        print("process and publish file: ", file_path)
                        process_and_publish_file(
                            file_path,
                            publish_xhs=publish_xhs,
                            publish_bilibili=publish_bilibili,
                            publish_douyin=publish_douyin,
                            publish_y2b=publish_y2b,
                            publish_shipinhao=publish_shipinhao,
                            test_mode=test_mode,
                            use_cache=use_cache,
                            use_translation_cache=use_translation_cache,
                            use_metadata_cache=use_metadata_cache
                        )
                        update_csv_if_new(filename, processed_path)

    # After all tasks are done, remove the lock file
    if os.path.exists(lock_file_path):
        os.remove(lock_file_path)