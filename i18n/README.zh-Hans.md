[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#前置要求)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#前置要求)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#使用)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

一个用于监控、处理并发布视频内容到多个平台的自动化系统。

## 概览

AutoPubMonitor 是一个面向 Linux 的视频处理与多平台发布自动化流水线。系统会监听新视频文件，并执行包括兼容性修复、可选增强、通过 API 的转录/翻译相关处理，以及将结果发布到已配置平台在内的流程。

运行时由 Shell 工具编排（`tmux`、`inotifywait`、`rsync`、`flock`），配合 Python 处理客户端与 CSV/文本状态追踪。

## 核心特性

| 能力 | 说明 |
|---|---|
| 自动文件检测 | 监听目录中的新视频内容 |
| 处理队列管理 | 以可控、串行的方式处理视频 |
| 视频处理 | 检查时长、格式并预处理视频 |
| 多平台发布 | 支持小红书、Bilibili、抖音、视频号、YouTube |
| 缓存系统 | 通过缓存优化处理效率 |
| 文件同步 | 处理系统间文件移动与同步 |
| 集中配置 | 所有路径与设置统一在一个配置文件中 |
| 易于安装 | 使用单个脚本完成整套系统安装 |
| 视频兼容性修复 | 使用 FFmpeg 检查，并可选 HandBrakeCLI 兜底 |
| 面向服务运行 | `tmux` 会话 + 可选 `systemd` 服务 |

## 仓库结构

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

## 系统组件

### 核心处理

| 组件 | 角色 |
|---|---|
| `autopub.py` | 主处理引擎，负责上传/处理/发布编排 |
| `process_video.py` | 视频处理客户端，负责上传、处理与结果回收 |
| `video_utils.py` / `handbrake.py` | 上传前的兼容性检查与修复 |

### 队列管理

| 组件 | 角色 |
|---|---|
| `process_queue.sh` | 使用 `flock` 锁和重试循环的队列消费者 |
| `queue_file_utility.sh` | 按路径或文件名模式手动加入队列 |

### 服务管理

| 组件 | 角色 |
|---|---|
| `autopub_monitor_tmux_session.sh` | 启动/停止多窗格 tmux 服务 |
| `autopub.sh` | `autopub.py` 的 Conda/启动封装器 |
| `autopub_sync.sh` | 从 Nutstore/坚果云路径同步文件 |
| `monitor_autopublish.sh` | 用于新文件监听与入队的 `inotify` 监控器 |

### 实用工具

| 组件 | 角色 |
|---|---|
| `window_info_utility.py` | 基于 `xdotool` 的活动窗口工具（可选） |
| `autopub.config` | 中央配置文件 |
| `install_autopub_monitor.sh` | 安装 + systemd 配置辅助脚本 |

## 前置要求

| 依赖 | 说明 |
|---|---|
| 带 bash 的 Linux 环境 | 主要运行目标 |
| Python 3.8+ | 安装脚本当前创建 Python 3.8 conda 环境 |
| 位于 `${HOME}/miniconda3` 的 Miniconda | 脚本默认预期路径 |
| `ffmpeg` / `ffprobe` | 视频校验/处理必需 |
| `tmux` | 服务编排 |
| `inotify-tools` | 文件事件监听（`inotifywait`） |
| `rsync` | 目录/系统间同步 |
| `python3-pip` | Python 包安装 |
| 可选：`HandBrakeCLI` | 建议用于修复疑难视频 |
| 可选：`xdotool` | `window_info_utility.py` 所需 |

仓库脚本使用的 Python 包包括：

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## 安装

### 🚀 自动安装（脚本化）

在仓库根目录执行：

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

安装脚本会：

- 安装 apt 依赖（`tmux`、`inotify-tools`、`ffmpeg`、`python3-pip`）
- 创建/使用 conda 环境 `autopub-video`
- 安装 Python 包（`requests`、`requests_toolbelt`、`selenium`）
- 创建运行目录与状态文件
- 安装并启用 `autopub-monitor.service`

### 🧩 启用/启动服务（如果安装器未启用）

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 手动配置

1. 根据你的环境检查并修改 `autopub_monitor/autopub.config`。
2. 创建并激活环境：

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 赋予脚本可执行权限：

```bash
chmod +x autopub_monitor/*.sh
```

## 配置

主配置文件：`autopub_monitor/autopub.config`

关键设置包括：

- 数据目录：`AUTOPUBLISH_DIR`、`TRANSCRIPTION_DIR`、`PREPROCESSED_VIDEOS_DIR`
- 同步源目录：`JIANGUOYUN_*`
- 状态文件：`QUEUE_LIST`、`TEMP_QUEUE`、`CHECKED_LIST`、`VIDEOS_DB_PATH`、`PROCESSED_PATH`
- 锁文件：`QUEUE_LOCK`、`AUTOPUB_LOCK`
- API 设置：`USE_APP_API`、`APP_API_BASE_URL`、`UPLOAD_URL`、`PROCESS_URL`、`PUBLISH_URL`
- Conda 设置：`CONDA_ENV`、`CONDA_DIR`、`CONDA_ACTIVATE`

说明：

- 默认配置目前优先使用 app API 模式（`USE_APP_API="true"`），并基于 `APP_API_BASE_URL` 构建各端点 URL。
- 配置中仍保留了旧版端点，供参考。

## 使用

### ▶️ 启动服务

在仓库根目录执行：

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

将启动：

- 文件同步服务
- 目录监听服务
- 队列处理服务
- 手动命令窗格
- 转录 rsync 会话（`am-transcription-sync`）

### ⏹️ 停止服务

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 手动队列管理

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 手动视频处理

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

## CLI 选项（`autopub.py`）

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

行为说明：

- 在 app API 模式下（`USE_APP_API=true`），除非显式传入发布参数，否则默认不发布。

## 处理架构

1. **文件检测**：`monitor_autopublish.sh` 监听 `close_write` / `moved_to` 事件。
2. **队列**：有效文件通过 `flock` 追加到 `queue_list.txt`。
3. **处理**：`process_queue.sh` 消费队列并调用 `autopub.sh`。
4. **上传/处理/发布**：`autopub.py` 与 `process_video.py` 调用已配置 API 端点。
5. **追踪**：已处理文件写入 `processed.csv`，已发现文件写入 `videos_db.csv`。

## 实用示例

### 示例 1：端到端守护进程模式 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

然后将视频放入或同步到你配置的源目录，并在 tmux 窗格中观察日志。

### 示例 2：强制重跑匹配文件 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 示例 3：本地测试且不发布 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 开发说明

- 仓库根目录当前没有固定依赖清单（`requirements.txt` / `pyproject.toml`）。
- 运行时强依赖 Linux Shell 工具与本地路径约定。
- 当前脚本会动态加载 shell 配置（`autopub.config`）；请保持 shell 兼容的变量表达式。
- 队列与锁语义依赖 `flock`；避免修改成会削弱队列原子更新的实现。
- API 协议细节来自客户端代码推断；服务端实现不在本仓库内。
- `i18n/` 目录已存在，本轮正在逐步补充多语言文档。

## 旧名称兼容性（保留）

此前文档使用过重命名后的组件标签。当前仓库文件名如下表所示。

| 旧文档标签 | 当前仓库文件 |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

为方便起见，如果你先 `cd autopub_monitor`，旧文档中的这些命令形式可映射为：

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 故障排查

| 症状 | 检查项 |
|---|---|
| `Miniconda not found at ~/miniconda3` | 安装 Miniconda，或在 `autopub.config` 中更新 `CONDA_DIR`。 |
| `inotifywait: command not found` | 安装 `inotify-tools`。 |
| `ffprobe`/`ffmpeg` 失败 | 安装 `ffmpeg`，并校验输入文件完整性。 |
| 视频反复未入队 | 检查 `checked_list.txt`、`temp_queue.txt`，并查看 `monitor_autopublish.sh` 日志。 |
| 队列卡住或存在竞争风险 | 检查 `queue.lock`、`queue_list.txt`，以及使用 `flock` 的活动进程。 |
| API 上传/处理/发布错误 | 校验 `autopub.config` 中的 `APP_API_BASE_URL` 与端点路径。 |
| tmux 服务无法启动 | 确认 `tmux has-session` 可用，且脚本具有可执行权限。 |

## 路线图

- 增加固定依赖管理（`requirements.txt` 或 `pyproject.toml`）。
- 增加 Shell/Python lint 与基础集成测试的 CI 检查。
- 增加 API 协议与部署前提文档。
- 持续扩展并维护 `i18n/` 多语言 README。
- 提升可观测性（结构化日志与健康检查）。

## 贡献

欢迎贡献。

建议流程：

1. Fork 并创建功能分支。
2. 保持改动小而聚焦（脚本与文档一并更新）。
3. 在具备所需系统工具的 Linux 环境验证。
4. 提交 Pull Request，并附清晰的复现/测试说明。

若行为发生变化，请同时更新：

- `README.md`
- `PROJECT_STRUCTURE.md` 和/或 `autopub_monitor/README.md`

## 支持与赞助

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

（来自 `.github/FUNDING.yml`）

## 致谢

- 基于 Linux 原生工具（`tmux`、`inotify`、`rsync`、`ffmpeg`）构建，以支持稳定的长时间自动化运行。
- 感谢所有支持持续改进的贡献者与用户。

## 许可证

Apache License 2.0 - 详见 [LICENSE](../LICENSE)。
