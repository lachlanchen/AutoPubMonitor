[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="Bannière LazyingArt" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#prerequisites)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#prerequisites)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#usage)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

Un système automatisé pour surveiller, traiter et publier du contenu vidéo sur plusieurs plateformes.

## Vue d'ensemble

AutoPubMonitor est un pipeline d'automatisation orienté Linux pour le traitement de contenus vidéo et la publication multi-plateforme. Le système détecte les nouveaux fichiers vidéo, les traite via plusieurs étapes incluant la réparation de compatibilité, l'augmentation optionnelle, le traitement lié à la transcription/traduction via API, puis publie les résultats vers les plateformes configurées.

L'exécution est orchestrée par des scripts shell (`tmux`, `inotifywait`, `rsync`, `flock`) avec des clients de traitement Python et un suivi d'état via CSV/texte.

## Fonctionnalités clés

| Capacité | Détails |
|---|---|
| Détection automatisée de fichiers | Surveille les répertoires pour détecter de nouveaux contenus vidéo |
| Gestion de file de traitement | Traite les vidéos de manière contrôlée et séquentielle |
| Traitement vidéo | Vérifie la durée, les formats et prépare les vidéos |
| Publication multi-plateforme | Prend en charge XiaoHongShu, Bilibili, Douyin, ShiPinHao et YouTube |
| Système de cache | Optimise le traitement en mettant en cache les résultats |
| Synchronisation de fichiers | Gère les déplacements de fichiers entre systèmes |
| Configuration centralisée | Tous les chemins et paramètres dans un seul fichier de configuration |
| Installation simple | Script unique pour installer l'ensemble du système |
| Réparation de compatibilité vidéo | Utilise des vérifications FFmpeg et un repli optionnel via HandBrakeCLI |
| Exploitation orientée service | Sessions `tmux` + service `systemd` optionnel |

## Structure du dépôt

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

## Composants du système

### Traitement principal

| Composant | Rôle |
|---|---|
| `autopub.py` | Moteur principal qui orchestre upload/traitement/publication |
| `process_video.py` | Client de traitement vidéo pour l'upload, le traitement et la gestion des résultats |
| `video_utils.py` / `handbrake.py` | Vérifications de compatibilité et réparations avant l'upload |

### Gestion de file

| Composant | Rôle |
|---|---|
| `process_queue.sh` | Consommateur de file avec verrouillage `flock` et boucle de reprise |
| `queue_file_utility.sh` | Alimentation manuelle de la file par chemin ou motif de nom de fichier |

### Gestion des services

| Composant | Rôle |
|---|---|
| `autopub_monitor_tmux_session.sh` | Démarre/arrête les services tmux multi-panneaux |
| `autopub.sh` | Wrapper Conda/bootstrap pour `autopub.py` |
| `autopub_sync.sh` | Synchronisation de fichiers depuis le chemin Nutstore/Jianguoyun |
| `monitor_autopublish.sh` | Surveillant `inotify` pour les nouveaux fichiers et leur mise en file |

### Utilitaires

| Composant | Rôle |
|---|---|
| `window_info_utility.py` | Utilitaire de fenêtre active via `xdotool` (optionnel) |
| `autopub.config` | Fichier de configuration central |
| `install_autopub_monitor.sh` | Assistant d'installation + configuration systemd |

## Prérequis

| Exigence | Notes |
|---|---|
| Environnement Linux avec bash | Cible principale d'exécution |
| Python 3.8+ | L'installateur crée actuellement un env conda Python 3.8 |
| Miniconda dans `${HOME}/miniconda3` | Chemin attendu par défaut dans les scripts |
| `ffmpeg` / `ffprobe` | Requis pour la validation/le traitement vidéo |
| `tmux` | Orchestration des services |
| `inotify-tools` | Surveillance des événements fichiers (`inotifywait`) |
| `rsync` | Synchronisation entre répertoires/systèmes |
| `python3-pip` | Installation des paquets Python |
| Optionnel : `HandBrakeCLI` | Recommandé pour réparer des vidéos problématiques |
| Optionnel : `xdotool` | Nécessaire pour `window_info_utility.py` |

Les paquets Python utilisés dans les scripts du dépôt incluent :

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation

### 🚀 Installation automatique (scriptée)

Depuis la racine du dépôt :

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

L'installateur :

- Installe les dépendances apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Crée/utilise l'environnement conda `autopub-video`
- Installe les paquets Python (`requests`, `requests_toolbelt`, `selenium`)
- Crée les répertoires d'exécution et les fichiers d'état
- Installe et active `autopub-monitor.service`

### 🧩 Activer/Démarrer le service (s'il n'est pas déjà activé par l'installateur)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Configuration manuelle

1. Vérifiez et modifiez `autopub_monitor/autopub.config` selon votre environnement.
2. Créez et activez l'environnement :

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Rendez les scripts exécutables :

```bash
chmod +x autopub_monitor/*.sh
```

## Configuration

Fichier de configuration principal : `autopub_monitor/autopub.config`

Paramètres importants :

- Répertoires de données : `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Répertoires source de synchronisation : `JIANGUOYUN_*`
- Fichiers d'état : `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Fichiers de verrouillage : `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Paramètres API : `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Paramètres Conda : `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Notes :

- La configuration par défaut privilégie actuellement le mode API applicatif (`USE_APP_API="true"`) et construit les URL d'endpoint depuis `APP_API_BASE_URL`.
- Les endpoints hérités sont toujours présents dans la configuration à titre de référence.

## Utilisation

### ▶️ Démarrer les services

Depuis la racine du dépôt :

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Cela démarre :

- Service de synchronisation de fichiers
- Service de surveillance de répertoire
- Service de traitement de file
- Panneau de commande manuelle
- Session rsync de transcription (`am-transcription-sync`)

### ⏹️ Arrêter les services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Gestion manuelle de la file

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Traitement vidéo manuel

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

## Options CLI (`autopub.py`)

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

Remarque de comportement :

- En mode API applicatif (`USE_APP_API=true`), la publication est désactivée par défaut, sauf si des drapeaux de publication sont explicitement fournis.

## Architecture de traitement

1. **Détection de fichiers** : `monitor_autopublish.sh` surveille les événements `close_write`/`moved_to`.
2. **File** : les fichiers valides sont ajoutés à `queue_list.txt` via `flock`.
3. **Traitement** : `process_queue.sh` consomme les entrées de la file et appelle `autopub.sh`.
4. **Upload/Traitement/Publication** : `autopub.py` et `process_video.py` appellent les endpoints API configurés.
5. **Suivi** : les fichiers traités sont écrits dans `processed.csv`, les fichiers détectés dans `videos_db.csv`.

## Exemples pratiques

### Exemple 1 : mode daemon de bout en bout 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Déposez ou synchronisez ensuite des vidéos dans votre répertoire source configuré et surveillez les logs dans les panneaux tmux.

### Exemple 2 : forcer une relance sur des fichiers correspondants 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Exemple 3 : test local sans publication 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Notes de développement

- Aucun manifeste de dépendances figé (`requirements.txt` / `pyproject.toml`) n'est présent à la racine du dépôt.
- L'exécution est fortement liée aux outils shell Linux et aux conventions de chemins locaux.
- Les scripts actuels chargent dynamiquement la configuration shell (`autopub.config`) ; conservez des expressions de variables compatibles shell.
- La sémantique de file et de verrouillage repose sur `flock` ; évitez les modifications qui affaiblissent les mises à jour atomiques de la file.
- Les détails du contrat API sont déduits du code client ; l'implémentation serveur est externe à ce dépôt.
- Le répertoire `i18n/` existe, mais les documents de langue ne sont pas encore entièrement peuplés dans ce cycle de brouillon.

## Compatibilité avec les noms historiques (préservée)

La documentation précédente utilisait des libellés de composants renommés. Les noms de fichiers actuels du dépôt restent ceux listés ci-dessous.

| Libellé dans l'ancienne doc | Fichier actuel du dépôt |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Pour plus de commodité, si vous faites `cd autopub_monitor`, ces formes de commandes de style ancien documentées auparavant correspondent à :

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Dépannage

| Symptôme | Vérifications |
|---|---|
| `Miniconda not found at ~/miniconda3` | Installez Miniconda ou mettez à jour `CONDA_DIR` dans `autopub.config`. |
| `inotifywait: command not found` | Installez `inotify-tools`. |
| Échecs `ffprobe`/`ffmpeg` | Installez `ffmpeg` ; validez l'intégrité du fichier d'entrée. |
| Les vidéos ne sont jamais mises en file | Vérifiez `checked_list.txt`, `temp_queue.txt` et les logs de `monitor_autopublish.sh`. |
| File bloquée ou craintes de concurrence | Inspectez `queue.lock`, `queue_list.txt` et les processus actifs utilisant `flock`. |
| Erreurs API upload/traitement/publication | Vérifiez `APP_API_BASE_URL` et les chemins d'endpoint dans `autopub.config`. |
| Service tmux qui ne démarre pas | Vérifiez que `tmux has-session` fonctionne et que les permissions d'exécution des scripts sont définies. |

## Feuille de route

- Ajouter une gestion figée des dépendances (`requirements.txt` ou `pyproject.toml`).
- Ajouter des vérifications CI pour le lint shell/Python et des tests d'intégration de base.
- Ajouter une documentation sur le contrat API et les hypothèses de déploiement.
- Étendre `i18n/` avec des README traduits maintenus.
- Améliorer l'observabilité (logs structurés et health checks).

## Contribution

Les contributions sont les bienvenues.

Workflow recommandé :

1. Forkez et créez une branche de fonctionnalité.
2. Gardez les changements petits et ciblés (scripts + documentation mis à jour ensemble).
3. Validez dans un environnement Linux avec les outils système requis.
4. Soumettez une pull request avec des notes claires de reproduction/test.

Si le comportement change, mettez à jour les deux :

- `README.md`
- `PROJECT_STRUCTURE.md` et/ou `autopub_monitor/README.md`

## Support et sponsor

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Site web: https://lazying.art
- Chat communautaire: https://chat.lazying.art
- Hub d'idées: https://onlyideas.art

(D'après `.github/FUNDING.yml`)

## Remerciements

- Construit autour d'outils natifs Linux (`tmux`, `inotify`, `rsync`, `ffmpeg`) pour une automatisation fiable de longue durée.
- Merci aux contributeurs et aux utilisateurs qui soutiennent les améliorations continues.

## Licence

Apache License 2.0 - Voir [LICENSE](LICENSE) pour les détails.
