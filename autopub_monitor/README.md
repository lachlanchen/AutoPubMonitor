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
- **Centralized configuration**: Single point of configuration for all components

## Installation

### Prerequisites

- Linux environment with bash
- Python 3.6+ with required packages
- FFmpeg for video manipulation
- tmux for service management
- inotify-tools for directory monitoring

### Quick Install

```bash
# Clone the repository
git clone https://github.com/yourusername/autopub-monitor.git
cd autopub-monitor

# Install the system (requires sudo)
sudo ./install_autopub_monitor.sh
```

### Manual Setup

If you prefer to set up manually:

1. Install required packages:
   ```bash
   sudo apt-get update
   sudo apt-get install tmux inotify-tools ffmpeg python3 python3-pip rsync
   ```

2. Install Python dependencies:
   ```bash
   pip3 install requests requests-toolbelt selenium
   ```

3. Create the necessary directories and files:
   ```bash
   ./setup_config.sh --initialize
   ```

4. Make scripts executable:
   ```bash
   chmod +x *.sh
   ```

5. Start the services:
   ```bash
   ./autopub_monitor_tmux_session.sh start
   ```

## Configuration

All configuration is centralized in `config.py`. The system exports these settings to a bash script (`autopub_config.sh`) for use by shell scripts.

Key configuration options:

- **Data directories**: Where videos and processed files are stored
- **Server URLs**: URLs for processing and publishing services
- **Publishing platforms**: Which platforms to publish to by default
- **Video settings**: Minimum video length, allowed file extensions

To modify configuration:

1. Edit `config.py` directly
2. Run `./setup_config.sh --export` to update the bash config

## Usage

### Managing Services

```bash
# Start all services
./autopub_monitor_tmux_session.sh start

# Stop all services
./autopub_monitor_tmux_session.sh stop

# Check service status
./autopub_monitor_tmux_session.sh status
```

### Processing Videos Manually

To process a specific video file:

```bash
# Process by path
./requeue.sh /path/to/video.mp4

# Process by filename pattern
./requeue.sh partial_filename

# Process with auto-confirmation
./requeue.sh -y pattern
```

### Monitoring Services

```bash
# View a specific service's output
tmux attach -t video-sync
tmux attach -t monitor-autopub
tmux attach -t process-queue
tmux attach -t transcription-sync
```

## System Architecture

The system consists of several components that work together:

1. **File Synchronization** (`autopub_sync.sh`): Monitors a source directory and syncs files to a destination
2. **File Monitoring** (`monitor_autopublish.sh`): Watches for new files and adds them to the processing queue
3. **Queue Processing** (`process_queue.sh`): Takes files from the queue and processes them
4. **Video Processing** (`autopub.py` and `process_video.py`): Processes videos and publishes them
5. **Service Management** (`autopub_monitor_tmux_session.sh`): Manages all the services

## File Flow

1. Files are detected in the source directory
2. Valid video files are renamed with a timestamp and synced to the processing directory
3. The monitoring service detects new files and adds them to the queue
4. The queue processor takes files one by one and processes them
5. The video processor prepares videos and publishes them to configured platforms
6. Processed files are tracked in CSV files to prevent duplicate processing

## Logging

Logs are stored in:
- `logs/`: General system logs
- `logs-autopub/`: Processing logs

## Troubleshooting

If services aren't running properly:
1. Check service status: `./autopub_monitor_tmux_session.sh status`
2. Check logs in the `logs/` and `logs-autopub/` directories
3. Ensure all required dependencies are installed
4. Verify configuration in `config.py` and `autopub_config.sh`

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.