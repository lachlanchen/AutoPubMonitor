[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#yeu-cau-tien-quyet)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#yeu-cau-tien-quyet)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#cach-su-dung)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

Một hệ thống tự động để giám sát, xử lý và xuất bản nội dung video lên nhiều nền tảng.

## Tổng quan

AutoPubMonitor là một pipeline tự động hóa hướng Linux dành cho xử lý nội dung video và xuất bản đa nền tảng. Hệ thống theo dõi tệp video mới, xử lý qua các bước gồm sửa tương thích, tăng cường tùy chọn, xử lý liên quan đến chép lời/dịch thuật qua API, rồi xuất bản kết quả lên các nền tảng đã cấu hình.

Runtime được điều phối bằng shell (`tmux`, `inotifywait`, `rsync`, `flock`), kết hợp các client xử lý Python và cơ chế theo dõi trạng thái bằng CSV/text.

## Tính năng chính

| Khả năng | Chi tiết |
|---|---|
| Tự động phát hiện tệp | Theo dõi thư mục để phát hiện nội dung video mới |
| Quản lý hàng đợi xử lý | Xử lý video tuần tự, có kiểm soát |
| Xử lý video | Kiểm tra độ dài, định dạng và chuẩn bị video |
| Xuất bản đa nền tảng | Hỗ trợ XiaoHongShu, Bilibili, Douyin, ShiPinHao và YouTube |
| Hệ thống cache | Tối ưu xử lý bằng cách lưu kết quả tạm |
| Đồng bộ tệp | Xử lý luồng di chuyển tệp giữa các hệ thống |
| Cấu hình tập trung | Tất cả đường dẫn và cài đặt nằm trong một tệp cấu hình |
| Cài đặt dễ dàng | Một script để thiết lập toàn bộ hệ thống |
| Sửa tương thích video | Dùng kiểm tra FFmpeg và fallback HandBrakeCLI (tùy chọn) |
| Vận hành theo dịch vụ | Phiên `tmux` + dịch vụ `systemd` (tùy chọn) |

## Cấu trúc kho mã

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

## Thành phần hệ thống

### Xử lý lõi

| Thành phần | Vai trò |
|---|---|
| `autopub.py` | Engine xử lý chính, điều phối upload/process/publish |
| `process_video.py` | Client xử lý video cho upload, xử lý và nhận kết quả |
| `video_utils.py` / `handbrake.py` | Kiểm tra và sửa tương thích trước khi upload |

### Quản lý hàng đợi

| Thành phần | Vai trò |
|---|---|
| `process_queue.sh` | Consumer hàng đợi với khóa `flock` và vòng lặp retry |
| `queue_file_utility.sh` | Nạp thủ công vào hàng đợi theo đường dẫn hoặc mẫu tên tệp |

### Quản lý dịch vụ

| Thành phần | Vai trò |
|---|---|
| `autopub_monitor_tmux_session.sh` | Khởi động/dừng dịch vụ tmux nhiều pane |
| `autopub.sh` | Wrapper Conda/bootstrap cho `autopub.py` |
| `autopub_sync.sh` | Đồng bộ tệp từ đường dẫn Nutstore/Jianguoyun |
| `monitor_autopublish.sh` | Trình theo dõi `inotify` để phát hiện tệp mới và đưa vào hàng đợi |

### Tiện ích

| Thành phần | Vai trò |
|---|---|
| `window_info_utility.py` | Tiện ích cửa sổ đang hoạt động dùng `xdotool` (tùy chọn) |
| `autopub.config` | Tệp cấu hình trung tâm |
| `install_autopub_monitor.sh` | Trợ lý cài đặt + thiết lập systemd |

## Yêu cầu tiên quyết

| Yêu cầu | Ghi chú |
|---|---|
| Môi trường Linux với bash | Mục tiêu runtime chính |
| Python 3.8+ | Trình cài đặt hiện tạo môi trường conda Python 3.8 |
| Miniconda tại `${HOME}/miniconda3` | Đường dẫn mặc định mà script mong đợi |
| `ffmpeg` / `ffprobe` | Bắt buộc cho kiểm tra/xử lý video |
| `tmux` | Điều phối dịch vụ |
| `inotify-tools` | Theo dõi sự kiện tệp (`inotifywait`) |
| `rsync` | Đồng bộ giữa thư mục/hệ thống |
| `python3-pip` | Cài đặt gói Python |
| Tùy chọn: `HandBrakeCLI` | Khuyến nghị để sửa video có vấn đề |
| Tùy chọn: `xdotool` | Cần cho `window_info_utility.py` |

Các gói Python được dùng trong script của repo gồm:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Cài đặt

### 🚀 Cài đặt tự động (script)

Từ thư mục gốc của repository:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

Trình cài đặt sẽ:

- Cài các phụ thuộc apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Tạo/dùng môi trường conda `autopub-video`
- Cài gói Python (`requests`, `requests_toolbelt`, `selenium`)
- Tạo thư mục runtime và tệp trạng thái
- Cài đặt và bật `autopub-monitor.service`

### 🧩 Bật/khởi động dịch vụ (nếu chưa được trình cài đặt bật)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Thiết lập thủ công

1. Xem lại và chỉnh sửa `autopub_monitor/autopub.config` theo môi trường của bạn.
2. Tạo và kích hoạt môi trường:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Cấp quyền thực thi cho script:

```bash
chmod +x autopub_monitor/*.sh
```

## Cấu hình

Tệp cấu hình chính: `autopub_monitor/autopub.config`

Các cài đặt quan trọng gồm:

- Thư mục dữ liệu: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Thư mục nguồn đồng bộ: `JIANGUOYUN_*`
- Tệp trạng thái: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Tệp khóa: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Cài đặt API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Cài đặt Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Lưu ý:

- Cấu hình mặc định hiện ưu tiên chế độ app API (`USE_APP_API="true"`) và tạo URL endpoint từ `APP_API_BASE_URL`.
- Các endpoint cũ vẫn còn trong config để tham khảo.

## Cách sử dụng

### ▶️ Khởi động dịch vụ

Từ thư mục gốc của repository:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Lệnh này sẽ khởi chạy:

- Dịch vụ đồng bộ tệp
- Dịch vụ theo dõi thư mục
- Dịch vụ xử lý hàng đợi
- Pane lệnh thủ công
- Phiên rsync transcription (`am-transcription-sync`)

### ⏹️ Dừng dịch vụ

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Quản lý hàng đợi thủ công

```bash
# Thêm theo mẫu khớp
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Thêm theo đường dẫn đầy đủ
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Thêm với tự động xác nhận (không hiện prompt chọn)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Xử lý video thủ công

```bash
# Xử lý một tệp cụ thể bằng thiết lập mặc định của wrapper
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# CLI trực tiếp với đích publish cụ thể
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Tùy chọn cache + hiển thị tiến trình
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

Ghi chú hành vi:

- Trong chế độ app API (`USE_APP_API=true`), mặc định sẽ tắt publish trừ khi bạn truyền rõ các cờ publish.

## Kiến trúc xử lý

1. **Phát hiện tệp**: `monitor_autopublish.sh` theo dõi sự kiện `close_write`/`moved_to`.
2. **Hàng đợi**: Tệp hợp lệ được thêm vào `queue_list.txt` bằng `flock`.
3. **Xử lý**: `process_queue.sh` lấy phần tử từ hàng đợi và gọi `autopub.sh`.
4. **Upload/Process/Publish**: `autopub.py` và `process_video.py` gọi các endpoint API đã cấu hình.
5. **Theo dõi**: Tệp đã xử lý ghi vào `processed.csv`, tệp đã phát hiện ghi vào `videos_db.csv`.

## Ví dụ thực tế

### Ví dụ 1: Chế độ daemon end-to-end 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Sau đó thả hoặc đồng bộ video vào thư mục nguồn đã cấu hình và theo dõi log trong các pane tmux.

### Ví dụ 2: Buộc chạy lại các tệp khớp điều kiện 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Ví dụ 3: Kiểm thử cục bộ không publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Ghi chú phát triển

- Chưa có manifest phụ thuộc được ghim phiên bản (`requirements.txt` / `pyproject.toml`) ở thư mục gốc repo.
- Runtime phụ thuộc mạnh vào công cụ shell trên Linux và quy ước đường dẫn cục bộ.
- Script hiện nạp cấu hình shell động (`autopub.config`); cần giữ biểu thức biến tương thích shell.
- Cơ chế hàng đợi và khóa dựa vào `flock`; tránh chỉnh sửa làm suy yếu tính nguyên tử khi cập nhật hàng đợi.
- Chi tiết hợp đồng API được suy ra từ mã client; phần triển khai server nằm ngoài repository này.
- Thư mục `i18n/` đã tồn tại nhưng tài liệu ngôn ngữ chưa được điền đầy đủ trong chu kỳ bản nháp này.

## Tương thích tên cũ (giữ nguyên)

Tài liệu trước đây dùng các nhãn thành phần đã đổi tên. Tên tệp hiện tại trong repository vẫn như bên dưới.

| Nhãn trong tài liệu cũ | Tệp hiện tại trong repository |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Để tiện dùng, nếu bạn `cd autopub_monitor`, các lệnh kiểu tài liệu cũ dưới đây tương đương theo ngữ cảnh vị trí:

```bash
# Kiểu tài liệu cũ (các lệnh tương đương, phụ thuộc vị trí thư mục)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Khắc phục sự cố

| Triệu chứng | Cần kiểm tra |
|---|---|
| `Miniconda not found at ~/miniconda3` | Cài Miniconda hoặc cập nhật `CONDA_DIR` trong `autopub.config`. |
| `inotifywait: command not found` | Cài `inotify-tools`. |
| Lỗi `ffprobe`/`ffmpeg` | Cài `ffmpeg`; kiểm tra tính toàn vẹn của tệp đầu vào. |
| Video liên tục không vào hàng đợi | Kiểm tra `checked_list.txt`, `temp_queue.txt`, và log theo dõi từ `monitor_autopublish.sh`. |
| Hàng đợi bị kẹt hoặc có nguy cơ race | Kiểm tra `queue.lock`, `queue_list.txt`, và tiến trình đang dùng `flock`. |
| Lỗi API upload/process/publish | Xác minh `APP_API_BASE_URL` và đường dẫn endpoint trong `autopub.config`. |
| Dịch vụ tmux không khởi động | Xác nhận `tmux has-session` hoạt động và script đã có quyền thực thi. |

## Lộ trình

- Thêm quản lý phụ thuộc có ghim phiên bản (`requirements.txt` hoặc `pyproject.toml`).
- Thêm kiểm tra CI cho lint shell/Python và test tích hợp cơ bản.
- Bổ sung tài liệu về hợp đồng API và giả định triển khai.
- Mở rộng `i18n/` với các README dịch được bảo trì.
- Cải thiện khả năng quan sát (log có cấu trúc và health check).

## Đóng góp

Rất hoan nghênh đóng góp.

Quy trình khuyến nghị:

1. Fork và tạo nhánh tính năng.
2. Giữ thay đổi nhỏ và tập trung (cập nhật script + tài liệu cùng nhau).
3. Xác thực trên môi trường Linux với đầy đủ công cụ hệ thống bắt buộc.
4. Gửi pull request kèm ghi chú tái hiện/test rõ ràng.

Nếu hành vi thay đổi, hãy cập nhật cả:

- `README.md`
- `PROJECT_STRUCTURE.md` và/hoặc `autopub_monitor/README.md`

## Hỗ trợ và tài trợ

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

(Trích từ `.github/FUNDING.yml`)

## Lời cảm ơn

- Được xây dựng xoay quanh bộ công cụ Linux-native (`tmux`, `inotify`, `rsync`, `ffmpeg`) để vận hành tự động hóa dài hạn ổn định.
- Cảm ơn các cộng tác viên và người dùng đã hỗ trợ cải tiến liên tục.

## Giấy phép

Apache License 2.0 - Xem [LICENSE](../LICENSE) để biết chi tiết.
