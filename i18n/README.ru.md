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

> Автоматизированная система для мониторинга, обработки и публикации видеоконтента на нескольких платформах.

| Что ожидать | Детали |
|---|---|
| Модель выполнения | Linux-first автоматизация с `tmux`, необязательным `systemd` и блокировкой очереди |
| Проектирование очереди | Отслеживание файлов → очередь → worker-loop с устойчивым хранением состояния |
| Расширяемость | Shell-оркестрация + Python-клиенты публикации для адаптеров платформ |
| Ключевые точки входа | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Карта документации

| Раздел | Почему это важно |
|---|---|
| [Обзор проекта](#project-at-a-glance) | Быстро понять модель выполнения и цели |
| [Установка](#installation) | Перейти от клонирования до запущенного сервиса |
| [Конфигурация](#configuration) | Разобраться во всех важных переключателях скриптов |
| [Использование](#usage) | Запуск, остановка, управление очередью и обработкой |
| [Компоненты системы](#system-components) | Разделить зоны ответственности между shell и Python |
| [Устранение неполадок](#troubleshooting) | Быстро решать ошибки старта и очереди |
| [Дорожная карта](#roadmap) | Отследить ближайшие планы по платформам и инструментам |
| [Участие в разработке](#contributing) | Понять безопасные паттерны для вкладов |

## 🧭 Быстрый старт за один взгляд

| Цель | Команда | Примечания |
|---|---|---|
| Запустить пайплайн мониторинга | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Запускает watcher + queue + sync + панель ручного управления |
| Остановить все сервисы | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Корректное завершение работы и очистка панелей |
| Поставить в очередь по шаблону | `./autopub_monitor/queue_file_utility.sh "pattern"` | Добавляет соответствующие файлы в очередь обработки |
| Обработать один файл | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Использует настройки публикации и обработки по умолчанию |

## 🎯 Обзор проекта

| Фокус | Детали |
|---|---|
| Целевая платформа | Linux с оркестрацией `tmux` и необязательным `systemd` |
| Модель очереди | Наблюдение за файлами → очередь → скрипты worker → конвейер публикации |
| Ключевые точки входа | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| Отслеживание состояния | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Обзор

AutoPubMonitor — это ориентированный на Linux конвейер автоматизации для обработки видео и публикации на нескольких платформах. Система следит за появлением новых видеофайлов, обрабатывает их по шагам: проверка совместимости, при необходимости аугментация, обработка транскрипции/перевода через API, и публикует результат на настроенные платформы.

Среда выполнения оркестрирована через shell (`tmux`, `inotifywait`, `rsync`, `flock`) с Python-клиентами и хранением состояния в CSV/текстовых файлах.

## ⚡ Ключевые возможности

| Возможность | Детали |
|---|---|
| Автоматическое обнаружение файлов | Отслеживает директории на предмет новых видеофайлов |
| Управление очередью | Обрабатывает видео в контролируемой последовательной схеме |
| Обработка видео | Проверяет продолжительность, форматы и подготавливает видео |
| Публикация на нескольких платформах | Поддерживаются XiaoHongShu, Bilibili, Douyin, ShiPinHao и YouTube |
| Кэширование | Ускоряет обработку за счёт повторного использования результатов |
| Синхронизация файлов | Переносит файлы между системами |
| Централизованная конфигурация | Все пути и параметры в одном файле настроек |
| Простая установка | Один скрипт для настройки всей системы |
| Исправление совместимости видео | Использует проверки FFmpeg и необязательный fallback через HandBrakeCLI |
| Операции как сервис | `tmux` сессии + необязательный сервис `systemd` |
| Международная документация | Языковые ссылки в корне и переводы в `i18n/` |

## 🗂️ Структура репозитория

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
| `autopub.py` | Основной движок обработки, который выполняет оркестрацию upload/process/publish |
| `process_video.py` | Видео-клиент для загрузки, обработки и обработки результатов |
| `video_utils.py` / `handbrake.py` | Проверки совместимости и исправления перед загрузкой |

### Управление очередью

| Компонент | Роль |
|---|---|
| `process_queue.sh` | Потребитель очереди с блокировкой `flock` и циклом повторов |
| `queue_file_utility.sh` | Ручная подача файлов по пути или шаблону имени |

### Управление сервисом

| Компонент | Роль |
|---|---|
| `autopub_monitor_tmux_session.sh` | Запускает и останавливает tmux-сервисы с несколькими панелями |
| `autopub.sh` | Wrapper на базе conda/bootstrap для `autopub.py` |
| `autopub_sync.sh` | Синхронизация файлов из удалённых/реплицируемых источников |
| `monitor_autopublish.sh` | `inotify`-наблюдатель новых файлов и постановки в очередь |

### Утилиты

| Компонент | Роль |
|---|---|
| `window_info_utility.py` | Утилита текущего активного окна с помощью `xdotool` (опционально) |
| `autopub.config` | Централизованный файл конфигурации |
| `install_autopub_monitor.sh` | Установка + помощник конфигурации systemd |

## Требования

| Требование | Примечания |
|---|---|
| Linux-среда с bash | Основная целевая платформа |
| Python 3.8+ | Установщик в данный момент создаёт conda-окружение Python 3.8 |
| Miniconda в `${HOME}/miniconda3` | Путь по умолчанию, ожидаемый скриптами |
| `ffmpeg` / `ffprobe` | Необходимы для проверки и обработки видео |
| `tmux` | Оркестрация сервисов |
| `inotify-tools` | Наблюдение за файловыми событиями (`inotifywait`) |
| `rsync` | Синхронизация между директориями/системами |
| `python3-pip` | Установка Python-зависимостей |
| Опционально: `HandBrakeCLI` | Рекомендуется для восстановления проблемных видео |
| Опционально: `xdotool` | Нужен для `window_info_utility.py` |

Python-пакеты, используемые в скриптах репозитория:

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

Установщик делает следующее:

- Устанавливает зависимости apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Создаёт или использует conda-окружение `autopub-video`
- Устанавливает Python-пакеты (`requests`, `requests_toolbelt`, `selenium`)
- Создаёт runtime-директории и файлы состояния
- Устанавливает и включает `autopub-monitor.service`

### 🧩 Включение и запуск сервиса (если установщик ещё этого не сделал)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Ручная настройка

1. Проверьте и при необходимости отредактируйте `autopub_monitor/autopub.config` под ваше окружение.
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

> Предположение: файлы состояния при запуске (например, `queue.lock`, `temp_queue.txt`, `checked_list.txt`) уже должны существовать или быть созданы установкой/стартом.

## Конфигурация

Основной файл конфигурации: `autopub_monitor/autopub.config`

Ключевые параметры включают:

- Каталоги данных: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Каталоги для синхронизации: `JIANGUOYUN_*`
- Файлы состояния: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Файлы блокировок: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Параметры API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Настройки Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Примечания:

- Конфигурация по умолчанию сейчас использует режим app API (`USE_APP_API="true"`) и формирует URL эндпоинтов из `APP_API_BASE_URL`.
- В конфиге по-прежнему есть устаревшие эндпоинты, оставлены для справки.
- Имена файлов очереди и блокировок можно менять с минимальным риском, если все скрипты используют те же ключи из конфига.

## Использование

### ▶️ Запуск сервисов

Из корня репозитория:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Эта команда запускает:

- Сервис синхронизации файлов
- Сервис наблюдения каталога
- Сервис обработки очереди
- Панель ручных команд
- Сессию rsync для транскрипции (`am-transcription-sync`)

### ⏹️ Остановка сервисов

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Ручное управление очередью

```bash
# Добавить по совпадению шаблона
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Добавить по абсолютному пути
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Добавить с автоподтверждением (без приглашения выбора)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Ручная обработка видео

```bash
# Обработать конкретный файл с настройками wrapper по умолчанию
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# Прямой CLI с конкретными целями публикации
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Параметры кэширования + визуализация прогресса
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Загрузка и обработка без публикации
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

- В режиме app API (`USE_APP_API=true`) публикация по умолчанию отключена, если флаги публикации явно не переданы.

## 🎛️ Панель команд

| Область | Примеры |
|---|---|
| Управление сервисом | `autopub_monitor_tmux_session.sh start/stop` |
| Операции очереди | `queue_file_utility.sh`, `process_queue.sh` |
| Синхронизация/обработка файлов | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Путь выполнения Python | `autopub.py`, `process_video.py`, `video_utils.py` |

## Архитектура обработки

1. **Обнаружение файлов**: `monitor_autopublish.sh` отслеживает события `close_write`/`moved_to`.
2. **Очередь**: валидные файлы добавляются в `queue_list.txt` через `flock`.
3. **Обработка**: `process_queue.sh` читает очередь и вызывает `autopub.sh`.
4. **Upload/Process/Publish**: `autopub.py` и `process_video.py` вызывают настроенные API-эндпоинты.
5. **Отслеживание**: обработанные файлы пишутся в `processed.csv`, обнаруженные — в `videos_db.csv`.

## Практические примеры

### Пример 1: Рабочий режим daemona 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Затем поместите или синхронизируйте видео в настроенный исходный каталог и следите за логами в панелях tmux.

### Пример 2: Принудительный повтор совпавших файлов 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Пример 3: Локальный тест без публикации 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Примечания по разработке

- На корне репозитория отсутствует закреплённый манифест зависимостей (`requirements.txt` / `pyproject.toml`).
- Среда выполнения жёстко привязана к Linux shell-инструментам и локальным соглашениям путей.
- Текущие скрипты динамически загружают shell-конфиг (`autopub.config`); сохраняйте shell-совместимые выражения переменных.
- Логика очереди и блокировок опирается на `flock`; избегайте изменений, которые ослабляют атомарность обновлений очереди.
- Детали API-контракта выводятся из клиентского кода; серверная часть находится вне этого репозитория.
- Каталог `i18n/` существует, но переводы документации не полностью поддерживались в черновом цикле.
- Файлы артефактов (`queue_list.txt`, `temp_queue.txt` и т.д.) обычно создаются и поддерживаются во время выполнения, поэтому могут отличаться по окружению.

## 🧱 Обратная совместимость с устаревшими названиями (сохраняется)

В старой документации использовались переименованные метки компонентов. Текущие имена файлов в репозитории ниже.

| Метка в старых документах | Текущий файл в репозитории |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Для удобства, если вы выполняете `cd autopub_monitor`, эквивалент команд из старых документаций будет таким:

```bash
# Старый стиль документации (эквивалентные команды с относительными путями)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 🛠️ Устранение неполадок

| Симптом | Что проверять |
|---|---|
| `Miniconda not found at ~/miniconda3` | Установите Miniconda или обновите `CONDA_DIR` в `autopub.config`. |
| `inotifywait: command not found` | Установите `inotify-tools`. |
| Ошибки `ffprobe`/`ffmpeg` | Установите `ffmpeg`; проверьте целостность исходного файла. |
| Видео не добавляются в очередь повторно | Проверьте `checked_list.txt`, `temp_queue.txt` и логи `monitor_autopublish.sh`. |
| Очередь зависла или есть гонки | Проверьте `queue.lock`, `queue_list.txt`, процессы с `flock`. |
| Ошибки API upload/process/publish | Проверьте `APP_API_BASE_URL` и пути endpoint в `autopub.config`. |
| Сервис `tmux` не запускается | Убедитесь, что `tmux has-session` работает, и права на выполнение скриптов выставлены корректно. |

## 🗺️ Дорожная карта

- Добавить фиксацию зависимостей (`requirements.txt` или `pyproject.toml`).
- Добавить CI-проверки для shell/Python linting и базовых интеграционных тестов.
- Добавить документацию по контракту API и допущениям при деплое.
- Расширить `i18n/` поддерживаемыми переведёнными версиями README.
- Улучшить наблюдаемость: структурированные логи и health-checks.

## 🤝 Участие в проекте

Принесения вкладов приветствуются.

Рекомендуемый рабочий процесс:

1. Форкните репозиторий и создайте feature-ветку.
2. Подходите к изменениям небольшими и сфокусированными блоками (скрипты + документация вместе).
3. Проверяйте на Linux с требуемыми системными инструментами.
4. Открывайте pull request с понятным описанием сценариев воспроизведения и заметками по проверкам.

Если поведение меняется, обновляйте оба файла:

- `README.md`
- `PROJECT_STRUCTURE.md` и/или `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Контакты

По вопросам, баг-репортам и запросам на новые функции:

- Откройте issue в [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 Благодарности

- Построен вокруг Linux-родных инструментов (`tmux`, `inotify`, `rsync`, `ffmpeg`) для надёжной долгосрочной автоматизации.
- Благодарности авторам и пользователям, которые поддерживают дальнейшее развитие.

## 📄 Лицензия

Apache License 2.0 — смотрите [LICENSE](LICENSE) для деталей.
