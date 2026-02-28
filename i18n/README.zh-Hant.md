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

> 用於監控、處理並將影片內容發布到多個平台的自動化系統。

| What to expect | Detail |
|---|---|
| 運行模型 | Linux 優先的自動化，使用 `tmux`、可選擇的 `systemd`，並以隊列鎖進行管控 |
| 佇列設計 | 檔案監視器 → 佇列 → worker 迴圈，並進行持續狀態追蹤 |
| 可延展性 | Shell 編排 + 平台適配器的 Python 發布客戶端 |
| 核心入口點 | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Documentation Map

| Section | Why it matters |
|---|---|
| [Project at a Glance](#project-at-a-glance) | 快速理解執行模型與目標 |
| [Installation](#installation) | 從 clone 到服務啟用 |
| [Configuration](#configuration) | 瞭解每個重要的腳本層設定 |
| [Usage](#usage) | 啟動、停止、佇列與處理流程 |
| [System Components](#system-components) | 區分 Shell 與 Python 的責任劃分 |
| [Troubleshooting](#troubleshooting) | 快速排查啟動與佇列問題 |
| [Roadmap](#roadmap) | 追蹤近期平台與工具規劃 |
| [Contributing](#contributing) | 掌握安全的貢獻方式 |

## 🧭 Quick Start at a Glance

| Goal | Command | Notes |
|---|---|---|
| Start monitoring pipeline | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | 啟動監控、佇列、同步與手動面板 |
| Stop all services | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | 優雅停機並清理面板 |
| Queue by pattern | `./autopub_monitor/queue_file_utility.sh "pattern"` | 將符合條件的檔案加入處理佇列 |
| Process one file | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | 使用預設的發布與處理設定 |

## 🎯 Project at a Glance

| Focus | Details |
|---|---|
| 運行目標 | Linux，使用 `tmux` 編排與可選 `systemd` |
| 佇列模型 | 檔案監視器 → 佇列 → worker 腳本 → 發布流程 |
| 核心入口點 | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| 狀態追蹤 | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Overview

AutoPubMonitor 是一個面向 Linux 的影片內容處理與多平台發布自動化流程。系統會監控新影片檔案，經過相容性修復、選用的增強處理、透過 API 的轉錄/翻譯相關流程，並將結果發布到已設定的平台。

執行時由 Shell 協調（`tmux`、`inotifywait`、`rsync`、`flock`）驅動，搭配 Python 處理客戶端與以 CSV/文字為基礎的狀態追蹤。

## ⚡ Key Features

| Capability | Details |
|---|---|
| 自動檔案偵測 | 監控目錄中的新影片內容 |
| 佇列管理 | 以可控、順序化方式處理影片 |
| 影片處理 | 檢查長度與格式，並預先整理影片 |
| 多平台發布 | 支援 XiaoHongShu、Bilibili、Douyin、ShiPinHao 與 YouTube |
| 快取機制 | 透過快取結果提升處理效率 |
| 檔案同步 | 在不同系統/目錄間移動檔案 |
| 集中化設定 | 所有路徑與設定集中在單一設定檔 |
| 簡易安裝 | 單一腳本可完成整套系統安裝 |
| 影片相容性修復 | 使用 FFmpeg 檢查，並在需要時退回 HandBrakeCLI |
| 服務導向運作 | `tmux` 會話 + 可選 `systemd` 服務 |
| 國際化文件 | 根目錄語系連結與 `i18n/` 翻譯 |

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
| `autopub.py` | 主處理引擎，負責上傳、處理與發布的整體編排 |
| `process_video.py` | 上傳、處理與結果處理的影片處理客戶端 |
| `video_utils.py` / `handbrake.py` | 上傳前的相容性檢查與修復 |

### Queue Management

| Component | Role |
|---|---|
| `process_queue.sh` | 以 `flock` 鎖定消費佇列並進行重試循環 |
| `queue_file_utility.sh` | 依路徑或檔名模式手動注入佇列 |

### Service Management

| Component | Role |
|---|---|
| `autopub_monitor_tmux_session.sh` | 啟動/停止多窗格 tmux 服務 |
| `autopub.sh` | `autopub.py` 的 conda/bootstrap 包裝 |
| `autopub_sync.sh` | 從遠端/同步來源目錄同步檔案 |
| `monitor_autopublish.sh` | 用於新檔案監測與佇列的 `inotify` 監看器 |

### Utilities

| Component | Role |
|---|---|
| `window_info_utility.py` | 使用 `xdotool` 的作用中視窗工具（可選） |
| `autopub.config` | 集中設定檔 |
| `install_autopub_monitor.sh` | 安裝與 `systemd` 設定輔助程式 |

## Prerequisites

| Requirement | Notes |
|---|---|
| Linux 環境與 bash | 主要執行目標 |
| Python 3.8+ | 安裝腳本目前會建立 Python 3.8 conda 環境 |
| `${HOME}/miniconda3` 中的 Miniconda | 腳本預設期待的安裝路徑 |
| `ffmpeg` / `ffprobe` | 影片驗證/處理必要套件 |
| `tmux` | 服務編排 |
| `inotify-tools` | 檔案事件監控（`inotifywait`） |
| `rsync` | 目錄或系統間同步 |
| `python3-pip` | 安裝 Python 套件 |
| 可選：`HandBrakeCLI` | 建議用於修復有問題的影片 |
| 可選：`xdotool` | `window_info_utility.py` 需要 |

Python 套件（本專案腳本有使用）：

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Automatic Installation (scripted)

在專案根目錄執行：

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

安裝器會：

- 安裝 apt 依賴（`tmux`、`inotify-tools`、`ffmpeg`、`python3-pip`）
- 建立或使用 conda 環境 `autopub-video`
- 安裝 Python 套件（`requests`, `requests_toolbelt`, `selenium`）
- 建立運行目錄與狀態檔
- 安裝並啟用 `autopub-monitor.service`

### 🧩 Service Enable/Start (if not already enabled by installer)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Manual Setup

1. 檢查並修改 `autopub_monitor/autopub.config` 以符合你的執行環境。
2. 建立並啟用環境：

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 讓腳本可執行：

```bash
chmod +x autopub_monitor/*.sh
```

> 假設：實際運行用到的狀態檔（例如 `queue.lock`, `temp_queue.txt`, `checked_list.txt`）應已存在，或在啟動/安裝流程中建立。

## Configuration

主要設定檔：`autopub_monitor/autopub.config`

重要設定包括：

- 資料目錄：`AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 同步來源目錄：`JIANGUOYUN_*`
- 狀態檔：`QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- 鎖檔：`QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 設定：`USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 設定：`CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

備註：

- 預設設定目前偏好 app API 模式（`USE_APP_API="true"`），並由 `APP_API_BASE_URL` 拼接 endpoint URL。
- 歷史 endpoint 仍保留在設定檔中作為參考。
- 只要所有腳本引用的是同一個設定鍵，佇列與鎖檔檔名可以低風險調整。

## Usage

### ▶️ Start Services

在專案根目錄執行：

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

此命令會啟動：

- 檔案同步服務
- 目錄監視服務
- 佇列處理服務
- 手動命令面板
- 轉錄 rsync 工作階段（`am-transcription-sync`）

### ⏹️ Stop Services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Manual Queue Management

```bash
# 依樣式新增
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# 以完整路徑新增
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# 自動確認新增（不顯示選取提示）
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Manual Video Processing

```bash
# 使用 wrapper 預設參數處理單一檔案
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 指定發布目標進行直接 CLI 呼叫
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# 快取選項與進度視覺化
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 上傳/處理但不發布
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

- 在 app API 模式（`USE_APP_API=true`）下，若未明確傳入發布參數，預設不會發布。

## 🎛️ Command Palette

| Area | Examples |
|---|---|
| 服務控制 | `autopub_monitor_tmux_session.sh start/stop` |
| 佇列操作 | `queue_file_utility.sh`, `process_queue.sh` |
| 檔案同步/處理 | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python 執行路徑 | `autopub.py`, `process_video.py`, `video_utils.py` |

## Processing Architecture

1. **檔案偵測**：`monitor_autopublish.sh` 監聽 `close_write`/`moved_to` 事件。
2. **佇列化**：有效檔案使用 `flock` 追加到 `queue_list.txt`。
3. **處理**：`process_queue.sh` 消費佇列項目並呼叫 `autopub.sh`。
4. **上傳/處理/發布**：`autopub.py` 與 `process_video.py` 呼叫設定好的 API 端點。
5. **追蹤**：已處理檔案寫入 `processed.csv`，已發現檔案寫入 `videos_db.csv`。

## Practical Examples

### Example 1: End-to-end daemon mode 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

接著將影片放入或同步到你設定的來源目錄，並在 tmux 面板中查看日誌。

### Example 2: Force re-run matching files 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Example 3: Local test without publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Development Notes

- 專案根目錄未提供固定版本管理的依賴清單（`requirements.txt` / `pyproject.toml`）。
- 執行期高度依賴 Linux Shell 工具與本機路徑慣例。
- 目前腳本會動態讀取 shell 設定（`autopub.config`）；請保留 Shell 相容的變數表示法。
- 佇列與鎖的語義依賴 `flock`，避免進行會削弱原子性更新佇列的修改。
- API 合約細節從客戶端程式推斷；伺服器實作位於本儲存庫外部。
- `i18n/` 目錄存在，但目前這個版本的翻譯文件尚未完全維護。
- 已處理檔案等中介產物（`queue_list.txt`、`temp_queue.txt` 等）通常在執行時建立/管理，於不同環境間可能有差異。

## 🧱 Legacy Name Compatibility (Preserved)

先前文件曾使用重新命名後的元件標籤。以下為目前版本的實際檔案名稱。

| Earlier docs label | Current repository file |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

如在 `cd autopub_monitor` 後，舊文件中的命令可對應為：

```bash
# 舊文件寫法（對應現行同位置命令）
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
| `Miniconda not found at ~/miniconda3` | 安裝 Miniconda，或更新 `autopub.config` 中的 `CONDA_DIR`。 |
| `inotifywait: command not found` | 安裝 `inotify-tools`。 |
| `ffprobe`/`ffmpeg` failures | 安裝 `ffmpeg`，並驗證輸入檔完整性。 |
| 影片反覆未入佇列 | 檢查 `checked_list.txt`、`temp_queue.txt`，以及 `monitor_autopublish.sh` 的監控日誌。 |
| Queue stuck or race concerns | 檢查 `queue.lock`、`queue_list.txt`，並用 `flock` 檢查活躍程序。 |
| API upload/process/publish errors | 確認 `APP_API_BASE_URL` 與 `autopub.config` 內的端點路徑。 |
| tmux service not starting | 確認 `tmux has-session` 可執行，並確認腳本具備執行權限。 |

## 🗺️ Roadmap

- 新增固定依賴管理（`requirements.txt` 或 `pyproject.toml`）。
- 新增 shell/Python lint 與基礎整合測試的 CI。
- 補強 API 合約與部署假設文件。
- 擴充 `i18n/`，維護更多完整翻譯的 README。
- 改善可觀測性（結構化日誌與健康檢查）。

## 🤝 Contributing

歡迎貢獻。

Recommended workflow:

1. Fork 並建立功能分支。
2. 保持變更小且集中（腳本與文件同步更新）。
3. 在具備必要系統工具的 Linux 環境中進行驗證。
4. 提交 Pull Request 時附上清楚的重現步驟與測試紀錄。

若行為有變更，請同步更新：

- `README.md`
- `PROJECT_STRUCTURE.md` 和／或 `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Contact

有問題、錯誤回報與功能需求：

- 前往 [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues) 開單

## 🙌 Acknowledgements

- 以 Linux 原生工具為基礎（`tmux`、`inotify`、`rsync`、`ffmpeg`）打造穩定長時自動化。
- 感謝所有持續支持改進的貢獻者與使用者。

## 📄 License

Apache License 2.0 - 詳情請參閱 [LICENSE](LICENSE)。
