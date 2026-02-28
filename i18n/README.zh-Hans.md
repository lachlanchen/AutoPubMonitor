[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


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

> 用于监控、处理并将视频内容发布到多个平台的自动化系统。

| What to expect | Detail |
|---|---|
| 运行模型 | Linux-first 的自动化流程，使用 `tmux`、可选 `systemd`，并通过队列锁进行串行控制 |
| 队列设计 | 文件监视器 → 队列 → worker 循环，具备持久化状态追踪 |
| 可扩展性 | Shell 编排 + Python 发布客户端，支持平台适配器扩展 |
| 核心入口 | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Documentation Map

| Section | Why it matters |
|---|---|
| [Project at a Glance](#project-at-a-glance) | 快速理解运行模型与目标 |
| [Installation](#installation) | 从克隆到服务运行 |
| [Configuration](#configuration) | 了解每个关键脚本级配置项 |
| [Usage](#usage) | 启停、入队与处理流程 |
| [System Components](#system-components) | 区分 shell 与 Python 的职责 |
| [Troubleshooting](#troubleshooting) | 快速定位启动与队列问题 |
| [Roadmap](#roadmap) | 查看近期平台与工具规划 |
| [Contributing](#contributing) | 掌握安全的贡献方式 |

## 🧭 Quick Start at a Glance

| Goal | Command | Notes |
|---|---|---|
| Start monitoring pipeline | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | 启动 watcher + 队列 + 同步 + manual pane |
| Stop all services | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | 优雅停机并清理面板 |
| Queue by pattern | `./autopub_monitor/queue_file_utility.sh "pattern"` | 将匹配文件加入处理队列 |
| Process one file | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | 使用默认发布和处理配置 |

## 🎯 Project at a Glance

| Focus | Details |
|---|---|
| Runtime target | Linux, with `tmux` orchestration and optional `systemd` |
| 队列模型 | 文件监视器 → 队列 → worker 脚本 → 发布流水线 |
| 核心入口 | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| 状态追踪 | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Overview

AutoPubMonitor 是一个面向 Linux 的视频内容处理与多平台发布自动化流水线。系统监听新的视频文件，通过兼容性修复、可选增强、API 驱动的转录/翻译相关处理等步骤，并将结果发布到已配置的平台。

运行时由 shell 协调（`tmux`, `inotifywait`, `rsync`, `flock`）驱动，并结合 Python 处理客户端与基于 CSV/文本的状态追踪。

## ⚡ Key Features

| Capability | Details |
|---|---|
| 自动文件检测 | 监听目录中新出现的视频内容 |
| 处理队列管理 | 以可控、顺序化方式处理视频 |
| 视频处理 | 检查时长与格式，并预处理视频 |
| 多平台发布 | 支持 XiaoHongShu、Bilibili、Douyin、ShiPinHao 和 YouTube |
| 缓存系统 | 通过缓存结果优化处理效率 |
| 文件同步 | 处理不同系统/目录间的文件迁移 |
| 集中化配置 | 全部路径与设置放在单一配置文件 |
| 简易安装 | 单脚本完成整套系统安装 |
| 视频兼容修复 | 使用 FFmpeg 校验，并在需要时回退到 HandBrakeCLI |
| 服务化运行 | `tmux` 会话 + 可选 `systemd` 服务 |
| 国际化文档 | 根目录语言切换与 `i18n/` 翻译 |

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
| `autopub.py` | 处理主引擎，统一协调上传、处理与发布 |
| `process_video.py` | 用于上传、处理和结果处理的视频处理客户端 |
| `video_utils.py` / `handbrake.py` | 上传前的兼容性检查与修复 |

### Queue Management

| Component | Role |
|---|---|
| `process_queue.sh` | `flock` 加锁消费队列并带重试循环 |
| `queue_file_utility.sh` | 按路径或文件名模式手动入队 |

### Service Management

| Component | Role |
|---|---|
| `autopub_monitor_tmux_session.sh` | 启动/停止多面板 tmux 服务 |
| `autopub.sh` | `autopub.py` 的 conda/bootstrap 包装脚本 |
| `autopub_sync.sh` | 从远端/已同步源目录同步文件 |
| `monitor_autopublish.sh` | `inotify` 文件观察器，负责监听新文件与入队 |

### Utilities

| Component | Role |
|---|---|
| `window_info_utility.py` | `xdotool` 活动窗口工具（可选） |
| `autopub.config` | 集中化配置文件 |
| `install_autopub_monitor.sh` | 安装与 systemd 的配置助手 |

## Prerequisites

| Requirement | Notes |
|---|---|
| Linux 环境与 bash | 主要运行目标 |
| Python 3.8+ | 安装脚本当前会创建 Python 3.8 conda 环境 |
| `${HOME}/miniconda3` 中的 Miniconda | 脚本默认期望的路径 |
| `ffmpeg` / `ffprobe` | 视频校验与处理所需 |
| `tmux` | 服务编排 |
| `inotify-tools` | 文件事件监听（`inotifywait`） |
| `rsync` | 目录/系统间同步 |
| `python3-pip` | Python 包安装 |
| 可选：`HandBrakeCLI` | 建议用于修复有问题的视频 |
| 可选：`xdotool` | `window_info_utility.py` 需要 |

Python 包清单（仓库脚本中使用）：

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Automatic Installation (scripted)

从仓库根目录执行：

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

安装器会执行：

- 安装 apt 依赖（`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`）
- 创建或使用 conda 环境 `autopub-video`
- 安装 Python 包（`requests`, `requests_toolbelt`, `selenium`）
- 创建运行目录与状态文件
- 安装并启用 `autopub-monitor.service`

### 🧩 Service Enable/Start (if not already enabled by installer)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Manual Setup

1. 检查并修改 `autopub_monitor/autopub.config` 以匹配你的运行环境。
2. 创建并激活环境：

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 设置脚本为可执行：

```bash
chmod +x autopub_monitor/*.sh
```

> 假设：仓库运行态状态文件（如 `queue.lock`, `temp_queue.txt`, `checked_list.txt`）应已存在，或在启动/安装流程中创建。

## Configuration

主要配置文件：`autopub_monitor/autopub.config`

关键配置项包括：

- 数据目录：`AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 同步源目录：`JIANGUOYUN_*`
- 状态文件：`QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- 锁文件：`QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 设置：`USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 配置：`CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

说明：

- 默认配置当前倾向 app API 模式（`USE_APP_API="true"`），并由 `APP_API_BASE_URL` 拼接端点 URL。
- 历史端点仍保留在配置文件中供参考。
- 队列和锁文件名在所有脚本一致引用的情况下，可低风险调整。

## Usage

### ▶️ Start Services

在仓库根目录执行：

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

该命令会启动：

- 文件同步服务
- 目录 watcher 服务
- 队列处理服务
- 手动命令面板
- 转录 rsync 会话（`am-transcription-sync`）

### ⏹️ Stop Services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Manual Queue Management

```bash
# 按模式匹配添加
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# 按完整路径添加
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# 自动确认添加（不显示选择提示）
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Manual Video Processing

```bash
# 使用 wrapper 默认参数处理单文件
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 指定发布目标进行直接 CLI 运行
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# 缓存选项 + 进度可视化
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 仅上传与处理，不发布
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

- 在 app API 模式（`USE_APP_API=true`）下，若未显式传入发布参数，则默认不会发布。

## 🎛️ Command Palette

| Area | Examples |
|---|---|
| Service controls | `autopub_monitor_tmux_session.sh start/stop` |
| Queue operations | `queue_file_utility.sh`, `process_queue.sh` |
| File sync/process | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python execution path | `autopub.py`, `process_video.py`, `video_utils.py` |

## Processing Architecture

1. **文件检测**：`monitor_autopublish.sh` 监听 `close_write`/`moved_to` 事件。
2. **入队**：有效文件通过 `flock` 追加到 `queue_list.txt`。
3. **处理**：`process_queue.sh` 消费队列条目并调用 `autopub.sh`。
4. **上传/处理/发布**：`autopub.py` 与 `process_video.py` 调用配置好的 API 端点。
5. **追踪**：处理后的文件写入 `processed.csv`，已发现文件写入 `videos_db.csv`。

## Practical Examples

### Example 1: End-to-end daemon mode 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

然后将视频放入或同步到你的源目录，并在 tmux 面板中查看日志。

### Example 2: Force re-run matching files 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Example 3: Local test without publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Development Notes

- 仓库根目录未提供固定的依赖清单（`requirements.txt` / `pyproject.toml`）。
- 运行时强依赖 Linux shell 工具和本地路径约定。
- 当前脚本会动态读取 shell 配置（`autopub.config`）；请保持 shell 兼容变量表达式。
- 队列和锁语义依赖 `flock`，避免引入破坏原子性队列更新的修改。
- API 协议细节可从客户端代码推断；服务端实现位于仓库外部。
- `i18n/` 目录存在，但该草稿周期内翻译文档尚未完全维护。
- 处理产物文件（`queue_list.txt`, `temp_queue.txt` 等）通常在运行时生成或托管管理，环境间可能不同。

## 🧱 Legacy Name Compatibility (Preserved)

先前文档使用了重命名后的组件标签。当前仓库文件名如下。

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
| `Miniconda not found at ~/miniconda3` | 安装 Miniconda，或更新 `autopub.config` 中的 `CONDA_DIR`。 |
| `inotifywait: command not found` | 安装 `inotify-tools`。 |
| `ffprobe`/`ffmpeg` failures | 安装 `ffmpeg`，并校验输入文件完整性。 |
| 视频反复未入队 | 检查 `checked_list.txt`、`temp_queue.txt` 与 `monitor_autopublish.sh` 的监控日志。 |
| Queue stuck or race concerns | 检查 `queue.lock`、`queue_list.txt`，并结合 `flock` 查看活跃进程。 |
| API upload/process/publish errors | 核对 `APP_API_BASE_URL`，以及 `autopub.config` 中的端点路径。 |
| tmux service not starting | 确认 `tmux has-session` 可用，并且脚本有执行权限。 |

## 🗺️ Roadmap

- 增加固定依赖管理（`requirements.txt` 或 `pyproject.toml`）。
- 新增 shell/Python 的 lint 与基础集成测试 CI。
- 补充 API 合约与部署假设文档。
- 扩展 `i18n/`，补齐维护中的翻译 README。
- 改善可观测性（结构化日志与健康检查）。

## 🤝 Contributing

欢迎贡献。

Recommended workflow:

1. Fork 并创建功能分支。
2. 保持改动小且聚焦（脚本与文档一起更新）。
3. 在安装必要系统工具的 Linux 环境中验证。
4. 提交 Pull Request 时附上清晰的复现与测试说明。

行为变更时，请同步更新：

- `README.md`
- `PROJECT_STRUCTURE.md` 和/或 `autopub_monitor/README.md`

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

Apache License 2.0 - 详见 [LICENSE](LICENSE) 了解详情。
