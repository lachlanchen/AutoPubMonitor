# AutoPubMonitor System Architecture

This document provides an overview of the AutoPubMonitor system architecture, component interactions, and data flow.

## System Overview

AutoPubMonitor is designed as a pipeline for automated video processing and multi-platform publishing. The system follows these main steps:

1. **File detection** - Monitor directories for new video files
2. **Queuing** - Add detected files to a processing queue
3. **Processing** - Process videos (formatting, transcription, etc.)
4. **Publishing** - Send processed content to multiple platforms
5. **Tracking** - Record processed files to prevent duplication

## Component Interactions

```
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  file_sync_       ├────►│  file_watcher_    ├────►│  queue_file_      │
│  service.sh       │     │  service.sh       │     │  utility.sh       │
│                   │     │                   │     │                   │
└───────────────────┘     └───────────────────┘     └────────┬──────────┘
                                                             │
                                                             ▼
┌───────────────────┐     ┌───────────────────┐     ┌───────────────────┐
│                   │     │                   │     │                   │
│  service_         │     │  process_video_   │◄────┤  queue_manager_   │
│  manager.sh       ├────►│  wrapper.sh       │     │  service.sh       │
│                   │     │                   │     │                   │
└───────────────────┘     └────────┬──────────┘     └───────────────────┘
                                   │
                                   ▼
                          ┌───────────────────┐     ┌───────────────────┐
                          │                   │     │                   │
                          │  video_processor_ ├────►│  video_processing_│
                          │  core.py         │     │  client.py        │
                          │                   │     │                   │
                          └───────────────────┘     └───────────────────┘
```

## Component Descriptions

### File Management
- **file_sync_service.sh**: Syncs files between directories, renaming with timestamps and "_COMPLETED" suffix
- **file_watcher_service.sh**: Uses inotifywait to monitor directories for new files

### Queue Management
- **queue_file_utility.sh**: Utility for manually adding files to the processing queue
- **queue_manager_service.sh**: Service that processes files from the queue one by one

### Processing Pipeline
- **process_video_wrapper.sh**: Sets up environment and executes the processing script
- **video_processor_core.py**: Core processing logic for videos
- **video_processing_client.py**: Client for handling video upload and receiving processed results

### Service Control
- **service_manager.sh**: Controls all services via tmux sessions
- **window_info_utility.py**: Utility for getting window information

## Data Flow

1. **File Detection**:
   - `file_sync_service.sh` syncs files from source to destination
   - `file_watcher_service.sh` detects new files in the watched directory

2. **Queuing**:
   - New files are added to `queue_list.txt`
   - `queue_file_utility.sh` allows manual addition to the queue

3. **Processing**:
   - `queue_manager_service.sh` reads from the queue
   - `process_video_wrapper.sh` sets up the environment
   - `video_processor_core.py` processes the video file

4. **Video Processing**:
   - `video_processing_client.py` handles:
     - Video length checking
     - Video augmentation if needed
     - Upload to processing server
     - Download of processed results

5. **Publishing**:
   - Processed files are sent to configured platforms through API calls
   - Results are stored in the CSV database

## File Tracking

The system uses several files to track processing status:
- `queue_list.txt`: Current processing queue
- `processed.csv`: Record of already processed files
- `videos_db.csv`: Database of all video files
- `checked_list.txt`: Files that have been checked but found invalid

## Configuration

Each component has configuration at the top of its file:
- Directory paths
- Lock file locations
- Command-line parameters
- Publishing platform settings

These should be adjusted according to your specific environment and requirements.

## Service Management

The `service_manager.sh` script manages multiple tmux sessions:
- **video-sync**: For file synchronization
- **monitor-autopub**: For directory monitoring
- **process-queue**: For queue processing
- **transcription-sync**: For syncing transcription data

Use `./service_manager.sh start` to start all services and `./service_manager.sh stop` to stop them.
