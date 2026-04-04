[English](README.md) · [العربية](i18n/README.ar.md) · [Español](i18n/README.es.md) · [Français](i18n/README.fr.md) · [日本語](i18n/README.ja.md) · [한국어](i18n/README.ko.md) · [Tiếng Việt](i18n/README.vi.md) · [中文 (简体)](i18n/README.zh-Hans.md) · [中文（繁體）](i18n/README.zh-Hant.md) · [Deutsch](i18n/README.de.md) · [Русский](i18n/README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#prerequisites)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#prerequisites)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#usage)
[![Monitors](https://img.shields.io/badge/monitoring-inotifywait-0ea5e9)](#usage)
[![Queueing](https://img.shields.io/badge/queue-flock-16a34a)](#system-components)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)
[![Activity](https://img.shields.io/github/last-commit/lachlanchen/AutoPubMonitor?style=flat-square&label=last%20commit&color=1d76db)](https://github.com/lachlanchen/AutoPubMonitor/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/lachlanchen/AutoPubMonitor?style=flat-square&color=0366d6)](https://github.com/lachlanchen/AutoPubMonitor)
[![Issues](https://img.shields.io/github/issues/lachlanchen/AutoPubMonitor?style=flat-square)](https://github.com/lachlanchen/AutoPubMonitor/issues)
[![Contributors](https://img.shields.io/github/contributors/lachlanchen/AutoPubMonitor?style=flat-square)](https://github.com/lachlanchen/AutoPubMonitor/graphs/contributors)

> Automated system for monitoring, processing, and publishing video content to multiple platforms.

| What to expect | Detail |
|---|---|
| Runtime model | Linux-first automation with `tmux`, optional `systemd`, and queue locks |
| Queue design | File watcher → queue -> worker loop, with persistent state tracking |
| Extensibility | Shell orchestration + Python publish clients for platform adapters |
| Core entry points | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Documentation Map

| Section | Why it matters |
|---|---|
| [Project at a Glance](#project-at-a-glance) | Quickly understand runtime model and goals |
| [Installation](#installation) | Get from clone to running service |
| [Configuration](#configuration) | Know every important script-level toggle |
| [Usage](#usage) | Start, stop, queue, and process workflows |
| [System Components](#system-components) | Identify shell and Python responsibilities |
| [Troubleshooting](#troubleshooting) | Resolve startup and queueing issues fast |
| [Roadmap](#roadmap) | Track near-term platform and tooling plans |
| [Contributing](#contributing) | Understand safe contribution patterns |

## 🧭 Quick Start at a Glance

| Goal | Command | Notes |
|---|---|---|
| Start monitoring pipeline | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Starts watcher + queue + sync + manual pane |
| Stop all services | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Clean shutdown and pane cleanup |
| Queue by pattern | `./autopub_monitor/queue_file_utility.sh "pattern"` | Add matching files to processing queue |
| Process one file | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Uses default publish and processing config |

## 🎯 Project at a Glance

| Focus | Details |
|---|---|
| Runtime target | Linux, with `tmux` orchestration and optional `systemd` |
| Queue model | File watcher → queue → worker scripts → publish pipeline |
| Core entry points | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| State tracking | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Overview

AutoPubMonitor is a Linux-oriented automation pipeline for video content processing and multi-platform publishing. The system watches for new video files, processes them through steps including compatibility repair, optional augmentation, transcription/translation-related processing via API, and publishes results to configured platforms.

The runtime is shell-orchestrated (`tmux`, `inotifywait`, `rsync`, `flock`) with Python processing clients and CSV/text-based state tracking.

## ⚡ Key Features

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
| International docs | Root language links and `i18n/` translations |

## 🗂️ Repository Structure

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
| `autopub_sync.sh` | File synchronization from remote/synced source directories |
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
- Installs a mount-aware `autopub-monitor.service` that waits for `/home/${USER}`, `/home/${USER}/DiskMech`, and `/home/${USER}/AutoPublishDATA`
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

> Assumption: repository runtime state files (for example `queue.lock`, `temp_queue.txt`, `checked_list.txt`) should either already exist or be created by your startup/install flow.

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
- Queue and lock filenames can be changed with minimal risk if all scripts reference the same config entries.

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
- Transcription rsync session (`transcription-sync`)

Operational notes:

- The manual pane is intentionally staged only. It prepares the `autopub.py --force`
  command and waits for Enter.
- The `transcription-sync` session is also intentionally staged only. Its rsync
  loop is typed into the shell and waits for Enter.
- `autopub.config` currently selects the Conda env `autopub-video`.
- Queue temp files already use `/dev/shm`, so queue/lock handling is not the
  main disk writer. The steady filesystem churn comes mostly from
  `autopub_sync.sh`'s `find` + `rsync` loop and repeated log appends.
- Startup race note: `autopub_sync.sh` can copy a `*_COMPLETED` file into
  `AUTOPUBLISH_DIR` before `monitor_autopublish.sh` has finished establishing
  its `inotifywait` watch. In that case, the file is present locally but no
  queue event is recorded, because the watcher only reacts to future
  `close_write` and `moved_to` events and does not do an initial scan of
  already-existing files.
- Practical consequence: if a file appears during service startup and is missed,
  renaming or recopying it after the watcher is live will trigger queueing and
  processing.

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

## 🎛️ Command Palette

| Area | Examples |
|---|---|
| Service controls | `autopub_monitor_tmux_session.sh start/stop` |
| Queue operations | `queue_file_utility.sh`, `process_queue.sh` |
| File sync/process | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python execution path | `autopub.py`, `process_video.py`, `video_utils.py` |

## Processing Architecture

1. **File Detection**: `monitor_autopublish.sh` watches for `close_write`/`moved_to` events.
2. **Queueing**: Valid files are appended to `queue_list.txt` using `flock`.
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

## 🧠 Development Notes

- No pinned dependency manifest (`requirements.txt` / `pyproject.toml`) is present at repo root.
- Runtime is strongly tied to Linux shell tools and local path conventions.
- Current scripts source shell config dynamically (`autopub.config`); keep shell-compatible variable expressions.
- Queue and lock semantics rely on `flock`; avoid edits that weaken atomic queue updates.
- API contract details are inferred from client code; server implementation is external to this repository.
- `i18n/` directory exists but translation docs are not fully maintained in this draft cycle.
- Processed artifact files (`queue_list.txt`, `temp_queue.txt`, etc.) are typically generated/managed at runtime and may vary by environment.

## 🧱 Legacy Name Compatibility (Preserved)

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

## 🛠️ Troubleshooting

| Symptom | What to check |
|---|---|
| `Miniconda not found at ~/miniconda3` | Install Miniconda or update `CONDA_DIR` in `autopub.config`. |
| `inotifywait: command not found` | Install `inotify-tools`. |
| `ffprobe`/`ffmpeg` failures | Install `ffmpeg`; validate input file integrity. |
| Videos repeatedly not queued | Check `checked_list.txt`, `temp_queue.txt`, and monitor logs from `monitor_autopublish.sh`. |
| Queue stuck or race concerns | Inspect `queue.lock`, `queue_list.txt`, and active processes using `flock`. |
| API upload/process/publish errors | Verify `APP_API_BASE_URL` and endpoint paths in `autopub.config`. |
| tmux service not starting | Confirm `tmux has-session` works and script execute permissions are set. |

## 🗺️ Roadmap

- Add pinned dependency management (`requirements.txt` or `pyproject.toml`).
- Add CI checks for shell/Python linting and basic integration tests.
- Add docs for API contract and deployment assumptions.
- Expand `i18n/` with maintained translated READMEs.
- Improve observability (structured logs and health checks).

## 🤝 Contributing

Contributions are welcome.

Recommended workflow:

1. Fork and create a feature branch.
2. Keep changes small and focused (script + docs updates together).
3. Validate on a Linux environment with required system tools.
4. Submit a pull request with clear reproduction/test notes.

If behavior changes, update both:

- `README.md`
- `PROJECT_STRUCTURE.md` and/or `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Contact

For questions, bug reports, and feature requests:

- Open an issue at [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 Acknowledgements

- Built around Linux-native tooling (`tmux`, `inotify`, `rsync`, `ffmpeg`) for reliable long-running automation.
- Thanks to contributors and users supporting ongoing improvements.

## 📄 License

Apache License 2.0 - See [LICENSE](LICENSE) for details.
