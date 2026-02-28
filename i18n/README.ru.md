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

Автоматизированная система для мониторинга, обработки и публикации видеоконтента на нескольких платформах.

## Обзор

AutoPubMonitor — это ориентированный на Linux конвейер автоматизации для обработки видеоконтента и публикации на нескольких платформах. Система отслеживает появление новых видеофайлов, выполняет их обработку (включая проверку/исправление совместимости, опциональные улучшения, обработку, связанную с транскрибацией/переводом через API) и публикует результаты на настроенные платформы.

Среда выполнения оркестрируется shell-скриптами (`tmux`, `inotifywait`, `rsync`, `flock`) с Python-клиентами обработки и отслеживанием состояния в CSV/текстовых файлах.

## Ключевые возможности

| Возможность | Детали |
|---|---|
| Автоматическое обнаружение файлов | Отслеживает каталоги на предмет нового видеоконтента |
| Управление очередью обработки | Обрабатывает видео контролируемо и последовательно |
| Обработка видео | Проверяет длительность, форматы и подготавливает видео |
| Публикация на нескольких платформах | Поддерживает XiaoHongShu, Bilibili, Douyin, ShiPinHao и YouTube |
| Система кэширования | Оптимизирует обработку за счёт кэша |
| Синхронизация файлов | Управляет перемещением файлов между системами |
| Централизованная конфигурация | Все пути и настройки в одном конфигурационном файле |
| Простая установка | Один скрипт для настройки всей системы |
| Исправление совместимости видео | Использует проверки FFmpeg и опциональный fallback через HandBrakeCLI |
| Работа как сервис | `tmux`-сессии + опциональный `systemd`-сервис |

## Структура репозитория

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

## Компоненты системы

### Основная обработка

| Компонент | Роль |
|---|---|
| `autopub.py` | Основной движок обработки, управляющий оркестрацией upload/process/publish |
| `process_video.py` | Клиент обработки видео для загрузки, обработки и получения результатов |
| `video_utils.py` / `handbrake.py` | Проверки совместимости и исправления перед загрузкой |

### Управление очередью

| Компонент | Роль |
|---|---|
| `process_queue.sh` | Консьюмер очереди с блокировками `flock` и циклом повторных попыток |
| `queue_file_utility.sh` | Ручное добавление в очередь по пути или шаблону имени файла |

### Управление сервисами

| Компонент | Роль |
|---|---|
| `autopub_monitor_tmux_session.sh` | Запускает/останавливает multi-pane tmux-сервисы |
| `autopub.sh` | Обёртка conda/bootstrap для `autopub.py` |
| `autopub_sync.sh` | Синхронизация файлов из пути Nutstore/Jianguoyun |
| `monitor_autopublish.sh` | `inotify`-наблюдатель за новыми файлами и постановкой в очередь |

### Утилиты

| Компонент | Роль |
|---|---|
| `window_info_utility.py` | Утилита активного окна на базе `xdotool` (опционально) |
| `autopub.config` | Центральный конфигурационный файл |
| `install_autopub_monitor.sh` | Помощник установки + настройки systemd |

<a id="prerequisites"></a>

## Предварительные требования

| Требование | Примечания |
|---|---|
| Linux-окружение с bash | Основная целевая среда выполнения |
| Python 3.8+ | Установщик сейчас создаёт conda-среду Python 3.8 |
| Miniconda в `${HOME}/miniconda3` | Путь по умолчанию, ожидаемый скриптами |
| `ffmpeg` / `ffprobe` | Требуются для валидации/обработки видео |
| `tmux` | Оркестрация сервисов |
| `inotify-tools` | Мониторинг событий файлов (`inotifywait`) |
| `rsync` | Синхронизация между каталогами/системами |
| `python3-pip` | Установка Python-пакетов |
| Опционально: `HandBrakeCLI` | Рекомендуется для исправления проблемных видео |
| Опционально: `xdotool` | Нужен для `window_info_utility.py` |

Пакеты Python, используемые в скриптах репозитория:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Установка

### 🚀 Автоматическая установка (скриптом)

Из корня репозитория:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

Установщик:

