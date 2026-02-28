[English](README.md) · [العربية](i18n/README.ar.md) · [Español](i18n/README.es.md) · [Français](i18n/README.fr.md) · [日本語](i18n/README.ja.md) · [한국어](i18n/README.ko.md) · [Tiếng Việt](i18n/README.vi.md) · [中文 (简体)](i18n/README.zh-Hans.md) · [中文（繁體）](i18n/README.zh-Hant.md) · [Deutsch](i18n/README.de.md) · [Русский](i18n/README.ru.md)


<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#prerequisites)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#prerequisites)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#usage)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

An automated system for monitoring, processing, and publishing video content to multiple platforms.

## Overview

AutoPubMonitor is a Linux-oriented automation pipeline for video content processing and multi-platform publishing. The system watches for new video files, processes them through steps including compatibility repair, optional augmentation, transcription/translation-related processing via API, and publishes results to configured platforms.

The runtime is shell-orchestrated (`tmux`, `inotifywait`, `rsync`, `flock`) with Python processing clients and CSV/text state tracking.

## Key Features

| Capability | Details |
|---|---|
| Automated file detection | Watches directories for new video content |
| Processing queue management | Handles videos in a controlled, sequential manner |
| Video processing | Checks length, formats, and prepares videos |
| Multi-platform publishing | Supports XiaoHongShu, Bilibili, Douyin, ShiPinHao, and YouTube |
| Caching system | Optimizes processing by caching results |
| File synchronization | Handles file movement between systems |
| Centralized configuration | All paths and settings in a single config file |
| Easy installation | Single script for setting up the entire system |
| Video compatibility repair | Uses FFmpeg checks and optional HandBrakeCLI fallback |
| Service-oriented operation | `tmux` sessions + optional `systemd` service |

## Repository Structure

```text
autopub-monitor/
├── README.md
├── PROJECT_STRUCTURE.md
├── LICENSE
├── queue_list.txt
├── queue.lock
├── .github/
│   └── FUNDING.yml
├── figs/
│   ├── banner.png|svg
│   ├── logo.png|svg
│   └── logo-w-text.png|svg
├── i18n/
└── autopub_monitor/
    ├── README.md
    ├── autopub.config
    ├── install_autopub_monitor.sh
    ├── autopub_monitor_tmux_session.sh
    ├── monitor_autopublish.sh
    ├── process_queue.sh
    ├── queue_file_utility.sh
    ├── autopub_sync.sh
    ├── autopub.sh
    ├── autopub.py
    ├── process_video.py
    ├── video_utils.py
    ├── handbrake.py
    └── window_info_utility.py
```

## System Components

### Core Processing

| Component | Role |
|---|---|
| `autopub.py` | Main processing engine that handles upload/process/publish orchestration |
| `process_video.py` | Video processing client for upload, processing, and result handling |
| `video_utils.py` / `handbrake.py` | Compatibility checks and repairs before upload |

### Queue Management

| Component | Role |
|---|---|
| `process_queue.sh` | Queue consumer with `flock` locking and retry loop |
| `queue_file_utility.sh` | Manual queue feeder by path or filename pattern |

### Service Management

| Component | Role |
|---|---|
| `autopub_monitor_tmux_session.sh` | Starts/stops multi-pane tmux services |
| `autopub.sh` | Conda/bootstrap wrapper for `autopub.py` |
| `autopub_sync.sh` | File synchronization from Nutstore/Jianguoyun path |
| `monitor_autopublish.sh` | `inotify` watcher for new files and queueing |

### Utilities

| Component | Role |
|---|---|
| `window_info_utility.py` | Active window utility using `xdotool` (optional) |
| `autopub.config` | Central configuration file |
| `install_autopub_monitor.sh` | Installation + systemd setup helper |

## Prerequisites

| Requirement | Notes |
|---|---|
| Linux environment with bash | Primary runtime target |
| Python 3.8+ | Installer currently creates Python 3.8 conda env |
| Miniconda at `${HOME}/miniconda3` | Default expected path in scripts |
| `ffmpeg` / `ffprobe` | Required for video validation/processing |
| `tmux` | Service orchestration |
| `inotify-tools` | File event monitoring (`inotifywait`) |
| `rsync` | Synchronization between directories/systems |
| `python3-pip` | Python package installation |
| Optional: `HandBrakeCLI` | Recommended for repairing problematic videos |
| Optional: `xdotool` | Needed for `window_info_utility.py` |

Python packages used in repo scripts include:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Automatic Installation (scripted)

From repository root:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

The installer:

