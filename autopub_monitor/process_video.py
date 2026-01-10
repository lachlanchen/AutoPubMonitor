#!/usr/bin/env python3
# process_video.py - Video processing utilities for AutoPub Monitor

import os
import requests
from urllib.parse import urlparse
from pathlib import Path
from requests_toolbelt import MultipartEncoder
import subprocess
import tempfile
import shutil
import numpy as np
from tqdm import tqdm
import json

from video_utils import preprocess_if_needed

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
        # Get the length of the input video
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
        
        # Use tqdm to show progress
        process = subprocess.Popen(ffmpeg_command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
        
        # Create progress bar for the augmentation process
        with tqdm(total=100, desc="Augmenting video", unit="%") as pbar:
            for line in process.stdout:
                if 'time=' in line:
                    # Extract progress from ffmpeg output
                    try:
                        time_str = line.split('time=')[1].split()[0]
                        h, m, s = time_str.split(':')
                        current_time = float(h) * 3600 + float(m) * 60 + float(s)
                        progress = min(100, int(100 * current_time / (video_length * repeat_count)))
                        pbar.update(progress - pbar.n)  # Update to current progress
                    except:
                        pass
            
            # Ensure we reach 100% in the progress bar
            pbar.update(100 - pbar.n)
            
        process.wait()
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
    def __init__(
        self,
        upload_url,
        process_url,
        video_path,
        transcription_path,
        preprocess_dir=None,
        use_app_api=False,
        upload_source=None,
    ):
        self.upload_url = upload_url
        self.process_url = process_url
        self.video_path = video_path
        self.transcription_path = transcription_path
        self.preprocess_dir = preprocess_dir
        self.use_app_api = use_app_api
        self.upload_source = upload_source or ("api" if use_app_api else None)
        os.makedirs(self.transcription_path, exist_ok=True)

        input_file = self.video_path

        ## Preprocessing ##
        # input_file = preprocess_if_needed(input_file)
        # Preprocess video if needed (replace the existing preprocess_if_needed call)
        base_name, extension = os.path.splitext(os.path.basename(input_file))
        
        # Use specified temp directory or create one
        if self.preprocess_dir:
            os.makedirs(self.preprocess_dir, exist_ok=True)
            temp_dir = self.preprocess_dir
        else:
            temp_dir = tempfile.mkdtemp(prefix="video_preprocess_")
        
        preprocessed_file = preprocess_if_needed(input_file, temp_dir)
        input_file = preprocessed_file

        ## Augmentation ##
        # Define the minimum length for the video in seconds
        augmented_length = 7  # 7 seconds
        threshold_length = augmented_length

        # Attempt to check the video length
        video_length = get_video_length(input_file)
        
        print("Video length:", video_length)

        # Skip augmentation if the video length is greater than augmented_length or if it couldn't be determined
        if video_length is None or video_length > threshold_length:
            if video_length is None:
                print(f"Warning: Could not determine video length for {input_file}. Skipping augmentation.")
            else:
                print(f"Video is longer than {augmented_length} seconds, skipping augmentation.")
        else:
            # Proceed with augmentation if the video is shorter than the augmented_length
            print(f"Video length {video_length} is shorter than {threshold_length}. Augmenting to {augmented_length}s.")
            input_file = self.augment_video_if_needed(input_file, augmented_length)

       

        self.video_path = input_file

    def augment_video_if_needed(self, input_file, augmented_length):
        print("Input file:", input_file)

        base_name, extension = os.path.splitext(os.path.basename(input_file))
        # Using tempfile to create a temporary directory
        temp_dir = tempfile.mkdtemp()
        augmented_video_path = os.path.join(temp_dir, f"{base_name}_augmented_{augmented_length}s{extension}")

        print("Augmented video path:", augmented_video_path)

        # Perform the augmentation
        new_path = augment_video(input_file, augmented_length, augmented_video_path)
        return new_path

    @staticmethod
    def format_video_url(url, video_id):
        if not url or video_id is None:
            return url
        if "{video_id}" in url:
            return url.replace("{video_id}", str(video_id))
        if "{id}" in url:
            return url.replace("{id}", str(video_id))
        return url

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
                print(f"{zip_file_path} not found.")
                print("Cache miss. Uploading video for processing.")
            else:
                print("Cache ignored: use_cache=false.")
        
        # Upload the video file
        upload_data = {
            "filename": os.path.basename(self.video_path),
            "title": Path(self.video_path).stem,
        }
        if self.upload_source:
            upload_data["source"] = self.upload_source

        if not self.upload_url.endswith("stream"):
            with open(self.video_path, 'rb') as f:
                files = {'video': (os.path.basename(self.video_path), f)}
                response = requests.post(
                    self.upload_url, 
                    files=files, 
                    data=upload_data
                )
        else:
            # Preprocess the file for streaming upload
            preprocessed_file_path = self.preprocess_for_streaming(self.video_path)
            with open(preprocessed_file_path, 'rb') as f:
                files = {'video': (os.path.basename(preprocessed_file_path), f)}
                response = requests.put(
                    self.upload_url, 
                    files=files, 
                    params=upload_data
                )

        if not response.ok:
            print(f'Failed to upload file. Status code: {response.status_code}, Message: {response.text}')
            return

        # Extract the file path from the response
        try:
            upload_payload = response.json()
        except Exception:
            print(f"Failed to parse upload response: {response.text}")
            return

        uploaded_file_path = upload_payload.get('file_path')
        uploaded_video_id = upload_payload.get('video_id')
        if not uploaded_file_path:
            print("Failed to get the uploaded file path from the server response.")
            return

        if self.use_app_api:
            if not uploaded_video_id:
                print("Upload response missing video_id; cannot continue.")
                return

            process_url = self.format_video_url(self.process_url, uploaded_video_id)
            process_payload = {
                "use_translation_cache": use_translation_cache,
                "use_metadata_cache": use_metadata_cache,
            }
            process_response = requests.post(process_url, json=process_payload)
            if not process_response.ok:
                print(f'Failed to process file. Status code: {process_response.status_code}, Message: {process_response.text}')
                return

            try:
                process_payload = process_response.json()
            except Exception:
                process_payload = {"raw": process_response.text}

            return {
                "video_id": uploaded_video_id,
                "file_path": uploaded_file_path,
                "upload": upload_payload,
                "process": process_payload,
            }

        # Request processing of the uploaded file (legacy zip flow)
        process_response = requests.post(
            self.process_url,
            data={
                'file_path': uploaded_file_path,
                "use_translation_cache": use_translation_cache,
                "use_metadata_cache": use_metadata_cache
            }
        )
        
        if process_response.ok:
            # Save the processing results with progress bar
            content_length = int(process_response.headers.get('content-length', 0))
            
            with open(zip_file_path, 'wb') as f, tqdm(
                desc=f"Downloading processed files",
                total=content_length,
                unit='B',
                unit_scale=True,
                unit_divisor=1024,
            ) as pbar:
                for chunk in process_response.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        pbar.update(len(chunk))
            
            print(f'Success! Processed files are downloaded and saved to {zip_file_path}.')
            
            # Save the data alongside the figure/results
            data_file_path = os.path.join(zip_file_root, f"{video_name}_data.json")
            try:
                data = {
                    "processed_date": str(datetime.now()),
                    "video_path": self.video_path,
                    "video_name": video_name,
                    "processing_options": {
                        "use_cache": use_cache,
                        "use_translation_cache": use_translation_cache,
                        "use_metadata_cache": use_metadata_cache
                    }
                }
                with open(data_file_path, 'w') as f:
                    json.dump(data, f, indent=4)
            except:
                print("Unable to save processing data file.")
                
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
    # Set random seed
    np.random.seed(23)
    
    # Example usage
    video_path = '/home/lachlan/AutoPublishDATA/Autopublish/video.mp4'
    server_url = 'http://localhost:8081/video-processing'
    transcription_path = "/home/lachlan/AutoPublishDATA/transcription_data"
    preprocess_dir="/home/lachlan/AutoPublishDATA/PreprocessedVideos" 

    processor = VideoProcessor(
        upload_url='http://localhost:8081/upload',
        process_url=server_url,
        video_path=video_path, 
        transcription_path=transcription_path,
        preprocess_dir=preprocess_dir
    )
    processor.process_video(use_cache=True)
