#!/usr/bin/env python3
# process_video.py - Video processing client

import os
import requests
import tempfile
import subprocess
import sys
import shutil
from pathlib import Path
from requests_toolbelt import MultipartEncoder

# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Import config
sys.path.append(SCRIPT_DIR)
try:
    from config import CONFIG
except ImportError:
    print("Error: Cannot import config module.")
    print("Make sure config.py is in the same directory as this script.")
    sys.exit(1)

def get_video_length(filename):
    """Returns the length of the video in seconds or None if unable to determine."""
    try:
        cmd = f"ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"{filename}\""
        output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT)
        video_length = float(output)
        return video_length
    except Exception as e:
        print(f"Warning: Failed to get video length for {filename}. Error: {e}")
        return None

def augment_video(video_path, augmented_length, output_path):
    """
    Repeats the video to ensure it reaches at least the specified minimum length.
    If the video already meets or exceeds the minimum length, no repetition is performed.

    Args:
        video_path (str): Path to the input video.
        augmented_length (int): Minimum desired length of the video in seconds.
        output_path (str): Path to the output augmented video.
    """
    try:
        video_length = get_video_length(video_path)

        if video_length >= augmented_length:
            print(f"No augmentation needed. Video length ({video_length}s) already meets or exceeds the minimum length ({augmented_length}s).")
            if video_path != output_path:
                # Copy the original video to the output path if they are not the same
                shutil.copy(video_path, output_path)
            return output_path

        repeat_count = int(augmented_length / video_length) + (augmented_length % video_length > 0)
        print(f"Repeating the video {repeat_count} times to meet the minimum length requirement.")

        # Generate a temporary file listing for ffmpeg
        concat_file_path = "concat_list.txt"
        with open(concat_file_path, "w") as file:
            for _ in range(repeat_count):
                file.write(f"file '{video_path}'\n")

        # Update ffmpeg command to re-encode audio for MP4 compatibility
        ffmpeg_command = [
            "ffmpeg", '-y', "-f", "concat", "-safe", "0", "-i", concat_file_path,
            "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", output_path
        ]
        print(f"Executing FFmpeg command: {' '.join(ffmpeg_command)}")
        subprocess.run(ffmpeg_command, check=True)

        print(f"Video successfully augmented and saved to {output_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error during video augmentation: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
    finally:
        # Clean up temporary file
        if os.path.exists(concat_file_path):
            os.remove(concat_file_path)

    return output_path

class VideoProcessor:
    def __init__(self, upload_url, process_url, video_path, transcription_path):
        self.upload_url = upload_url
        self.process_url = process_url
        self.video_path = video_path
        self.transcription_path = transcription_path
        os.makedirs(self.transcription_path, exist_ok=True)

        input_file = self.video_path
        # Get minimum video length from config
        augmented_length = CONFIG["min_video_length"]
        threshold_length = augmented_length

        # Attempt to check the video length
        video_length = get_video_length(input_file)
        
        print("video length: ", video_length)

        # Skip augmentation if the video length is greater than augmented_length or if it couldn't be determined
        if video_length is None or video_length > threshold_length:
            if video_length is None:
                print(f"Warning: Could not determine video length for {input_file}. Skipping augmentation.")
            else:
                print(f"Video is longer than {augmented_length} seconds, skipping augmentation.")
        else:
            # Proceed with augmentation if the video is shorter than the augmented_length
            print(f"Video length {video_length} is shorter than {threshold_length}. Augmented to {augmented_length}. ")
            input_file = self.augment_video_if_needed(input_file, augmented_length)

        self.video_path = input_file

    def augment_video_if_needed(self, input_file, augmented_length):
        print("input_file: ", input_file)

        base_name, extension = os.path.splitext(os.path.basename(input_file))
        # Using tempfile to create a temporary directory
        temp_dir = tempfile.mkdtemp()
        augmented_video_path = os.path.join(temp_dir, f"{base_name}_augmented_{augmented_length}s{extension}")

        print("augmented_video_path: ", augmented_video_path)

        # Perform the augmentation
        new_path = augment_video(input_file, augmented_length, augmented_video_path)
        return new_path

    def process_video(self, 
        use_cache=False,
        use_translation_cache=False,
        use_metadata_cache=False
    ):
        video_name = Path(self.video_path).stem
        zip_file_root = os.path.join(self.transcription_path, video_name)
        os.makedirs(zip_file_root, exist_ok=True)
        zip_file_path = os.path.join(zip_file_root, f"{video_name}.zip")

        # Check cache
        if use_cache and os.path.isfile(zip_file_path):
            print(f"Cache hit! Returning the processed file from {zip_file_path}.")
            return zip_file_path
        else:
            if not os.path.isfile(zip_file_path):
                print(f"{zip_file_path} not found. ")
                print("Cache miss. Uploading video for processing.")
            else:
                print("Cache ignored: use_cache=false.")
            
        if not self.upload_url.endswith("stream"):
            with open(self.video_path, 'rb') as f:
                files = {'video': (os.path.basename(self.video_path), f)}
                response = requests.post(
                    self.upload_url, 
                    files=files, 
                    data={'filename': os.path.basename(self.video_path)}
                )
        else:
            # Preprocess the file for streaming upload
            preprocessed_file_path = self.preprocess_for_streaming(self.video_path)
            with open(preprocessed_file_path, 'rb') as f:
                files = {'video': (os.path.basename(preprocessed_file_path), f)}
                response = requests.put(
                    self.upload_url, 
                    files=files, 
                    params={'filename': os.path.basename(preprocessed_file_path)}
                )

        if not response.ok:
            print(f'Failed to upload file. Status code: {response.status_code}, Message: {response.text}')
            return

        # Extract the file path from the response
        uploaded_file_path = response.json().get('file_path')
        if not uploaded_file_path:
            print("Failed to get the uploaded file path from the server response.")
            return

        # Request processing of the uploaded file
        process_response = requests.post(
            self.process_url, 
            data={
                'file_path': uploaded_file_path, 
                "use_translation_cache": use_translation_cache,
                "use_metadata_cache": use_metadata_cache
            }
        )
        if process_response.ok:
            with open(zip_file_path, 'wb') as f:
                f.write(process_response.content)
            print(f'Success! Processed files are downloaded and saved to {zip_file_path}.')
            return zip_file_path
        else:
            print(f'Failed to process file. Status code: {process_response.status_code}, Message: {process_response.text}')
    
    def preprocess_for_streaming(self, file_path):
        output_file_path = os.path.join(os.path.dirname(file_path), 'preprocessed_' + os.path.basename(file_path))
        # Explicitly specify the video and audio codec along with copying the streams and moving the moov atom
        command = f"ffmpeg -y -i \"{file_path}\" -vcodec copy -acodec copy -movflags faststart \"{output_file_path}\""
        try:
            subprocess.run(command, shell=True, check=True)
            print(f"Successfully preprocessed {file_path} to {output_file_path}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to preprocess file with FFmpeg: {e}")
            return file_path  # Return original file path in case of failure
        return output_file_path


if __name__ == "__main__":
    # Usage example
    video_path = os.path.join(os.path.expanduser("~"), 'AutoPublishDATA', 'AutoPublish', 'example.mp4')
    upload_url = CONFIG["upload_url"]
    process_url = CONFIG["process_url"]
    transcription_path = CONFIG["transcription_data_dir"]

    processor = VideoProcessor(upload_url, process_url, video_path, transcription_path)
    processor.process_video(use_cache=True)