#!/usr/bin/env python3
# autopub.py - Main processing script for AutoPub Monitor

import os
import csv
import re
import json
import argparse
import requests
from datetime import datetime
from pathlib import Path
from process_video import VideoProcessor
from selenium.webdriver.chrome.service import Service
import subprocess
from tqdm import tqdm

# Read configuration file
config_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'autopub.config')

# Initialize paths with defaults
script_dir = os.path.dirname(os.path.abspath(__file__))
logs_folder_path = os.path.join(script_dir, 'logs')
autopublish_folder_path = os.path.expanduser('~/AutoPublishDATA/AutoPublish')
videos_db_path = os.path.join(script_dir, 'videos_db.csv')
processed_path = os.path.join(script_dir, 'processed.csv')
transcription_path = os.path.expanduser('~/AutoPublishDATA/transcription_data')
lock_file_path = os.path.join(script_dir, 'autopub.lock')
bash_script_path = os.path.join(script_dir, 'autopub.sh')
upload_url = 'http://localhost:8081/upload'
process_url = 'http://localhost:8081/video-processing'
publish_url = 'http://lazyingart:8081/publish'

# Parse the bash-style config file using subprocess to evaluate shell expressions
try:
    # Create a temporary shell script that will output the evaluated values
    temp_script_path = os.path.join(os.path.dirname(config_path), '.temp_config_eval.sh')
    with open(temp_script_path, 'w') as temp_script:
        temp_script.write('#!/bin/bash\n')
        temp_script.write(f'source {config_path}\n')
        temp_script.write('echo "LOGS_DIR=$LOGS_DIR"\n')
        temp_script.write('echo "AUTOPUBLISH_DIR=$AUTOPUBLISH_DIR"\n')
        temp_script.write('echo "VIDEOS_DB_PATH=$VIDEOS_DB_PATH"\n')
        temp_script.write('echo "PROCESSED_PATH=$PROCESSED_PATH"\n')
        temp_script.write('echo "TRANSCRIPTION_DIR=$TRANSCRIPTION_DIR"\n')
        temp_script.write('echo "AUTOPUB_LOCK=$AUTOPUB_LOCK"\n')
        temp_script.write('echo "AUTOPUB_SH=$AUTOPUB_SH"\n')
        temp_script.write('echo "UPLOAD_URL=$UPLOAD_URL"\n')
        temp_script.write('echo "PROCESS_URL=$PROCESS_URL"\n')
        temp_script.write('echo "PUBLISH_URL=$PUBLISH_URL"\n')
    
    # Make the script executable
    os.chmod(temp_script_path, 0o755)
    
    # Execute the shell script and capture its output
    result = subprocess.run([temp_script_path], capture_output=True, text=True, check=True)
    
    # Clean up the temporary script
    os.remove(temp_script_path)
    
    # Parse the output to get the evaluated variables
    config_vars = {}
    for line in result.stdout.splitlines():
        if '=' in line:
            key, value = line.split('=', 1)
            config_vars[key] = value
    
    # Update the relevant path variables
    if 'LOGS_DIR' in config_vars:
        logs_folder_path = config_vars['LOGS_DIR']
    if 'AUTOPUBLISH_DIR' in config_vars:
        autopublish_folder_path = config_vars['AUTOPUBLISH_DIR']
    if 'VIDEOS_DB_PATH' in config_vars:
        videos_db_path = config_vars['VIDEOS_DB_PATH']
    if 'PROCESSED_PATH' in config_vars:
        processed_path = config_vars['PROCESSED_PATH']
    if 'TRANSCRIPTION_DIR' in config_vars:
        transcription_path = config_vars['TRANSCRIPTION_DIR']
    if 'AUTOPUB_LOCK' in config_vars:
        lock_file_path = config_vars['AUTOPUB_LOCK']
    if 'AUTOPUB_SH' in config_vars:
        bash_script_path = config_vars['AUTOPUB_SH']
    if 'UPLOAD_URL' in config_vars:
        upload_url = config_vars['UPLOAD_URL']
    if 'PROCESS_URL' in config_vars:
        process_url = config_vars['PROCESS_URL']
    if 'PUBLISH_URL' in config_vars:
        publish_url = config_vars['PUBLISH_URL']
except Exception as e:
    print(f"Warning: Error reading config file: {e}. Using default paths.")

# Ensure the logs, videos, and database files exist
os.makedirs(logs_folder_path, exist_ok=True)
print("logs_folder_path: ", logs_folder_path)
os.makedirs(autopublish_folder_path, exist_ok=True)
print("autopublish_folder_path: ", autopublish_folder_path)
os.makedirs(transcription_path, exist_ok=True)
print("transcription_path: ", transcription_path)
open(videos_db_path, 'a').close()
open(processed_path, 'a').close()

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

def visualize_progress(total_files):
    """Visualize the processing progress."""
    return tqdm(total=total_files, desc="Processing videos", unit="file")

if __name__ == "__main__":
    # Set random seed for reproducibility
    import random
    import numpy as np
    random.seed(23)
    np.random.seed(23)

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
    parser.add_argument('--no-pub', action='store_true', help="Don't publish to any platform")
    parser.add_argument('--test', action='store_true', help="Run in test mode")
    parser.add_argument('--use-cache', action='store_true', help="Use cache")
    parser.add_argument('--use-translation-cache', action='store_true', help="Use translation cache")
    parser.add_argument('--use-metadata-cache', action='store_true', help="Use metadata cache")
    parser.add_argument('--force', action='store', type=str, help="Force update the file followed by the --force argument")
    parser.add_argument('--path', action='store', type=str, help="Process only the file at this path")
    parser.add_argument('-v', '--verbose', action='store_true', help="Show progress bar")
    args = parser.parse_args()

    # Determine publishing platforms based on provided arguments
    # If none of the publish_xxx flags are provided, default to publishing on all platforms
    if not any([args.pub_xhs, args.pub_bilibili, args.pub_douyin, args.pub_y2b, args.pub_shipinhao]):
        publish_xhs = publish_bilibili = publish_douyin = publish_y2b = publish_shipinhao = True
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

    # Define video file pattern
    video_file_pattern = re.compile(r'.+\.(mp4|mov|avi|flv|wmv|mkv)$', re.IGNORECASE)
    
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
        # Get list of video files to process
        files_to_process = []
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
                    if ((force_files and any(force_file.strip() in filename for force_file in force_files)) or 
                       (filename and filename in force_files)) or (not force_filename and filename not in processed_files):
                        files_to_process.append(file_path)

        # Process files with progress visualization if verbose
        if args.verbose and files_to_process:
            progress_bar = visualize_progress(len(files_to_process))
            for file_path in files_to_process:
                filename = os.path.basename(file_path)
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
                progress_bar.update(1)
            progress_bar.close()
        else:
            for file_path in files_to_process:
                filename = os.path.basename(file_path)
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