- Installs apt dependencies (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Creates/uses conda environment `autopub-video`
- Installs Python packages (`requests`, `requests_toolbelt`, `selenium`)
- Creates runtime directories and state files
- Installs and enables `autopub-monitor.service`

### 🧩 Service Enable/Start (if not already enabled by installer)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Manual Setup

1. Review and modify `autopub_monitor/autopub.config` for your environment.
2. Create and activate environment:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Make scripts executable:

```bash
chmod +x autopub_monitor/*.sh
```

## Configuration

Primary configuration file: `autopub_monitor/autopub.config`

Important settings include:

- Data directories: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Sync source directories: `JIANGUOYUN_*`
- State files: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Lock files: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API settings: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda settings: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Notes:

- Default config currently prefers app API mode (`USE_APP_API="true"`) and constructs endpoint URLs from `APP_API_BASE_URL`.
- Legacy endpoints are still present in config for reference.

## Usage

### ▶️ Start Services

From repository root:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

This starts:

- File sync service
- Directory watcher service
- Queue processing service
- Manual command pane
- Transcription rsync session (`am-transcription-sync`)

### ⏹️ Stop Services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Manual Queue Management

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Manual Video Processing

```bash
# Process a specific file using wrapper defaults
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# Direct CLI with specific publish targets
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Caching options + progress visualization
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Upload/process without publishing
python autopub_monitor/autopub.py --no-pub --path "/path/to/video.mp4"
```

## CLI Options (`autopub.py`)

```text
--pub-xhs
--pub-bilibili
--pub-douyin
--pub-shipinhao
--pub-y2b
--no-pub
--test
--use-cache
--use-translation-cache
--use-metadata-cache
--force [pattern_or_csv]
--path /path/to/video
-v, --verbose
```

Behavior note:

- In app API mode (`USE_APP_API=true`), publish defaults to disabled unless publish flags are explicitly passed.

## Processing Architecture

1. **File Detection**: `monitor_autopublish.sh` watches for `close_write`/`moved_to` events.
2. **Queue**: Valid files are appended to `queue_list.txt` using `flock`.
3. **Processing**: `process_queue.sh` consumes queue entries and calls `autopub.sh`.
4. **Upload/Process/Publish**: `autopub.py` and `process_video.py` call configured API endpoints.
5. **Tracking**: Processed files are written to `processed.csv`, discovered files to `videos_db.csv`.

## Practical Examples

### Example 1: End-to-end daemon mode 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Then drop or sync videos into your configured source directory and monitor logs in tmux panes.

### Example 2: Force re-run matching files 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Example 3: Local test without publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Development Notes

- No pinned dependency manifest (`requirements.txt` / `pyproject.toml`) is present at repo root.
- Runtime is strongly tied to Linux shell tools and local path conventions.
- Current scripts source shell config dynamically (`autopub.config`); keep shell-compatible variable expressions.
- Queue and lock semantics rely on `flock`; avoid edits that weaken atomic queue updates.
- API contract details are inferred from client code; server implementation is external to this repository.
- `i18n/` directory exists but language docs are not yet populated in this draft cycle.

## Legacy Name Compatibility (Preserved)

Previous documentation used renamed component labels. Current repository filenames remain as listed below.

| Earlier docs label | Current repository file |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

For convenience, if you `cd autopub_monitor`, these legacy-style command forms from older docs map to:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Troubleshooting

| Symptom | What to check |
|---|---|
| `Miniconda not found at ~/miniconda3` | Install Miniconda or update `CONDA_DIR` in `autopub.config`. |
| `inotifywait: command not found` | Install `inotify-tools`. |
| `ffprobe`/`ffmpeg` failures | Install `ffmpeg`; validate input file integrity. |
| Videos repeatedly not queued | Check `checked_list.txt`, `temp_queue.txt`, and monitor logs from `monitor_autopublish.sh`. |
| Queue stuck or race concerns | Inspect `queue.lock`, `queue_list.txt`, and active processes using `flock`. |
| API upload/process/publish errors | Verify `APP_API_BASE_URL` and endpoint paths in `autopub.config`. |
| tmux service not starting | Confirm `tmux has-session` works and script execute permissions are set. |

## Roadmap

- Add pinned dependency management (`requirements.txt` or `pyproject.toml`).
- Add CI checks for shell/Python linting and basic integration tests.
- Add docs for API contract and deployment assumptions.
- Expand `i18n/` with maintained translated READMEs.
- Improve observability (structured logs and health checks).

## Contributing

Contributions are welcome.

Recommended workflow:

1. Fork and create a feature branch.
2. Keep changes small and focused (script + docs updates together).
3. Validate on a Linux environment with required system tools.
4. Submit a pull request with clear reproduction/test notes.

If behavior changes, update both:

- `README.md`
- `PROJECT_STRUCTURE.md` and/or `autopub_monitor/README.md`

## Support and Sponsor

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

(From `.github/FUNDING.yml`)

## Acknowledgements

- Built around Linux-native tooling (`tmux`, `inotify`, `rsync`, `ffmpeg`) for reliable long-running automation.
- Thanks to contributors and users supporting ongoing improvements.

## License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
