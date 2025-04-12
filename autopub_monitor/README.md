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
- **Centralized configuration**: All paths and settings in a single config file
- **Easy installation**: Single script for setting up the entire system

## System Components

### Core Processing
- **autopub.py**: Main processing engine that handles video processing and publishing
- **process_video.py**: Client for video processing operations

### Queue Management
- **process_queue.sh**: Service that manages the processing queue
- **queue_file_utility.sh**: Utility for manually adding files to the queue

### Service Management
- **autopub_monitor_tmux_session.sh**: Controls all services via tmux sessions
- **autopub.sh**: Environment setup and processing execution
- **autopub_sync.sh**: File synchronization between systems
- **monitor_autopublish.sh**: Watches for new files and adds them to queue

### Utilities
- **window_info_utility.py**: Utility to get active window information
- **autopub.config**: Central configuration file
- **install_autopub_monitor.sh**: System installation script

## Installation

### Prerequisites

- Linux environment with bash
- Python 3.6+ with required packages
- FFmpeg for video manipulation
- tmux for service management
- inotify-tools for directory monitoring

### Automatic Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/lachlanchen/AutoPubMonitor.git
   cd AutoPubMonitor
   ```

2. Run the installation script:
   ```bash
   chmod +x install_autopub_monitor.sh
   ./install_autopub_monitor.sh
   ```

3. Enable and start the service:
   ```bash
   sudo systemctl enable autopub-monitor.service
   sudo systemctl start autopub-monitor.service
   ```

### Manual Setup

1. Review and modify `autopub.config` for your environment.

2. Install Python dependencies:
   ```bash
   # Create and activate conda environment
   conda create -n autopub-video python=3.8
   conda activate autopub-video
   pip install requests requests_toolbelt selenium tqdm numpy
   ```

3. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

## Usage

### Starting Services

```bash
./autopub_monitor_tmux_session.sh start
```

This will start:
- Directory monitoring service
- File synchronization service
- Queue processing service
- Transcription sync service

### Stopping Services

```bash
./autopub_monitor_tmux_session.sh stop
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
./autopub.sh "/path/to/video.mp4"

# Process with specific platforms
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Process with caching enabled and progress visualization
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Configuration

The central configuration file `autopub.config` contains all paths and settings used by the system:

- Data directories (source and destination)
- Log locations
- Database files
- Script paths
- Lock files
- Service URLs
- Conda environment settings

Modify this file to adapt the system to your environment.

## Architecture

1. **File Detection**: `monitor_autopublish.sh` watches for new files
2. **Queue**: Files are added to `queue_list.txt`
3. **Processing**: `process_queue.sh` processes files using `autopub.sh`
4. **Publishing**: Processed files are sent to configured platforms
5. **Tracking**: Processed files are logged in CSV files

## License

Apache License 2.0 - See LICENSE file for details.