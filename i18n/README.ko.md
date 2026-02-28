[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#사전-요구사항)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#사전-요구사항)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#사용법)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

여러 플랫폼에 비디오 콘텐츠를 모니터링, 처리, 게시하기 위한 자동화 시스템입니다.

## 개요

AutoPubMonitor는 Linux 중심의 비디오 콘텐츠 처리 및 멀티 플랫폼 게시 자동화 파이프라인입니다. 시스템은 새 비디오 파일을 감지하고, 호환성 복구, 선택적 보강, API를 통한 전사/번역 관련 처리 단계를 수행한 뒤, 설정된 플랫폼에 결과를 게시합니다.

런타임은 Python 처리 클라이언트와 CSV/텍스트 상태 추적을 기반으로 쉘(`tmux`, `inotifywait`, `rsync`, `flock`)에서 오케스트레이션됩니다.

## 주요 기능

| 기능 | 상세 |
|---|---|
| 자동 파일 감지 | 새 비디오 콘텐츠를 디렉터리에서 감지 |
| 처리 큐 관리 | 비디오를 제어된 순차 방식으로 처리 |
| 비디오 처리 | 길이/포맷을 점검하고 게시용으로 준비 |
| 멀티 플랫폼 게시 | XiaoHongShu, Bilibili, Douyin, ShiPinHao, YouTube 지원 |
| 캐시 시스템 | 결과 캐싱으로 처리 효율 최적화 |
| 파일 동기화 | 시스템 간 파일 이동 처리 |
| 중앙화된 설정 | 단일 설정 파일에 경로/설정 통합 |
| 쉬운 설치 | 전체 시스템 설치를 단일 스크립트로 제공 |
| 비디오 호환성 복구 | FFmpeg 점검 및 선택적 HandBrakeCLI 폴백 사용 |
| 서비스 지향 운영 | `tmux` 세션 + 선택적 `systemd` 서비스 |

## 저장소 구조

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

## 시스템 구성 요소

### 핵심 처리

| 구성 요소 | 역할 |
|---|---|
| `autopub.py` | 업로드/처리/게시 오케스트레이션을 담당하는 메인 처리 엔진 |
| `process_video.py` | 업로드, 처리, 결과 핸들링을 수행하는 비디오 처리 클라이언트 |
| `video_utils.py` / `handbrake.py` | 업로드 전 호환성 점검 및 복구 |

### 큐 관리

| 구성 요소 | 역할 |
|---|---|
| `process_queue.sh` | `flock` 락과 재시도 루프를 사용하는 큐 컨슈머 |
| `queue_file_utility.sh` | 경로 또는 파일명 패턴으로 수동 큐 입력 |

### 서비스 관리

| 구성 요소 | 역할 |
|---|---|
| `autopub_monitor_tmux_session.sh` | 다중 pane tmux 서비스 시작/중지 |
| `autopub.sh` | `autopub.py`용 Conda/부트스트랩 래퍼 |
| `autopub_sync.sh` | Nutstore/Jianguoyun 경로에서 파일 동기화 |
| `monitor_autopublish.sh` | 새 파일 감지 및 큐잉을 위한 `inotify` 감시기 |

### 유틸리티

| 구성 요소 | 역할 |
|---|---|
| `window_info_utility.py` | `xdotool` 기반 활성 창 유틸리티(선택 사항) |
| `autopub.config` | 중앙 설정 파일 |
| `install_autopub_monitor.sh` | 설치 + systemd 설정 도우미 |

## 사전 요구사항

| 요구사항 | 비고 |
|---|---|
| bash가 가능한 Linux 환경 | 기본 런타임 대상 |
| Python 3.8+ | 설치 스크립트는 현재 Python 3.8 conda 환경 생성 |
| `${HOME}/miniconda3`의 Miniconda | 스크립트가 기본적으로 기대하는 경로 |
| `ffmpeg` / `ffprobe` | 비디오 검증/처리에 필수 |
| `tmux` | 서비스 오케스트레이션 |
| `inotify-tools` | 파일 이벤트 모니터링(`inotifywait`) |
| `rsync` | 디렉터리/시스템 간 동기화 |
| `python3-pip` | Python 패키지 설치 |
| 선택 사항: `HandBrakeCLI` | 문제 있는 비디오 복구에 권장 |
| 선택 사항: `xdotool` | `window_info_utility.py` 실행에 필요 |

저장소 스크립트에서 사용하는 Python 패키지는 다음과 같습니다.

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## 설치

### 🚀 자동 설치(스크립트)

저장소 루트에서 실행:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

설치 스크립트가 수행하는 작업:

- apt 의존성 설치(`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- conda 환경 `autopub-video` 생성/사용
- Python 패키지 설치(`requests`, `requests_toolbelt`, `selenium`)
- 런타임 디렉터리 및 상태 파일 생성
- `autopub-monitor.service` 설치 및 활성화

### 🧩 서비스 활성화/시작(설치 스크립트에서 아직 활성화하지 않은 경우)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 수동 설정

1. 환경에 맞게 `autopub_monitor/autopub.config`를 검토하고 수정합니다.
2. 환경을 생성하고 활성화합니다.

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. 스크립트에 실행 권한을 부여합니다.

```bash
chmod +x autopub_monitor/*.sh
```

## 설정

기본 설정 파일: `autopub_monitor/autopub.config`

중요 설정 항목:

- 데이터 디렉터리: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 동기화 소스 디렉터리: `JIANGUOYUN_*`
- 상태 파일: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- 락 파일: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 설정: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 설정: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

참고:

- 현재 기본 설정은 app API 모드(`USE_APP_API="true"`)를 우선 사용하며, `APP_API_BASE_URL`을 기반으로 엔드포인트 URL을 구성합니다.
- 레거시 엔드포인트도 참고용으로 설정 파일에 남아 있습니다.

## 사용법

### ▶️ 서비스 시작

저장소 루트에서 실행:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

다음 서비스가 시작됩니다.

- 파일 동기화 서비스
- 디렉터리 감시 서비스
- 큐 처리 서비스
- 수동 명령 pane
- 전사 rsync 세션(`am-transcription-sync`)

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

# 자동 확인으로 추가(선택 프롬프트 없음)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 수동 비디오 처리

```bash
# 래퍼 기본값으로 특정 파일 처리
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 게시 대상 플래그를 지정한 직접 CLI 실행
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# 캐시 옵션 + 진행률 시각화
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 게시 없이 업로드/처리만 수행
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

- app API 모드(`USE_APP_API=true`)에서는 게시 플래그를 명시적으로 전달하지 않으면 기본적으로 게시가 비활성화됩니다.

## 처리 아키텍처

1. **파일 감지**: `monitor_autopublish.sh`가 `close_write`/`moved_to` 이벤트를 감시합니다.
2. **큐잉**: 유효한 파일을 `flock`으로 보호하면서 `queue_list.txt`에 추가합니다.
3. **처리**: `process_queue.sh`가 큐 항목을 소비하고 `autopub.sh`를 호출합니다.
4. **업로드/처리/게시**: `autopub.py`와 `process_video.py`가 설정된 API 엔드포인트를 호출합니다.
5. **추적**: 처리 완료 파일은 `processed.csv`에, 발견된 파일은 `videos_db.csv`에 기록됩니다.

## 실전 예시

### 예시 1: 엔드투엔드 데몬 모드 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

이후 설정된 소스 디렉터리에 비디오를 드롭하거나 동기화하고, tmux pane 로그를 모니터링합니다.

### 예시 2: 일치 파일 강제 재실행 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 예시 3: 게시 없이 로컬 테스트 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 개발 참고 사항

- 저장소 루트에는 고정 의존성 매니페스트(`requirements.txt` / `pyproject.toml`)가 없습니다.
- 런타임은 Linux 셸 도구와 로컬 경로 관례에 강하게 의존합니다.
- 현재 스크립트는 셸 설정(`autopub.config`)을 동적으로 source 하므로, 셸 호환 변수 표현식을 유지해야 합니다.
- 큐 및 락 시맨틱은 `flock`에 의존하므로, 원자적 큐 업데이트를 약화시키는 변경은 피해야 합니다.
- API 계약 상세는 클라이언트 코드에서 추론되며, 서버 구현은 이 저장소 외부에 있습니다.
- `i18n/` 디렉터리는 존재하지만, 이번 초안 사이클에서는 언어 문서가 아직 채워지지 않았습니다.

## 레거시 이름 호환성(보존)

기존 문서에는 이름이 변경된 컴포넌트 레이블이 사용되었습니다. 현재 저장소 파일명은 아래 표와 같습니다.

| 이전 문서 레이블 | 현재 저장소 파일 |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

편의를 위해 `cd autopub_monitor` 상태라면, 구버전 문서 스타일 명령은 아래와 같이 대응됩니다.

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 문제 해결

| 증상 | 확인 사항 |
|---|---|
| `Miniconda not found at ~/miniconda3` | Miniconda를 설치하거나 `autopub.config`의 `CONDA_DIR`을 수정하세요. |
| `inotifywait: command not found` | `inotify-tools`를 설치하세요. |
| `ffprobe`/`ffmpeg` 실패 | `ffmpeg`를 설치하고 입력 파일 무결성을 확인하세요. |
| 비디오가 반복적으로 큐에 들어가지 않음 | `checked_list.txt`, `temp_queue.txt`, `monitor_autopublish.sh` 로그를 확인하세요. |
| 큐가 멈춤/레이스 우려 | `queue.lock`, `queue_list.txt`, `flock` 사용 중인 활성 프로세스를 점검하세요. |
| API upload/process/publish 오류 | `autopub.config`의 `APP_API_BASE_URL`과 엔드포인트 경로를 검증하세요. |
| tmux 서비스가 시작되지 않음 | `tmux has-session` 동작 여부와 스크립트 실행 권한을 확인하세요. |

## 로드맵

- 고정 의존성 관리 추가(`requirements.txt` 또는 `pyproject.toml`).
- 셸/Python 린팅 및 기본 통합 테스트를 위한 CI 검사 추가.
- API 계약 및 배포 가정에 대한 문서 추가.
- 유지보수되는 번역 README로 `i18n/` 확장.
- 관측성 개선(구조화 로그 및 헬스 체크).

## 기여

기여를 환영합니다.

권장 워크플로우:

1. Fork 후 기능 브랜치를 생성합니다.
2. 변경은 작고 집중적으로 유지합니다(스크립트 + 문서 동시 업데이트).
3. 필수 시스템 도구가 있는 Linux 환경에서 검증합니다.
4. 재현/테스트 노트를 명확히 작성해 Pull Request를 제출합니다.

동작이 변경되면 아래 문서를 함께 업데이트하세요.

- `README.md`
- `PROJECT_STRUCTURE.md` 및/또는 `autopub_monitor/README.md`

## 지원 및 스폰서

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

(`.github/FUNDING.yml`에서 발췌)

## 감사의 말

- 안정적인 장기 실행 자동화를 위해 Linux 네이티브 도구(`tmux`, `inotify`, `rsync`, `ffmpeg`)를 중심으로 구축되었습니다.
- 지속적인 개선을 지원해 주시는 기여자와 사용자 여러분께 감사드립니다.

## 라이선스

Apache License 2.0 - 자세한 내용은 [LICENSE](../LICENSE)를 참고하세요.
