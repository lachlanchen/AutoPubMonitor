[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
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

> 여러 플랫폼에 걸쳐 영상 콘텐츠를 자동으로 모니터링하고 처리 및 게시하는 시스템.

| 기대 항목 | 상세 |
|---|---|
| 실행 모델 | `tmux` 기반 Linux 우선 자동화, 선택적 `systemd`, 큐 락 사용 |
| 큐 설계 | 파일 감시 → 큐 → 워커 반복, 영속적인 상태 추적 포함 |
| 확장성 | 플랫폼 어댑터용 셸 오케스트레이션 + Python 게시 클라이언트 |
| 주요 진입점 | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

<a id="documentation-map"></a>
## 🧭 문서 맵

| 섹션 | 왜 중요할까요 |
|---|---|
| [한눈에 보기: 프로젝트](#project-at-a-glance) | 런타임 모델과 목표를 빠르게 파악 |
| [설치](#installation) | 클론부터 실행 가능한 서비스까지 진행 |
| [설정](#configuration) | 스크립트 단위 중요 설정을 한눈에 확인 |
| [사용법](#usage) | 시작, 중단, 큐 처리 및 수동 실행 흐름 |
| [시스템 구성 요소](#system-components) | 셸과 Python의 역할 구분 |
| [문제 해결](#troubleshooting) | 기동 및 큐 이슈를 빠르게 해결 |
| [로드맵](#roadmap) | 단기 개선 계획 확인 |
| [기여](#contributing) | 안전한 기여 방식 이해 |

<a id="quick-start-at-a-glance"></a>
## 🧭 빠른 시작 한눈에 보기

| 목표 | 명령 | 참고 |
|---|---|---|
| 모니터링 파이프라인 시작 | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | watcher + 큐 + 동기화 + 수동 패널 시작 |
| 모든 서비스 중지 | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | 깨끗한 종료와 패널 정리 |
| 패턴으로 큐 등록 | `./autopub_monitor/queue_file_utility.sh "pattern"` | 일치하는 파일을 처리 큐에 추가 |
| 단일 파일 처리 | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | 기본 게시/처리 설정 사용 |

<a id="project-at-a-glance"></a>
## 🎯 프로젝트 한눈에 보기

| 항목 | 상세 |
|---|---|
| 실행 대상 | Linux, `tmux` 오케스트레이션 및 선택적 `systemd` |
| 큐 모델 | 파일 감시 → 큐 → 워커 스크립트 → 게시 파이프라인 |
| 주요 진입점 | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| 상태 추적 | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

<a id="overview"></a>
## 🔎 개요

AutoPubMonitor는 영상 콘텐츠 처리와 다중 플랫폼 게시를 위한 Linux 지향 자동화 파이프라인입니다. 이 시스템은 새 영상 파일을 감지한 뒤, 호환성 복구, 선택적 보강, API 기반 자막/번역 처리 단계를 거쳐 구성된 플랫폼에 게시물을 업로드합니다.

런타임은 셸 오케스트레이션(`tmux`, `inotifywait`, `rsync`, `flock`)으로 동작하며, Python 처리 클라이언트와 CSV/텍스트 기반 상태 추적을 결합합니다.

<a id="key-features"></a>
## ⚡ 핵심 기능

| 기능 | 상세 |
|---|---|
| 자동 파일 탐지 | 새 영상 콘텐츠를 디렉터리에서 감지 |
| 큐 관리 | 파일을 제어된 순차 방식으로 처리 |
| 영상 처리 | 길이·포맷 검사, 업로드 전 준비 |
| 다중 플랫폼 게시 | XiaoHongShu, Bilibili, Douyin, ShiPinHao, YouTube 지원 |
| 캐시 시스템 | 처리 결과 캐시로 속도와 비용 최적화 |
| 파일 동기화 | 시스템 간 파일 이동 처리 |
| 중앙 설정 | 모든 경로와 설정을 단일 config 파일에서 관리 |
| 손쉬운 설치 | 단일 스크립트로 전체 시스템 설치 |
| 영상 호환성 복구 | FFmpeg 점검과 선택적 HandBrakeCLI 폴백 |
| 서비스형 동작 | `tmux` 세션 + 선택적 `systemd` 서비스 |
| 다국어 문서 | 루트 언어 링크와 `i18n/` 번역 지원 |

<a id="repository-structure"></a>
## 🗂️ 저장소 구조

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

<a id="system-components"></a>
## 시스템 구성 요소

### 핵심 처리

| 구성 요소 | 역할 |
|---|---|
| `autopub.py` | 업로드/처리/게시 오케스트레이션을 담당하는 주 처리 엔진 |
| `process_video.py` | 업로드·처리·결과 반영을 수행하는 영상 처리 클라이언트 |
| `video_utils.py` / `handbrake.py` | 업로드 전 호환성 검사와 복구 |

### 큐 관리

| 구성 요소 | 역할 |
|---|---|
| `process_queue.sh` | `flock` 잠금과 재시도 루프로 동작하는 큐 소비자 |
| `queue_file_utility.sh` | 경로 또는 파일명 패턴으로 수동 큐 추가 |

### 서비스 관리

| 구성 요소 | 역할 |
|---|---|
| `autopub_monitor_tmux_session.sh` | 다중 패널 tmux 서비스를 시작/중지 |
| `autopub.sh` | `autopub.py`용 Conda/부트스트랩 래퍼 |
| `autopub_sync.sh` | 원격/동기화된 소스 디렉터리에서 파일 동기화 |
| `monitor_autopublish.sh` | `inotify` 기반으로 새 파일 감지 후 큐 등록 |

### 유틸리티

| 구성 요소 | 역할 |
|---|---|
| `window_info_utility.py` | `xdotool` 기반 활성 창 유틸리티(선택 항목) |
| `autopub.config` | 중앙 설정 파일 |
| `install_autopub_monitor.sh` | 설치 + systemd 설정 도우미 |

<a id="prerequisites"></a>
## 선행 조건

| 요구사항 | 비고 |
|---|---|
| bash를 지원하는 Linux 환경 | 기본 실행 대상 |
| Python 3.8+ | 설치 스크립트가 Python 3.8 conda 환경을 생성 |
| `${HOME}/miniconda3`에 Miniconda | 스크립트의 기본 기대 경로 |
| `ffmpeg` / `ffprobe` | 영상 검증/처리에 필수 |
| `tmux` | 서비스 오케스트레이션 |
| `inotify-tools` | 파일 이벤트 모니터링 (`inotifywait`) |
| `rsync` | 디렉터리·시스템 간 동기화 |
| `python3-pip` | Python 패키지 설치 |
| 선택: `HandBrakeCLI` | 문제가 있는 영상 복구 시 권장 |
| 선택: `xdotool` | `window_info_utility.py` 사용 시 필요 |

리포지토리 스크립트에서 사용하는 Python 패키지:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

<a id="installation"></a>
## 설치

### 🚀 자동 설치(스크립트 기반)

레포지토리 루트에서 실행:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

설치 스크립트는 다음을 수행합니다:

- `tmux`, `inotify-tools`, `ffmpeg`, `python3-pip` 같은 apt 의존성 설치
- conda 환경 `autopub-video` 생성/활용
- Python 패키지 설치 (`requests`, `requests_toolbelt`, `selenium`)
- 런타임 디렉터리와 상태 파일 생성
- `autopub-monitor.service` 설치 및 활성화

### 🧩 서비스 활성화/시작 (설치 스크립트가 자동으로 하지 않은 경우)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 수동 설정

1. 환경에 맞게 `autopub_monitor/autopub.config`를 검토하고 수정합니다.
2. 환경을 생성·활성화합니다:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 스크립트 실행 권한을 부여합니다:

```bash
chmod +x autopub_monitor/*.sh
```

> 가정: 런타임 상태 파일(예: `queue.lock`, `temp_queue.txt`, `checked_list.txt`)은 시작/설치 흐름에서 이미 존재하거나 생성되어야 합니다.

<a id="configuration"></a>
## 설정

주요 설정 파일: `autopub_monitor/autopub.config`

중요 설정 항목:

- 데이터 디렉터리: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 동기화 소스 디렉터리: `JIANGUOYUN_*`
- 상태 파일: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- 잠금 파일: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 설정: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 설정: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

참고:

- 기본 구성은 현재 앱 API 모드(`USE_APP_API="true"`)를 사용하며, `APP_API_BASE_URL`로 엔드포인트 URL을 구성합니다.
- 레거시 엔드포인트는 참고용으로 여전히 남아 있습니다.
- 큐 및 락 파일명은 모든 스크립트가 동일한 설정 키를 참조하면 위험 없이 변경 가능합니다.

<a id="usage"></a>
## 사용법

### ▶️ 서비스 시작

레포지토리 루트에서:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

이 명령은 다음 서비스를 시작합니다:

- 파일 동기화 서비스
- 디렉터리 감시 서비스
- 큐 처리 서비스
- 수동 명령 패널
- 전사 rsync 세션 (`am-transcription-sync`)

### ⏹️ 서비스 중지

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 수동 큐 관리

```bash
# 패턴 일치로 추가
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# 전체 경로로 추가
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# 자동 확인 비활성화(선택 프롬프트 없음)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 수동 영상 처리

```bash
# 기본 래퍼 기본값으로 특정 파일 처리
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 게시 타깃을 명시한 직접 CLI 호출
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# 캐시 옵션 + 진행률 표시
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 게시 없이 업로드/처리
python autopub_monitor/autopub.py --no-pub --path "/path/to/video.mp4"
```

## CLI 옵션 (`autopub.py`)

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

동작 참고:

- 앱 API 모드(`USE_APP_API=true`)에서는 게시 플래그를 명시적으로 전달하지 않으면 게시가 기본 비활성화됩니다.

<a id="command-palette"></a>
## 🎛️ 커맨드 팔레트

| 영역 | 예시 |
|---|---|
| 서비스 제어 | `autopub_monitor_tmux_session.sh start/stop` |
| 큐 동작 | `queue_file_utility.sh`, `process_queue.sh` |
| 파일 동기화/처리 | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python 실행 경로 | `autopub.py`, `process_video.py`, `video_utils.py` |

<a id="processing-architecture"></a>
## 처리 아키텍처

1. **파일 감지**: `monitor_autopublish.sh`가 `close_write`/`moved_to` 이벤트를 감시합니다.
2. **큐 등록**: 유효한 파일은 `flock`으로 `queue_list.txt`에 추가됩니다.
3. **처리**: `process_queue.sh`가 큐 항목을 소비하고 `autopub.sh`를 호출합니다.
4. **업로드/처리/게시**: `autopub.py`와 `process_video.py`가 구성된 API 엔드포인트를 호출합니다.
5. **추적**: 처리된 파일은 `processed.csv`, 발견 파일은 `videos_db.csv`에 기록됩니다.

<a id="practical-examples"></a>
## 실전 예시

### 예시 1: 데몬 엔드투엔드 모드 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

그다음 구성한 소스 디렉터리에 영상을 넣거나 동기화하고 tmux 패널에서 로그를 확인합니다.

### 예시 2: 일치 파일 강제 재실행 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 예시 3: 게시 없이 로컬 테스트 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

<a id="development-notes"></a>
## 🧠 개발 노트

- 루트에는 고정된 의존성 목록(`requirements.txt` / `pyproject.toml`)이 없습니다.
- 런타임은 Linux 셸 도구와 로컬 경로 규약에 강하게 의존합니다.
- 현재 스크립트는 `autopub.config`를 동적으로 source 하므로 shell 호환 변수 표현을 유지하세요.
- 큐와 락 동작은 `flock`에 의존하므로 원자성 큐 갱신을 약화시키는 변경은 피하십시오.
- API 계약은 클라이언트 코드 기준으로 추론해야 하며, 서버 구현은 이 저장소 외부입니다.
- `i18n/` 디렉터리가 존재하지만 번역 문서는 현재 사이클에서 완전히 유지되지 않았습니다.
- 처리 산출물 파일(`queue_list.txt`, `temp_queue.txt` 등)은 런타임에서 생성/관리되며 환경에 따라 달라질 수 있습니다.

<a id="legacy-compat"></a>
## 🧱 레거시 이름 호환성 (유지됨)

이전 문서에서는 구성 요소 레이블이 달랐습니다. 현재 저장소 파일명은 아래와 같습니다.

| 이전 문서 레이블 | 현재 저장소 파일 |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

`cd autopub_monitor` 기준으로 이전 문서의 명령을 사용할 때는 다음이 대응됩니다.

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

<a id="troubleshooting"></a>
## 🛠️ 문제 해결

| 증상 | 점검 항목 |
|---|---|
| `Miniconda not found at ~/miniconda3` | Miniconda를 설치하거나 `autopub.config`의 `CONDA_DIR`를 업데이트 |
| `inotifywait: command not found` | `inotify-tools` 설치 |
| `ffprobe`/`ffmpeg` 실패 | `ffmpeg` 설치 및 입력 파일 무결성 확인 |
| 동영상이 반복해서 큐에 안 들어감 | `checked_list.txt`, `temp_queue.txt`, `monitor_autopublish.sh` 로그 확인 |
| 큐가 멈추거나 레이스 이슈가 의심됨 | `queue.lock`, `queue_list.txt`, `flock` 사용 중인 프로세스 점검 |
| API 업로드/처리/게시 오류 | `autopub.config`의 `APP_API_BASE_URL` 및 엔드포인트 경로 확인 |
| tmux 서비스가 시작되지 않음 | `tmux has-session` 동작 여부와 스크립트 실행 권한 확인 |

<a id="roadmap"></a>
## 🗺️ 로드맵

- `requirements.txt` 또는 `pyproject.toml` 기반 의존성 고정화 추가
- Shell/Python lint 및 기본 통합 테스트를 포함한 CI 검증 추가
- API 계약과 배포 가정에 대한 문서 보강
- `i18n/` 디렉터리에 유지 관리되는 번역 README 확장
- 가시성 개선(구조화 로그 및 health check)

<a id="contributing"></a>
## 🤝 기여

기여를 환영합니다.

권장 워크플로:

1. 포크하고 기능 브랜치를 만드세요.
2. 변경은 작고 집중적으로 유지하세요(스크립트 + 문서 업데이트 함께).
3. 필수 시스템 도구가 있는 Linux 환경에서 검증하세요.
4. 재현/테스트 노트를 포함해 Pull Request를 제출하세요.

동작이 바뀌면 함께 업데이트하세요:

- `README.md`
- `PROJECT_STRUCTURE.md` 및/또는 `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Contact

질문, 버그 리포트, 기능 요청은 아래로 보내주세요:

- Open an issue at [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

<a id="acknowledgements"></a>
## 🙌 Acknowledgements

- Linux 네이티브 도구(`tmux`, `inotify`, `rsync`, `ffmpeg`)를 중심으로 신뢰성 높은 장기 자동화를 구성했습니다.
- 지속적인 개선에 기여한 기여자와 사용자에게 감사합니다.

<a id="license"></a>
## 📄 License

Apache License 2.0 - 자세한 내용은 [LICENSE](../LICENSE)에서 확인하세요.
