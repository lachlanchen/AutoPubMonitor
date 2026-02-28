[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#voraussetzungen)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#voraussetzungen)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#verwendung)
[![Monitors](https://img.shields.io/badge/monitoring-inotifywait-0ea5e9)](#verwendung)
[![Queueing](https://img.shields.io/badge/queue-flock-16a34a)](#systemkomponenten)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)
[![Activity](https://img.shields.io/github/last-commit/lachlanchen/AutoPubMonitor?style=flat-square&label=last%20commit&color=1d76db)](https://github.com/lachlanchen/AutoPubMonitor/commits/main)
[![Repo Size](https://img.shields.io/github/repo-size/lachlanchen/AutoPubMonitor?style=flat-square&color=0366d6)](https://github.com/lachlanchen/AutoPubMonitor)
[![Issues](https://img.shields.io/github/issues/lachlanchen/AutoPubMonitor?style=flat-square)](https://github.com/lachlanchen/AutoPubMonitor/issues)
[![Contributors](https://img.shields.io/github/contributors/lachlanchen/AutoPubMonitor?style=flat-square)](https://github.com/lachlanchen/AutoPubMonitor/graphs/contributors)

> Automatisiertes System für die Überwachung, Verarbeitung und Veröffentlichung von Videoinhalten auf mehreren Plattformen.

| Was zu erwarten ist | Details |
|---|---|
| Ausführungsmodell | Linux-zentrierte Automatisierung mit `tmux`, optionalem `systemd` und Queue-Locks |
| Queue-Design | Dateiwächter → Queue → Worker-Schleife mit persistenter Statusverfolgung |
| Erweiterbarkeit | Shell-Orchestrierung + Python-Publish-Clients für Plattform-Adapter |
| Kerneinstiegspunkte | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Dokumentationsübersicht

| Abschnitt | Warum wichtig |
|---|---|
| [Projekt auf einen Blick](#projekt-auf-einen-blick) | Laufzeitmodell und Ziele schnell verstehen |
| [Installation](#installation) | Von `clone` bis laufendem Service |
| [Konfiguration](#konfiguration) | Alle wichtigen Schalter auf Skriptebene kennen |
| [Verwendung](#verwendung) | Starten, Stoppen, Queue und Verarbeitung steuern |
| [Systemkomponenten](#systemkomponenten) | Shell- und Python-Verantwortlichkeiten trennen |
| [Fehlerbehebung](#fehlerbehebung) | Start- und Queue-Probleme schnell lösen |
| [Roadmap](#roadmap) | Kurzfristige Plattform- und Tooling-Pläne verfolgen |
| [Mitwirken](#mitwirken) | Sichere Beitragspfade verstehen |

## 🧭 Schnellstart auf einen Blick

| Ziel | Befehl | Hinweise |
|---|---|---|
| Überwachungs-Pipeline starten | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Startet Watcher + Queue + Sync + manuelles Pane |
| Alle Dienste beenden | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Sauberes Herunterfahren und Bereinigung der Panes |
| Dateien per Muster in die Queue schreiben | `./autopub_monitor/queue_file_utility.sh "pattern"` | Fügt passende Dateien der Verarbeitungsqueue hinzu |
| Eine Datei verarbeiten | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Verwendet Standard-Publishing und -Verarbeitung |

## 🎯 Projekt auf einen Blick

| Fokus | Details |
|---|---|
| Laufzeitziel | Linux mit `tmux`-Orchestrierung und optionalem `systemd` |
| Queue-Modell | Dateiwächter → Queue → Worker-Skripte → Publishing-Pipeline |
| Kerneinstiegspunkte | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| Statusverfolgung | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Überblick

AutoPubMonitor ist eine Linux-orientierte Automatisierungspipeline für die Videobearbeitung und Multi-Plattform-Veröffentlichung. Das System überwacht neue Videodateien, verarbeitet diese in mehreren Schritten wie Kompatibilitätsreparatur, optionaler Erweiterung, transkriptions-/übersetzungsbezogener Verarbeitung über API und veröffentlicht anschließend die Ergebnisse auf den konfigurierten Plattformen.

Die Laufzeit ist shell-orchestriert (`tmux`, `inotifywait`, `rsync`, `flock`) mit Python-Verarbeitungstools und CSV/Text-basierter Statusverfolgung.

## ⚡ Zentrale Funktionen

| Fähigkeit | Details |
|---|---|
| Automatische Dateierkennung | Überwacht Verzeichnisse auf neue Videoinhalte |
| Queue-Management | Verarbeitet Videos kontrolliert und sequenziell |
| Videobearbeitung | Prüft Länge, Formate und bereitet Videos vor |
| Multi-Plattform-Publishing | Unterstützt XiaoHongShu, Bilibili, Douyin, ShiPinHao und YouTube |
| Caching-System | Optimiert Verarbeitung durch Caching |
| Dateisynchronisierung | Überführt Dateien zwischen Systemen |
| Zentrale Konfiguration | Alle Pfade und Einstellungen in einer einzigen Konfigurationsdatei |
| Einfache Installation | Einzelnes Skript für die komplette Einrichtung |
| Video-Kompatibilitätsreparatur | Nutzt FFmpeg-Prüfungen und optionales HandBrakeCLI-Fallback |
| Service-orientierter Betrieb | `tmux`-Sitzungen + optionaler `systemd`-Service |
| Internationale Dokumentation | Sprachlinks in der Wurzel und Übersetzungen unter `i18n/` |

## 🗂️ Repository-Struktur

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
| `autopub.py` | Hauptverarbeitungs-Engine für Upload/Verarbeitung/Publishing-Orchestrierung |
| `process_video.py` | Videoverarbeitungs-Client für Upload, Verarbeitung und Ergebnisbehandlung |
| `video_utils.py` / `handbrake.py` | Kompatibilitätsprüfungen und Reparaturen vor dem Upload |

### Queue-Management

| Komponente | Rolle |
|---|---|
| `process_queue.sh` | Queue-Verbraucher mit `flock`-Sperre und Retry-Schleife |
| `queue_file_utility.sh` | Manuelle Queue-Einspielung per Pfad oder Dateinamenmuster |

### Service-Management

| Komponente | Rolle |
|---|---|
| `autopub_monitor_tmux_session.sh` | Startet/stoppt mehrteilige tmux-Dienste |
| `autopub.sh` | Conda/Bootstrap-Wrapper für `autopub.py` |
| `autopub_sync.sh` | Dateisynchronisation aus synchronisierten Quellen |
| `monitor_autopublish.sh` | `inotify`-Watcher für neue Dateien und Queueing |

### Hilfsprogramme

| Komponente | Rolle |
|---|---|
| `window_info_utility.py` | Aktive Fenster-Utility mit `xdotool` (optional) |
| `autopub.config` | Zentrale Konfigurationsdatei |
| `install_autopub_monitor.sh` | Installations- + systemd-Setup-Helfer |

## Voraussetzungen

| Anforderung | Hinweise |
|---|---|
| Linux-Umgebung mit bash | Primäres Laufzeitziel |
| Python 3.8+ | Installer erstellt derzeit eine Python-3.8-Conda-Umgebung |
| Miniconda in `${HOME}/miniconda3` | Standardpfad, den Skripte erwarten |
| `ffmpeg` / `ffprobe` | Für Video-Validierung/Verarbeitung erforderlich |
| `tmux` | Service-Orchestrierung |
| `inotify-tools` | Dateiawareness (`inotifywait`) |
| `rsync` | Synchronisation zwischen Verzeichnissen/Systemen |
| `python3-pip` | Installation von Python-Paketen |
| Optional: `HandBrakeCLI` | Empfohlen zur Reparatur problematischer Videos |
| Optional: `xdotool` | Benötigt für `window_info_utility.py` |

Python-Pakete, die in den Repo-Skripten verwendet werden:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Automatische Installation (skriptbasiert)

Aus dem Repository-Root:

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

### 🧩 Service aktivieren/starten (falls der Installer ihn nicht schon aktiviert hat)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Manuelle Einrichtung

1. Prüfen und anpassen von `autopub_monitor/autopub.config` für die eigene Umgebung.
2. Umgebung anlegen und aktivieren:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Skripte ausführbar machen:

```bash
chmod +x autopub_monitor/*.sh
```

> Annahme: Die Laufzeitstatusdateien des Repos (z. B. `queue.lock`, `temp_queue.txt`, `checked_list.txt`) sollten bereits existieren oder durch Start/Installation angelegt werden.

## Konfiguration

Hauptkonfigurationsdatei: `autopub_monitor/autopub.config`

Wichtige Einstellungen:

- Datenverzeichnisse: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Sync-Quellverzeichnisse: `JIANGUOYUN_*`
- Statusdateien: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Lock-Dateien: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API-Einstellungen: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda-Einstellungen: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Hinweise:

- Standardmäßig nutzt die aktuelle Konfiguration den App-API-Modus (`USE_APP_API="true"`) und baut Endpunkt-URLs aus `APP_API_BASE_URL`.
- Legacy-Endpunkte sind weiterhin zu Referenzzwecken in der Konfiguration enthalten.
- Queue- und Lock-Dateinamen können mit geringem Risiko geändert werden, solange alle Skripte dieselben Konfigurationseinträge verwenden.

## Verwendung

### ▶️ Dienste starten

Aus dem Repository-Root:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Dabei werden gestartet:

- Datei-Sync-Service
- Verzeichnis-Watcher-Service
- Queue-Verarbeitungs-Service
- Manuelles Befehls-Pane
- Transkriptions-Rsync-Session (`am-transcription-sync`)

### ⏹️ Dienste stoppen

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Manuelle Queue-Verwaltung

```bash
# Nach Muster hinzufügen
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Über vollständigen Pfad hinzufügen
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Mit automatischer Bestätigung hinzufügen (keine Auswahlabfrage)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Manuelle Videobearbeitung

```bash
# Eine bestimmte Datei mit Standardwerten des Wrappers verarbeiten
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# Direkte CLI mit konkreten Publish-Zielen
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Caching-Optionen + Fortschrittsanzeige
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Upload/Verarbeitung ohne Veröffentlichung
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

Verhaltenshinweis:

- Im App-API-Modus (`USE_APP_API=true`) ist Publishing standardmäßig deaktiviert, sofern keine Publish-Flags explizit übergeben werden.

## 🎛️ Kommandopalette

| Bereich | Beispiele |
|---|---|
| Service-Steuerung | `autopub_monitor_tmux_session.sh start/stop` |
| Queue-Operationen | `queue_file_utility.sh`, `process_queue.sh` |
| Dateisync/Verarbeitung | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python-Ausführungspfad | `autopub.py`, `process_video.py`, `video_utils.py` |

## Verarbeitungs-Architektur

1. **Dateierkennung**: `monitor_autopublish.sh` überwacht `close_write`/`moved_to`-Ereignisse.
2. **Queueing**: Gültige Dateien werden mit `flock` an `queue_list.txt` angehängt.
3. **Verarbeitung**: `process_queue.sh` verarbeitet Queue-Einträge und ruft `autopub.sh` auf.
4. **Upload/Processing/Publishing**: `autopub.py` und `process_video.py` rufen konfigurierte API-Endpunkte auf.
5. **Tracking**: Verarbeitete Dateien werden in `processed.csv`, entdeckte Dateien in `videos_db.csv` geschrieben.

## Praktische Beispiele

### Beispiel 1: End-to-end-Daemon-Modus 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Danach können Sie Videos in das konfigurierte Quellverzeichnis legen oder synchronisieren und Logs in den tmux-Panes beobachten.

### Beispiel 2: Erneuter Lauf passender Dateien 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Beispiel 3: Lokaler Test ohne Publishing 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Entwicklungshinweise

- Kein fest verankertes Dependency-Manifest (`requirements.txt` / `pyproject.toml`) im Repo-Root vorhanden.
- Laufzeit ist eng an Linux-Shell-Tools und lokale Pfadkonventionen gebunden.
- Aktuelle Skripte laden Shell-Konfiguration dynamisch (`autopub.config`); behalten Sie shell-kompatible Variablenausdrücke bei.
- Queue- und Lock-Semantik stützt sich auf `flock`; vermeiden Sie Änderungen, die atomare Queue-Updates schwächen.
- API-Vertragsdetails werden aus dem Client-Code abgeleitet; Serverimplementierung liegt außerhalb dieses Repos.
- Das Verzeichnis `i18n/` existiert, doch die Übersetzungen werden in diesem Entwurfszyklus nicht vollständig gepflegt.
- Generierte Artefakte (`queue_list.txt`, `temp_queue.txt` usw.) werden zur Laufzeit erstellt und können je nach Umgebung variieren.

## 🧱 Legacy-Namenskompatibilität (beibehalten)

Frühere Dokumentation nutzte andere Bezeichnungen für Komponenten. Die aktuellen Dateinamen im Repository bleiben wie unten aufgelistet.

| Früheres Dokumentationslabel | Aktuelle Repository-Datei |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Zur Erleichterung gilt für die Nutzung im Verzeichnis `cd autopub_monitor` die Äquivalenz zu älteren Dokumentationsbefehlen (pfadabhängig):

```bash
# Ältere Dokumentations-Form (äquivalente, pfadabhängige Befehle)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 🛠️ Fehlerbehebung

| Symptom | Prüfen Sie |
|---|---|
| `Miniconda not found at ~/miniconda3` | Installieren Sie Miniconda oder passen Sie `CONDA_DIR` in `autopub.config` an. |
| `inotifywait: command not found` | Installieren Sie `inotify-tools`. |
| `ffprobe`/`ffmpeg`-Fehler | Installieren Sie `ffmpeg`; prüfen Sie die Integrität der Eingabedatei. |
| Videos werden wiederholt nicht gequeued | Prüfen Sie `checked_list.txt`, `temp_queue.txt` und Logdateien von `monitor_autopublish.sh`. |
| Queue hängt oder Race-Bedingungen | Prüfen Sie `queue.lock`, `queue_list.txt` und aktive Prozesse mit `flock`. |
| API-Upload/Processing/Publish-Fehler | Verifizieren Sie `APP_API_BASE_URL` und die Endpoint-Pfade in `autopub.config`. |
| tmux-Service startet nicht | Prüfen Sie, ob `tmux has-session` funktioniert, und setzen Sie Skriptausführungsrechte korrekt. |

## 🗺️ Roadmap

- Pinnen von Abhängigkeitsverwaltung (`requirements.txt` oder `pyproject.toml`) hinzufügen.
- CI-Prüfungen für Shell-/Python-Linting und Basistests hinzufügen.
- Dokumentation zum API-Vertrag und zu Bereitstellungsannahmen ergänzen.
- `i18n/` mit gepflegten übersetzten READMEs erweitern.
- Beobachtbarkeit verbessern (strukturierte Logs und Health Checks).

## 🤝 Mitwirken

Beiträge sind willkommen.

Empfohlener Workflow:

1. Fork erstellen und Feature-Branch anlegen.
2. Änderungen klein und fokussiert halten (Skript + Docs zusammen).
3. In einer Linux-Umgebung mit benötigten Systemwerkzeugen validieren.
4. Einen Pull Request mit klaren Reproduktions- und Testhinweisen einreichen.

Wenn sich Verhalten ändert, beide Dateien aktualisieren:

- `README.md`
- `PROJECT_STRUCTURE.md` und/oder `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Kontakt

Bei Fragen, Fehlerberichten und Funktionswünschen:

- Öffnen Sie ein Issue unter [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 Danksagung

- Aufbauend auf Linux-nativem Tooling (`tmux`, `inotify`, `rsync`, `ffmpeg`) für robuste, langfristige Automatisierung.
- Dank an Mitwirkende und Nutzer, die die kontinuierliche Weiterentwicklung unterstützen.

## 📄 Lizenz

Apache License 2.0 - siehe [LICENSE](../LICENSE) für Details.
