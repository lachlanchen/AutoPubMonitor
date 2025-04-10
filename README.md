# AutoPubMonitor

An automated system for monitoring, processing, and publishing video content to multiple platforms.

## System Overview

AutoPubMonitor is a comprehensive pipeline for video content processing and multi-platform publishing. The system watches for new video files, processes them through a series of steps including transcription and translation, and publishes the results to configured platforms.

### Key Features

- **Automated file detection**: Watches directories for new video content
- **Processing queue management**: Handles videos in a controlled, sequential manner
- **Video processing**: Checks length, formats, and prepares videos
- **Multi-platform publishing**: Supports XiaoHongShu, Bilibili, Douyin, ShiPinHao, and YouTube
- **Caching system**: Optimizes processing by caching results
- **File synchronization**: Handles file movement between systems

## System Components

### Core Processing
- **video_processor_core.py** (formerly autopub.py): Main processing engine that handles video processing and publishing
- **video_processing_client.py** (formerly process_video.py): Client for video processing operations

### Queue Management
- **queue_manager_service.sh** (formerly process_queue.sh): Service that manages the processing queue
- **queue_file_utility.sh** (formerly requeue.sh): Utility for manually adding files to the queue

### Service Management
- **service_manager.sh** (formerly autopub_monitor_tmux_session.sh): Controls all services via tmux sessions
- **process_video_wrapper.sh** (formerly autopub.sh): Environment setup and processing execution
- **file_sync_service.sh** (formerly autopub_sync.sh): File synchronization between systems
- **file_watcher_service.sh** (formerly monitor_autopublish.sh): Watches for new files and adds them to queue

### Utilities
- **window_info_utility.py** (formerly test_xdo.py): Utility to get active window information

## Installation

### Prerequisites

- Linux environment with bash
- Python 3.6+ with required packages
- FFmpeg for video manipulation
- tmux for service management
- inotify-tools for directory monitoring

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/lachlanchen/AutoPubMonitor.git
   cd AutoPubMonitor
   ```

2. Install Python dependencies:
   ```bash
   # Create and activate conda environment
   conda create -n autopub-video python=3.8
   conda activate autopub-video
   pip install requests requests_toolbelt selenium
   ```

3. Configure directory paths in the scripts according to your environment.

## Usage

### Starting Services

```bash
./service_manager.sh start
```

This will start:
- Directory monitoring service
- File synchronization service
- Queue processing service
- Transcription sync service

### Stopping Services

```bash
./service_manager.sh stop
```

### Manual Queue Management

To manually add files to the processing queue:

```bash
# Add by pattern match
./queue_file_utility.sh "pattern_to_match"

# Add by full path
./queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./queue_file_utility.sh -y "pattern_to_match"
```

### Manual Video Processing

```bash
# Process a specific file
./process_video_wrapper.sh "/path/to/video.mp4"

# Process with specific platforms
python video_processor_core.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Process with caching enabled
python video_processor_core.py --use-cache --use-translation-cache --path "/path/to/video.mp4"
```

## Configuration

- Adjust directory paths in each script according to your setup
- Modify script behavior through command-line arguments
- Platform targets can be configured in `video_processor_core.py`

## Architecture

1. **File Detection**: `file_watcher_service.sh` watches for new files
2. **Queue**: Files are added to `queue_list.txt`
3. **Processing**: `queue_manager_service.sh` processes files using `process_video_wrapper.sh`
4. **Publishing**: Processed files are sent to configured platforms
5. **Tracking**: Processed files are logged in CSV files

## License

Apache License 2.0 - See LICENSE file for details.