- Устанавливает apt-зависимости (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Создаёт/использует conda-среду `autopub-video`
- Устанавливает Python-пакеты (`requests`, `requests_toolbelt`, `selenium`)
- Создаёт рабочие каталоги и файлы состояния
- Устанавливает и включает `autopub-monitor.service`

### 🧩 Включение/запуск сервиса (если установщик этого ещё не сделал)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Ручная настройка

1. Просмотрите и измените `autopub_monitor/autopub.config` под своё окружение.
2. Создайте и активируйте окружение:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Сделайте скрипты исполняемыми:

```bash
chmod +x autopub_monitor/*.sh
```

## Конфигурация

Основной конфигурационный файл: `autopub_monitor/autopub.config`

Важные настройки включают:

- Каталоги данных: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Каталоги источников синхронизации: `JIANGUOYUN_*`
- Файлы состояния: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Файлы блокировок: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Настройки API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Настройки Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Примечания:

- Конфигурация по умолчанию сейчас предпочитает режим app API (`USE_APP_API="true"`) и формирует URL эндпоинтов из `APP_API_BASE_URL`.
- Устаревшие эндпоинты всё ещё присутствуют в конфиге для справки.

<a id="usage"></a>

## Использование

### ▶️ Запуск сервисов

Из корня репозитория:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Это запускает:

- Сервис синхронизации файлов
- Сервис наблюдения за каталогом
- Сервис обработки очереди
- Панель для ручных команд
- Сессию rsync транскрибаций (`am-transcription-sync`)

### ⏹️ Остановка сервисов

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Ручное управление очередью

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Ручная обработка видео

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

## Параметры CLI (`autopub.py`)

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

Примечание по поведению:

- В режиме app API (`USE_APP_API=true`) публикация по умолчанию отключена, если флаги публикации не переданы явно.

## Архитектура обработки

1. **Обнаружение файлов**: `monitor_autopublish.sh` отслеживает события `close_write`/`moved_to`.
2. **Очередь**: валидные файлы добавляются в `queue_list.txt` с использованием `flock`.
3. **Обработка**: `process_queue.sh` потребляет элементы очереди и вызывает `autopub.sh`.
4. **Upload/Process/Publish**: `autopub.py` и `process_video.py` вызывают настроенные API-эндпоинты.
5. **Отслеживание**: обработанные файлы записываются в `processed.csv`, обнаруженные файлы — в `videos_db.csv`.

## Практические примеры

### Пример 1: Сквозной daemon-режим 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Затем поместите или синхронизируйте видео в настроенный исходный каталог и отслеживайте логи в панелях tmux.

### Пример 2: Принудительный повторный запуск для совпадающих файлов 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Пример 3: Локальный тест без публикации 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Заметки по разработке

- В корне репозитория нет зафиксированного манифеста зависимостей (`requirements.txt` / `pyproject.toml`).
- Среда выполнения тесно привязана к Linux shell-инструментам и локальным соглашениям путей.
- Текущие скрипты динамически подгружают конфигурацию shell (`autopub.config`); сохраняйте shell-совместимые выражения переменных.
- Семантика очереди и блокировок опирается на `flock`; избегайте правок, ослабляющих атомарность обновлений очереди.
- Детали API-контракта выведены из клиентского кода; реализация сервера находится вне этого репозитория.
- Каталог `i18n/` существует, но языковые документы в этом цикле черновика ещё не заполнены.

## Совместимость с устаревшими названиями (сохранено)

В предыдущей документации использовались переименованные метки компонентов. Текущие имена файлов репозитория приведены ниже.

| Метка в старых документах | Текущий файл в репозитории |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Для удобства, если вы выполнили `cd autopub_monitor`, эти формы команд в стиле старой документации соответствуют:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Устранение неполадок

| Симптом | Что проверить |
|---|---|
| `Miniconda not found at ~/miniconda3` | Установите Miniconda или обновите `CONDA_DIR` в `autopub.config`. |
| `inotifywait: command not found` | Установите `inotify-tools`. |
| Ошибки `ffprobe`/`ffmpeg` | Установите `ffmpeg`; проверьте целостность исходного файла. |
| Видео постоянно не попадают в очередь | Проверьте `checked_list.txt`, `temp_queue.txt` и логи `monitor_autopublish.sh`. |
| Очередь зависла или есть риски гонок | Проверьте `queue.lock`, `queue_list.txt` и активные процессы, использующие `flock`. |
| Ошибки API upload/process/publish | Проверьте `APP_API_BASE_URL` и пути эндпоинтов в `autopub.config`. |
| tmux-сервис не запускается | Убедитесь, что работает `tmux has-session` и для скриптов выставлены права на выполнение. |

## Дорожная карта

- Добавить фиксированное управление зависимостями (`requirements.txt` или `pyproject.toml`).
- Добавить CI-проверки для shell/Python linting и базовых интеграционных тестов.
- Добавить документацию по API-контракту и предположениям развёртывания.
- Расширить `i18n/` поддерживаемыми переведёнными README.
- Улучшить наблюдаемость (структурированные логи и health checks).

## Участие в проекте

Вклад приветствуется.

Рекомендуемый workflow:

1. Сделайте fork и создайте feature-ветку.
2. Держите изменения небольшими и сфокусированными (обновляйте скрипты и документацию вместе).
3. Проверяйте на Linux-окружении с необходимыми системными инструментами.
4. Отправьте pull request с понятными примечаниями по воспроизведению/тестированию.

Если поведение меняется, обновите оба файла:

- `README.md`
- `PROJECT_STRUCTURE.md` и/или `autopub_monitor/README.md`

## Поддержка и спонсорство

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

(из `.github/FUNDING.yml`)

## Благодарности

- Проект построен вокруг Linux-native инструментов (`tmux`, `inotify`, `rsync`, `ffmpeg`) для надёжной долгоживущей автоматизации.
- Спасибо контрибьюторам и пользователям за поддержку постоянных улучшений.

## Лицензия

Apache License 2.0 - Подробности см. в [LICENSE](LICENSE).
