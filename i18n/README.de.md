[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#voraussetzungen)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#voraussetzungen)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#verwendung)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

Ein automatisiertes System zur Überwachung, Verarbeitung und Veröffentlichung von Videoinhalten auf mehreren Plattformen.

## Überblick

AutoPubMonitor ist eine Linux-orientierte Automatisierungs-Pipeline für die Videobearbeitung und Multi-Plattform-Veröffentlichung. Das System überwacht neue Videodateien, verarbeitet sie über Schritte wie Kompatibilitätsreparatur, optionale Erweiterung, transkriptions-/übersetzungsbezogene Verarbeitung per API und veröffentlicht die Ergebnisse auf konfigurierten Plattformen.

Die Laufzeit wird per Shell orchestriert (`tmux`, `inotifywait`, `rsync`, `flock`) mit Python-Verarbeitungsclients sowie CSV-/Text-Zustandsverfolgung.

## Hauptfunktionen

| Fähigkeit | Details |
|---|---|
| Automatische Dateierkennung | Überwacht Verzeichnisse auf neue Videoinhalte |
| Verarbeitungswarteschlange | Verarbeitet Videos kontrolliert und sequenziell |
| Videobearbeitung | Prüft Länge, Formate und bereitet Videos auf |
| Multi-Plattform-Veröffentlichung | Unterstützt XiaoHongShu, Bilibili, Douyin, ShiPinHao und YouTube |
| Caching-System | Optimiert die Verarbeitung durch Zwischenspeicherung |
| Dateisynchronisierung | Bewegt Dateien zwischen Systemen |
| Zentrale Konfiguration | Alle Pfade und Einstellungen in einer Konfigurationsdatei |
| Einfache Installation | Ein einzelnes Skript richtet das gesamte System ein |
| Video-Kompatibilitätsreparatur | Nutzt FFmpeg-Prüfungen und optionales HandBrakeCLI-Fallback |
| Service-orientierter Betrieb | `tmux`-Sitzungen + optionaler `systemd`-Service |

## Repository-Struktur

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

## Systemkomponenten

### Kernverarbeitung

| Komponente | Rolle |
|---|---|
| `autopub.py` | Hauptverarbeitungs-Engine für die Orchestrierung von Upload/Verarbeitung/Veröffentlichung |
| `process_video.py` | Videobearbeitungs-Client für Upload, Verarbeitung und Ergebnisbehandlung |
| `video_utils.py` / `handbrake.py` | Kompatibilitätsprüfungen und Reparaturen vor dem Upload |

### Queue-Management

| Komponente | Rolle |
|---|---|
| `process_queue.sh` | Queue-Consumer mit `flock`-Locking und Retry-Schleife |
| `queue_file_utility.sh` | Manueller Queue-Feeder per Pfad oder Dateinamenmuster |

### Service-Management

| Komponente | Rolle |
|---|---|
| `autopub_monitor_tmux_session.sh` | Startet/stoppt Multi-Pane-`tmux`-Services |
| `autopub.sh` | Conda-/Bootstrap-Wrapper für `autopub.py` |
| `autopub_sync.sh` | Dateisynchronisierung aus Nutstore-/Jianguoyun-Pfad |
| `monitor_autopublish.sh` | `inotify`-Watcher für neue Dateien und Queueing |

### Hilfswerkzeuge

| Komponente | Rolle |
|---|---|
| `window_info_utility.py` | Utility für aktives Fenster mit `xdotool` (optional) |
| `autopub.config` | Zentrale Konfigurationsdatei |
| `install_autopub_monitor.sh` | Installations- + systemd-Setup-Helfer |

## Voraussetzungen

| Anforderung | Hinweise |
|---|---|
| Linux-Umgebung mit bash | Primäres Laufzeitziel |
| Python 3.8+ | Der Installer erstellt derzeit eine Python-3.8-Conda-Umgebung |
| Miniconda unter `${HOME}/miniconda3` | Standardpfad, den Skripte erwarten |
| `ffmpeg` / `ffprobe` | Erforderlich für Videovalidierung/-verarbeitung |
| `tmux` | Service-Orchestrierung |
| `inotify-tools` | Überwachung von Dateiereignissen (`inotifywait`) |
| `rsync` | Synchronisierung zwischen Verzeichnissen/Systemen |
| `python3-pip` | Installation von Python-Paketen |
| Optional: `HandBrakeCLI` | Empfohlen zur Reparatur problematischer Videos |
| Optional: `xdotool` | Benötigt für `window_info_utility.py` |

In Repository-Skripten verwendete Python-Pakete:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Automatische Installation (Skript)

Vom Repository-Root aus:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

Der Installer:

- Installiert apt-Abhängigkeiten (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Erstellt/verwendet die Conda-Umgebung `autopub-video`
- Installiert Python-Pakete (`requests`, `requests_toolbelt`, `selenium`)
- Erstellt Laufzeitverzeichnisse und Statusdateien
- Installiert und aktiviert `autopub-monitor.service`

### 🧩 Service aktivieren/starten (falls nicht bereits durch den Installer aktiviert)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Manuelles Setup

1. Prüfe und passe `autopub_monitor/autopub.config` für deine Umgebung an.
2. Erstelle und aktiviere die Umgebung:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Mache Skripte ausführbar:

```bash
chmod +x autopub_monitor/*.sh
```

## Konfiguration

Primäre Konfigurationsdatei: `autopub_monitor/autopub.config`

Wichtige Einstellungen umfassen:

- Datenverzeichnisse: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Sync-Quellverzeichnisse: `JIANGUOYUN_*`
- Statusdateien: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Lock-Dateien: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API-Einstellungen: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda-Einstellungen: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Hinweise:

- Die Standardkonfiguration bevorzugt derzeit den App-API-Modus (`USE_APP_API="true"`) und erzeugt Endpoint-URLs aus `APP_API_BASE_URL`.
- Legacy-Endpoints sind weiterhin zur Referenz in der Konfiguration enthalten.

## Verwendung

### ▶️ Services starten

Vom Repository-Root aus:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Dies startet:

- Dateisynchronisierungs-Service
- Verzeichnis-Watcher-Service
- Queue-Verarbeitungs-Service
- Manuelles Befehls-Pane
- Transkriptions-rsync-Sitzung (`am-transcription-sync`)

### ⏹️ Services stoppen

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Manuelles Queue-Management

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Manuelle Videoverarbeitung

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

## CLI-Optionen (`autopub.py`)

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

Hinweis zum Verhalten:

- Im App-API-Modus (`USE_APP_API=true`) ist Veröffentlichen standardmäßig deaktiviert, sofern nicht explizit Publish-Flags übergeben werden.

## Verarbeitungsarchitektur

1. **Dateierkennung**: `monitor_autopublish.sh` überwacht `close_write`-/`moved_to`-Ereignisse.
2. **Queue**: Gültige Dateien werden mit `flock` an `queue_list.txt` angehängt.
3. **Verarbeitung**: `process_queue.sh` konsumiert Queue-Einträge und ruft `autopub.sh` auf.
4. **Upload/Verarbeitung/Veröffentlichung**: `autopub.py` und `process_video.py` rufen konfigurierte API-Endpoints auf.
5. **Tracking**: Verarbeitete Dateien werden in `processed.csv`, erkannte Dateien in `videos_db.csv` geschrieben.

## Praktische Beispiele

### Beispiel 1: End-to-End-Daemon-Modus 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Danach Videos in dein konfiguriertes Quellverzeichnis legen oder synchronisieren und die Logs in den tmux-Panes beobachten.

### Beispiel 2: Übereinstimmende Dateien erzwungen erneut ausführen 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Beispiel 3: Lokaler Test ohne Veröffentlichung 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Hinweise zur Entwicklung

- Kein fest gepinntes Abhängigkeits-Manifest (`requirements.txt` / `pyproject.toml`) im Repository-Root vorhanden.
- Laufzeit ist stark an Linux-Shell-Tools und lokale Pfadkonventionen gebunden.
- Aktuelle Skripte beziehen Shell-Konfiguration dynamisch (`autopub.config`); shell-kompatible Variablenausdrücke beibehalten.
- Queue- und Lock-Semantik basiert auf `flock`; keine Änderungen vornehmen, die atomare Queue-Updates schwächen.
- API-Vertragsdetails sind aus Client-Code abgeleitet; die Server-Implementierung liegt außerhalb dieses Repositories.
- Das Verzeichnis `i18n/` existiert, Sprachdokumente waren in diesem Entwurfszyklus jedoch noch nicht befüllt.

## Legacy-Namenskompatibilität (beibehalten)

Frühere Dokumentation nutzte umbenannte Komponentenbezeichnungen. Die aktuellen Dateinamen im Repository bleiben wie unten aufgeführt.

| Frühere Doku-Bezeichnung | Aktuelle Repository-Datei |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Zur Bequemlichkeit, wenn du `cd autopub_monitor` ausführst, entsprechen diese Legacy-Befehlsformen aus älteren Docs:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Fehlerbehebung

| Symptom | Zu prüfen |
|---|---|
| `Miniconda not found at ~/miniconda3` | Miniconda installieren oder `CONDA_DIR` in `autopub.config` aktualisieren. |
| `inotifywait: command not found` | `inotify-tools` installieren. |
| `ffprobe`/`ffmpeg`-Fehler | `ffmpeg` installieren; Integrität der Eingabedatei prüfen. |
| Videos werden wiederholt nicht in die Queue aufgenommen | `checked_list.txt`, `temp_queue.txt` und Logs von `monitor_autopublish.sh` prüfen. |
| Queue hängt oder Race-Condition-Sorgen | `queue.lock`, `queue_list.txt` und aktive Prozesse mit `flock` prüfen. |
| API-Upload/Verarbeitung/Veröffentlichung-Fehler | `APP_API_BASE_URL` und Endpoint-Pfade in `autopub.config` verifizieren. |
| tmux-Service startet nicht | Prüfen, ob `tmux has-session` funktioniert und Skript-Ausführungsrechte gesetzt sind. |

## Roadmap

- Gepinntes Abhängigkeitsmanagement hinzufügen (`requirements.txt` oder `pyproject.toml`).
- CI-Prüfungen für Shell/Python-Linting und grundlegende Integrationstests hinzufügen.
- Dokumentation für API-Vertrag und Deployment-Annahmen ergänzen.
- `i18n/` um gepflegte übersetzte READMEs erweitern.
- Beobachtbarkeit verbessern (strukturierte Logs und Health-Checks).

## Mitwirken

Beiträge sind willkommen.

Empfohlener Workflow:

1. Fork erstellen und Feature-Branch anlegen.
2. Änderungen klein und fokussiert halten (Skript- + Doku-Updates gemeinsam).
3. In einer Linux-Umgebung mit erforderlichen System-Tools validieren.
4. Pull Request mit klaren Reproduktions-/Testhinweisen einreichen.

Wenn sich Verhalten ändert, aktualisiere beide:

- `README.md`
- `PROJECT_STRUCTURE.md` und/oder `autopub_monitor/README.md`

## Support und Sponsoring

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community-Chat: https://chat.lazying.art
- Ideen-Hub: https://onlyideas.art

(Aus `.github/FUNDING.yml`)

## Danksagung

- Aufgebaut auf Linux-nativen Tools (`tmux`, `inotify`, `rsync`, `ffmpeg`) für zuverlässige, langlaufende Automatisierung.
- Danke an Mitwirkende und Nutzer für die Unterstützung kontinuierlicher Verbesserungen.

## Lizenz

Apache License 2.0 - Siehe [LICENSE](../LICENSE) für Details.
