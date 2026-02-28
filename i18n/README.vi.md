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

> Hệ thống tự động hóa để giám sát, xử lý và xuất bản nội dung video trên nhiều nền tảng.

| Có thể mong đợi | Chi tiết |
|---|---|
| Mô hình chạy | Tự động hóa ưu tiên Linux với `tmux`, `systemd` tùy chọn và khóa hàng đợi |
| Thiết kế hàng đợi | Theo dõi file → hàng đợi -> worker loop, kèm theo theo dõi trạng thái bền vững |
| Mở rộng | Điều phối bởi shell + client Python cho các adapter nền tảng |
| Điểm vào cốt lõi | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Bản đồ tài liệu

| Mục | Lý do quan trọng |
|---|---|
| [Project at a Glance](#project-at-a-glance) | Nắm nhanh mô hình chạy và mục tiêu của hệ thống |
| [Installation](#installation) | Từ bước clone đến chạy dịch vụ |
| [Configuration](#configuration) | Biết rõ mọi thiết lập quan trọng cấp script |
| [Usage](#usage) | Khởi động, dừng, thêm hàng đợi và xử lý quy trình |
| [System Components](#system-components) | Xác định rõ trách nhiệm của shell và Python |
| [Troubleshooting](#troubleshooting) | Xử lý nhanh lỗi khởi động và queue |
| [Roadmap](#roadmap) | Theo dõi kế hoạch ngắn hạn cho nền tảng và tooling |
| [Contributing](#contributing) | Hiểu mẫu đóng góp an toàn |

## 🧭 Tóm tắt nhanh

| Mục tiêu | Lệnh | Ghi chú |
|---|---|---|
| Bắt đầu pipeline giám sát | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Khởi chạy watcher + queue + sync + pane thủ công |
| Dừng tất cả dịch vụ | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Tắt sạch và dọn dẹp pane |
| Thêm vào queue theo mẫu | `./autopub_monitor/queue_file_utility.sh "pattern"` | Thêm các file khớp mẫu vào hàng đợi xử lý |
| Xử lý một file | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Dùng cấu hình và chế độ publish mặc định |

## 🎯 Project at a Glance

| Trọng tâm | Chi tiết |
|---|---|
| Mục tiêu runtime | Linux, với `tmux` orchestration và `systemd` tùy chọn |
| Mô hình queue | File watcher → queue → worker scripts → pipeline xuất bản |
| Điểm vào cốt lõi | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| Theo dõi trạng thái | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Tổng quan

AutoPubMonitor là một pipeline tự động hóa dành cho Linux, phục vụ xử lý video và xuất bản đa nền tảng. Hệ thống theo dõi các file video mới, xử lý qua nhiều bước gồm sửa lỗi tương thích, tăng cường nội dung tuỳ chọn, xử lý liên quan phụ đề/ dịch thuật qua API, rồi xuất bản kết quả lên các nền tảng đã cấu hình.

Runtime được điều phối bằng shell (`tmux`, `inotifywait`, `rsync`, `flock`) cùng các client xử lý Python và theo dõi trạng thái bằng file CSV/text.

## ⚡ Tính năng chính

| Khả năng | Chi tiết |
|---|---|
| Phát hiện file tự động | Theo dõi thư mục để nhận diện nội dung video mới |
| Quản lý queue xử lý | Xử lý video theo trình tự có kiểm soát |
| Xử lý video | Kiểm tra độ dài, định dạng và chuẩn bị video |
| Xuất bản đa nền tảng | Hỗ trợ XiaoHongShu, Bilibili, Douyin, ShiPinHao và YouTube |
| Hệ thống cache | Tối ưu hóa xử lý nhờ cache kết quả |
| Đồng bộ file | Di chuyển file giữa các hệ thống |
| Cấu hình tập trung | Mọi đường dẫn và cài đặt nằm trong một file cấu hình duy nhất |
| Cài đặt dễ dàng | Một script duy nhất để thiết lập toàn bộ hệ thống |
| Sửa lỗi tương thích video | Dùng kiểm tra FFmpeg và fallback HandBrakeCLI tùy chọn |
| Chạy theo hướng service | Phiên `tmux` + service `systemd` tùy chọn |
| Tài liệu quốc tế hóa | Liên kết ngôn ngữ gốc và bản dịch trong `i18n/` |

## 🗂️ Cấu trúc repository

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
| `autopub.py` | Engine xử lý chính điều phối upload/process/publish |
| `process_video.py` | Client xử lý video cho upload, processing và xử lý kết quả |
| `video_utils.py` / `handbrake.py` | Kiểm tra và sửa lỗi tương thích trước upload |

### Queue Management

| Component | Role |
|---|---|
| `process_queue.sh` | Consumer queue với khóa `flock` và vòng lặp retry |
| `queue_file_utility.sh` | Nạp queue thủ công theo đường dẫn hoặc mẫu tên file |

### Service Management

| Component | Role |
|---|---|
| `autopub_monitor_tmux_session.sh` | Khởi chạy/dừng dịch vụ tmux nhiều pane |
| `autopub.sh` | Wrapper conda/bootstrap cho `autopub.py` |
| `autopub_sync.sh` | Đồng bộ file từ nguồn từ xa/đã sync |
| `monitor_autopublish.sh` | Watcher `inotify` cho file mới và đẩy vào queue |

### Utilities

| Component | Role |
|---|---|
| `window_info_utility.py` | Công cụ lấy thông tin cửa sổ đang hoạt động dùng `xdotool` (tùy chọn) |
| `autopub.config` | File cấu hình tập trung |
| `install_autopub_monitor.sh` | Hỗ trợ cài đặt + thiết lập systemd |

## Prerequisites

| Requirement | Notes |
|---|---|
| Môi trường Linux có bash | Mục tiêu runtime chính |
| Python 3.8+ | Installer hiện tạo môi trường conda Python 3.8 |
| Miniconda tại `${HOME}/miniconda3` | Đường dẫn mặc định được kỳ vọng trong các script |
| `ffmpeg` / `ffprobe` | Bắt buộc cho kiểm tra/xử lý video |
| `tmux` | Điều phối dịch vụ |
| `inotify-tools` | Theo dõi sự kiện file (`inotifywait`) |
| `rsync` | Đồng bộ giữa các thư mục/hệ thống |
| `python3-pip` | Cài đặt package Python |
| Tùy chọn: `HandBrakeCLI` | Khuyến nghị để sửa video có vấn đề |
| Tùy chọn: `xdotool` | Cần cho `window_info_utility.py` |

Python packages used in repo scripts include:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Cài đặt tự động (script hóa)

Từ repository gốc:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

Bộ cài đặt sẽ:

- Cài các dependency apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Tạo/sử dụng môi trường conda `autopub-video`
- Cài đặt Python packages (`requests`, `requests_toolbelt`, `selenium`)
- Tạo các thư mục runtime và file trạng thái
- Cài đặt và bật `autopub-monitor.service`

### 🧩 Service Enable/Start (nếu installer chưa bật)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Cài đặt thủ công

1. Xem lại và chỉnh sửa `autopub_monitor/autopub.config` theo môi trường của bạn.
2. Tạo và kích hoạt environment:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Gán quyền thực thi cho các script:

```bash
chmod +x autopub_monitor/*.sh
```

> Assumption: repository runtime state files (for example `queue.lock`, `temp_queue.txt`, `checked_list.txt`) should either already exist or be created by your startup/install flow.

## Cấu hình

Primary configuration file: `autopub_monitor/autopub.config`

Các thiết lập quan trọng gồm:

- Thư mục dữ liệu: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Nguồn sync directories: `JIANGUOYUN_*`
- State files: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Lock files: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Cấu hình API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Cấu hình Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Lưu ý:

- Cấu hình mặc định hiện ưu tiên app API mode (`USE_APP_API="true"`) và tạo URL endpoint từ `APP_API_BASE_URL`.
- Các endpoint legacy vẫn còn trong config để tham chiếu.
- Tên file queue và lock có thể đổi với rủi ro thấp nếu mọi script đều tham chiếu đúng entry trong config.

## Usage

### ▶️ Khởi động services

Từ repository gốc:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Lệnh này khởi chạy:

- Dịch vụ đồng bộ file
- Dịch vụ giám sát thư mục
- Dịch vụ xử lý queue
- Pane lệnh thủ công
- Phiên rsync phụ đề (`am-transcription-sync`)

### ⏹️ Dừng services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Quản lý queue thủ công

```bash
# Thêm theo mẫu
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Thêm theo đường dẫn đầy đủ
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Thêm với tự động xác nhận (không hiển thị chọn)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Xử lý video thủ công

```bash
# Xử lý file cụ thể bằng wrapper mặc định
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# CLI trực tiếp với các mục đích publish cụ thể
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Tùy chọn cache + hiển thị tiến độ
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Upload/process mà không publish
python autopub_monitor/autopub.py --no-pub --path "/path/to/video.mp4"
```

## Tùy chọn CLI (`autopub.py`)

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

Lưu ý hành vi:

- Trong app API mode (`USE_APP_API=true`), publish mặc định bị tắt trừ khi truyền rõ cờ publish.

## 🎛️ Bảng điều khiển lệnh

| Khu vực | Ví dụ |
|---|---|
| Điều khiển service | `autopub_monitor_tmux_session.sh start/stop` |
| Thao tác queue | `queue_file_utility.sh`, `process_queue.sh` |
| Đồng bộ/xử lý file | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Đường dẫn thực thi Python | `autopub.py`, `process_video.py`, `video_utils.py` |

## Kiến trúc xử lý

1. **Phát hiện file**: `monitor_autopublish.sh` theo dõi event `close_write`/`moved_to`.
2. **Đưa vào queue**: file hợp lệ được append vào `queue_list.txt` bằng `flock`.
3. **Xử lý**: `process_queue.sh` đọc queue và gọi `autopub.sh`.
4. **Upload/Process/Publish**: `autopub.py` và `process_video.py` gọi các endpoint API đã cấu hình.
5. **Theo dõi**: file đã xử lý được ghi vào `processed.csv`, file đã phát hiện vào `videos_db.csv`.

## Ví dụ thực tế

### Ví dụ 1: Chế độ daemon end-to-end 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Sau đó thả hoặc đồng bộ video vào source directory đã cấu hình và theo dõi log trên các tmux pane.

### Ví dụ 2: Chạy lại ép file khớp từ khóa 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Ví dụ 3: Test local không publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Development Notes

- Không có file manifest phụ thuộc cố định (`requirements.txt` / `pyproject.toml`) ở root repository.
- Runtime phụ thuộc nhiều vào shell tools Linux và quy ước đường dẫn cục bộ.
- Các script hiện tại `source` config shell động (`autopub.config`); giữ nguyên cú pháp biến tương thích shell.
- Queue/lock dựa vào `flock`; tránh sửa đổi làm giảm tính atomic của cập nhật queue.
- Chi tiết API contract suy ra từ code client; triển khai server nằm ngoài repository này.
- Thư mục `i18n/` đã tồn tại nhưng tài liệu dịch chưa được duy trì đầy đủ trong chu kỳ này.
- Các file artifact xử lý (`queue_list.txt`, `temp_queue.txt`, …) thường được sinh/tạo động theo runtime và có thể khác theo môi trường.

## 🧱 Legacy Name Compatibility (Preserved)

Tài liệu trước từng dùng tên component đã đổi tên. Tên file repository hiện tại vẫn giữ như dưới đây.

| Nhãn tài liệu cũ | File repository hiện tại |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Nếu bạn `cd autopub_monitor`, các lệnh kiểu docs cũ sau đây tương đương:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 🛠️ Khắc phục sự cố

| Triệu chứng | Cần kiểm tra |
|---|---|
| `Miniconda not found at ~/miniconda3` | Cài Miniconda hoặc cập nhật `CONDA_DIR` trong `autopub.config`. |
| `inotifywait: command not found` | Cài `inotify-tools`. |
| Lỗi `ffprobe`/`ffmpeg` | Cài `ffmpeg`; kiểm tra tính toàn vẹn file đầu vào. |
| Video không được đưa vào queue lặp lại | Kiểm tra `checked_list.txt`, `temp_queue.txt`, và log từ `monitor_autopublish.sh`. |
| Queue bị kẹt hoặc có concern về race | Kiểm tra `queue.lock`, `queue_list.txt`, và các tiến trình đang chạy bằng `flock`. |
| Lỗi API upload/process/publish | Xác minh `APP_API_BASE_URL` và đường dẫn endpoint trong `autopub.config`. |
| Dịch vụ tmux không khởi động | Xác nhận `tmux has-session` hoạt động và script có quyền thực thi. |

## 🗺️ Roadmap

- Thêm quản lý dependency đã khóa (`requirements.txt` hoặc `pyproject.toml`).
- Thêm CI check cho shell/Python lint và một số integration test cơ bản.
- Bổ sung docs cho API contract và giả định triển khai.
- Mở rộng `i18n/` với các README đã được duy trì dịch thuật.
- Cải thiện observability (log có cấu trúc và health check).

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh.

Luồng khuyến nghị:

1. Fork và tạo branch tính năng.
2. Giữ thay đổi nhỏ gọn và tập trung (script + docs cùng đi đôi).
3. Kiểm tra trên môi trường Linux đã có đủ công cụ hệ thống bắt buộc.
4. Tạo pull request kèm ghi chú tái hiện/kiểm thử rõ ràng.

Nếu hành vi thay đổi, cập nhật cả:

- `README.md`
- `PROJECT_STRUCTURE.md` và/hoặc `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Liên hệ

For questions, bug reports, and feature requests:

- Tạo issue tại [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 Lời cảm ơn

- Được xây dựng quanh công cụ gốc Linux (`tmux`, `inotify`, `rsync`, `ffmpeg`) cho tự động hóa chạy liên tục, đáng tin cậy.
- Cảm ơn các contributor và người dùng đã hỗ trợ cải tiến liên tục.

## 📄 Giấy phép

Apache License 2.0 - Xem [LICENSE](LICENSE) để biết chi tiết.
