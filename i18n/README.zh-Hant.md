[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#prerequisites)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#prerequisites)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#usage)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

一套用於監控、處理並將影片內容發佈到多平台的自動化系統。

## 概覽

AutoPubMonitor 是一個以 Linux 為核心的自動化流程管線，專為影片內容處理與多平台發佈而設計。系統會偵測新影片檔案，依序執行相容性修復、可選增強、透過 API 的轉錄/翻譯相關處理，並將結果發佈到已配置的平台。

執行環境以 shell 為協調核心（`tmux`、`inotifywait`、`rsync`、`flock`），搭配 Python 處理客戶端與 CSV/文字狀態追蹤。

## 主要功能

| 能力 | 說明 |
|---|---|
| 自動檔案偵測 | 監看目錄中的新影片內容 |
| 處理佇列管理 | 以可控、序列化方式處理影片 |
| 影片處理 | 檢查時長、格式並預處理影片 |
| 多平台發佈 | 支援小紅書、Bilibili、抖音、視頻號與 YouTube |
| 快取系統 | 透過結果快取提升處理效率 |
| 檔案同步 | 處理系統間檔案移動與同步 |
| 集中式設定 | 所有路徑與參數集中於單一設定檔 |
| 易於安裝 | 使用單一腳本完成整套系統安裝 |
| 影片相容性修復 | 使用 FFmpeg 檢查，必要時可回退至 HandBrakeCLI |
| 服務化運行 | `tmux` 工作階段 + 可選 `systemd` 服務 |

## 儲存庫結構

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

## 系統元件

### 核心處理

| 元件 | 角色 |
|---|---|
| `autopub.py` | 主處理引擎，負責上傳/處理/發佈流程協調 |
| `process_video.py` | 影片處理客戶端，執行上傳、處理與結果收斂 |
| `video_utils.py` / `handbrake.py` | 上傳前進行相容性檢查與修復 |

### 佇列管理

| 元件 | 角色 |
|---|---|
| `process_queue.sh` | 具 `flock` 鎖定與重試迴圈的佇列消費器 |
| `queue_file_utility.sh` | 透過路徑或檔名模式手動加入佇列 |

### 服務管理

| 元件 | 角色 |
|---|---|
| `autopub_monitor_tmux_session.sh` | 啟動/停止多面板 tmux 服務 |
| `autopub.sh` | `autopub.py` 的 conda/bootstrap 包裝器 |
| `autopub_sync.sh` | 從 Nutstore/堅果雲路徑同步檔案 |
| `monitor_autopublish.sh` | 監看新檔並排入佇列的 `inotify` 監聽器 |

### 工具

| 元件 | 角色 |
|---|---|
| `window_info_utility.py` | 使用 `xdotool` 的前景視窗工具（可選） |
| `autopub.config` | 集中式設定檔 |
| `install_autopub_monitor.sh` | 安裝與 systemd 設定輔助腳本 |

## 先決條件

| 需求 | 備註 |
|---|---|
| Linux 環境與 bash | 主要執行目標 |
| Python 3.8+ | 安裝器目前建立 Python 3.8 conda 環境 |
| 位於 `${HOME}/miniconda3` 的 Miniconda | 腳本預設路徑 |
| `ffmpeg` / `ffprobe` | 影片驗證/處理必要工具 |
| `tmux` | 服務流程協調 |
| `inotify-tools` | 檔案事件監控（`inotifywait`） |
| `rsync` | 目錄/系統間同步 |
| `python3-pip` | Python 套件安裝 |
| 可選：`HandBrakeCLI` | 建議用於修復有問題的影片 |
| 可選：`xdotool` | `window_info_utility.py` 需要 |

儲存庫腳本使用的 Python 套件包含：

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## 安裝

### 🚀 自動安裝（腳本化）

在儲存庫根目錄執行：

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

安裝器會：

- 安裝 apt 依賴（`tmux`、`inotify-tools`、`ffmpeg`、`python3-pip`）
- 建立/使用 conda 環境 `autopub-video`
- 安裝 Python 套件（`requests`、`requests_toolbelt`、`selenium`）
- 建立執行期目錄與狀態檔
- 安裝並啟用 `autopub-monitor.service`

### 🧩 啟用/啟動服務（若安裝器尚未啟用）

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 手動設定

1. 依你的環境檢查並修改 `autopub_monitor/autopub.config`。
2. 建立並啟用環境：

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 為腳本加入可執行權限：

```bash
chmod +x autopub_monitor/*.sh
```

## 設定

主要設定檔：`autopub_monitor/autopub.config`

重要設定包含：

- 資料目錄：`AUTOPUBLISH_DIR`、`TRANSCRIPTION_DIR`、`PREPROCESSED_VIDEOS_DIR`
- 同步來源目錄：`JIANGUOYUN_*`
- 狀態檔：`QUEUE_LIST`、`TEMP_QUEUE`、`CHECKED_LIST`、`VIDEOS_DB_PATH`、`PROCESSED_PATH`
- 鎖檔：`QUEUE_LOCK`、`AUTOPUB_LOCK`
- API 設定：`USE_APP_API`、`APP_API_BASE_URL`、`UPLOAD_URL`、`PROCESS_URL`、`PUBLISH_URL`
- Conda 設定：`CONDA_ENV`、`CONDA_DIR`、`CONDA_ACTIVATE`

備註：

- 預設設定目前偏好 app API 模式（`USE_APP_API="true"`），並由 `APP_API_BASE_URL` 組合各端點 URL。
- 舊版端點仍保留於設定檔中供參考。

## 使用方式

### ▶️ 啟動服務

在儲存庫根目錄執行：

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

此命令會啟動：

- 檔案同步服務
- 目錄監看服務
- 佇列處理服務
- 手動命令面板
- 轉錄 rsync 工作階段（`am-transcription-sync`）

### ⏹️ 停止服務

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 手動佇列管理

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 手動影片處理

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

## CLI 選項（`autopub.py`）

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

行為說明：

- 在 app API 模式（`USE_APP_API=true`）下，預設不會執行發佈，除非明確傳入發佈旗標。

## 處理架構

1. **檔案偵測**：`monitor_autopublish.sh` 監看 `close_write`/`moved_to` 事件。
2. **佇列**：有效檔案透過 `flock` 附加到 `queue_list.txt`。
3. **處理**：`process_queue.sh` 消費佇列項目並呼叫 `autopub.sh`。
4. **上傳/處理/發佈**：`autopub.py` 與 `process_video.py` 呼叫已配置 API 端點。
5. **追蹤**：已處理檔案寫入 `processed.csv`，已發現檔案寫入 `videos_db.csv`。

## 實務範例

### 範例 1：端到端常駐模式 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

接著將影片放入（或同步到）你設定的來源目錄，並在 tmux 面板中觀察日誌。

### 範例 2：強制重跑符合條件檔案 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 範例 3：本地測試且不發佈 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 開發說明

- 儲存庫根目錄目前沒有固定版本依賴清單（`requirements.txt` / `pyproject.toml`）。
- 執行期高度依賴 Linux shell 工具與本機路徑慣例。
- 目前腳本會動態載入 shell 設定（`autopub.config`）；請保持 shell 相容的變數表達式。
- 佇列與鎖定語義依賴 `flock`；避免進行會削弱原子化佇列更新的修改。
- API 合約細節由客戶端程式推斷而來；伺服器實作不在此儲存庫中。
- `i18n/` 目錄已存在；本次循環已開始補齊多語 README。

## 舊名稱相容性（保留）

先前文件使用過重新命名的元件標籤；目前儲存庫實際檔名如下。

| 舊文件標籤 | 目前儲存庫檔案 |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

為了方便起見，若你先 `cd autopub_monitor`，舊文件風格的以下指令仍可對應使用：

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 疑難排解

| 症狀 | 建議檢查項目 |
|---|---|
| `Miniconda not found at ~/miniconda3` | 安裝 Miniconda，或更新 `autopub.config` 內的 `CONDA_DIR`。 |
| `inotifywait: command not found` | 安裝 `inotify-tools`。 |
| `ffprobe`/`ffmpeg` failures | 安裝 `ffmpeg`，並確認輸入檔案完整性。 |
| 影片反覆未進入佇列 | 檢查 `checked_list.txt`、`temp_queue.txt`，並查看 `monitor_autopublish.sh` 日誌。 |
| 佇列卡住或疑似競態 | 檢查 `queue.lock`、`queue_list.txt`，以及使用 `flock` 的相關進程。 |
| API upload/process/publish errors | 驗證 `autopub.config` 中的 `APP_API_BASE_URL` 與端點路徑。 |
| tmux service not starting | 確認 `tmux has-session` 可運作，且腳本已具可執行權限。 |

## 路線圖

- 增加固定版本依賴管理（`requirements.txt` 或 `pyproject.toml`）。
- 增加 shell/Python lint 與基本整合測試的 CI 檢查。
- 補上 API 合約與部署假設的文件。
- 擴充 `i18n/` 並維護多語 README。
- 強化可觀測性（結構化日誌與健康檢查）。

## 貢獻

歡迎貢獻。

建議流程：

1. Fork 並建立功能分支。
2. 讓變更保持小而聚焦（建議腳本與文件同步更新）。
3. 於具備必要系統工具的 Linux 環境驗證。
4. 提交 Pull Request，並附上清楚的重現/測試說明。

若行為有變更，請同步更新：

- `README.md`
- `PROJECT_STRUCTURE.md` 及/或 `autopub_monitor/README.md`

## 支援與贊助

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

（來源：`.github/FUNDING.yml`）

## 致謝

- 系統以 Linux 原生工具（`tmux`、`inotify`、`rsync`、`ffmpeg`）為核心，提供可靠的長時間自動化能力。
- 感謝所有貢獻者與使用者持續支持改進。

## 授權

Apache License 2.0 - 詳見 [LICENSE](LICENSE)。
