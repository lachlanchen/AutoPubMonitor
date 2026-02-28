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

> Système automatisé de surveillance, de traitement et de publication de contenu vidéo sur plusieurs plateformes.

| À attendre | Détail |
|---|---|
| Modèle d’exécution | Automatisation orientée Linux avec `tmux`, `systemd` optionnel, et verrous de file d’attente |
| Conception de la file | Observateur de fichiers → file d’attente → boucle worker, avec suivi d’état persistant |
| Extensibilité | Orchestration shell + clients Python de publication pour les adaptateurs de plateforme |
| Points d’entrée principaux | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 Carte de documentation

| Section | Pourquoi c’est utile |
|---|---|
| [Aperçu du projet](#project-at-a-glance) | Comprendre rapidement le modèle d’exécution et les objectifs |
| [Installation](#installation) | Passer du clone au service fonctionnel |
| [Configuration](#configuration) | Comprendre chaque réglage important au niveau script |
| [Utilisation](#usage) | Démarrer, arrêter, mettre en file et traiter les workflows |
| [Composants du système](#system-components) | Distinguer les responsabilités entre shell et Python |
| [Dépannage](#troubleshooting) | Résoudre rapidement les problèmes de démarrage et de queue |
| [Feuille de route](#roadmap) | Suivre les plans proches d’évolutions |
| [Contribuer](#contributing) | Comprendre les pratiques de contribution sans risque |

## 🧭 Démarrage rapide en bref

| Objectif | Commande | Remarques |
|---|---|---|
| Démarrer le pipeline de surveillance | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Démarre l’observateur + file d’attente + synchronisation + panneau manuel |
| Arrêter tous les services | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Arrêt propre et nettoyage des panneaux |
| Mettre en file par motif | `./autopub_monitor/queue_file_utility.sh "pattern"` | Ajoute les fichiers correspondants à la file d’attente |
| Traiter un fichier | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Utilise la configuration et le traitement par défaut |

## 🎯 Présentation du projet {#project-at-a-glance}

| Axe | Détails |
|---|---|
| Cible d’exécution | Linux, avec orchestration `tmux` et `systemd` optionnel |
| Modèle de file | Observateur de fichiers → file d’attente → scripts worker → pipeline de publication |
| Points d’entrée principaux | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| Suivi d’état | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 Aperçu

AutoPubMonitor est une chaîne d’automatisation orientée Linux pour le traitement vidéo et la publication multi-plateforme. Le système détecte les nouveaux fichiers vidéo, les traite via des étapes de correction de compatibilité, d’augmentation optionnelle, de traitement/transcription/traduction via API, puis publie les résultats vers les plateformes configurées.

Le runtime est orchestré par des scripts shell (`tmux`, `inotifywait`, `rsync`, `flock`) avec des clients de traitement Python et un suivi d’état basé sur CSV/txt.

## ⚡ Fonctions clés

| Fonction | Détails |
|---|---|
| Détection de fichiers automatisée | Surveille les répertoires pour détecter du nouveau contenu vidéo |
| Gestion de file d’attente de traitement | Traite les vidéos de manière contrôlée et séquentielle |
| Traitement vidéo | Vérifie la durée, les formats et prépare les vidéos |
| Publication multi-plateforme | Prend en charge XiaoHongShu, Bilibili, Douyin, ShiPinHao et YouTube |
| Système de cache | Optimise le traitement en mettant en cache les résultats |
| Synchronisation de fichiers | Gère le déplacement de fichiers entre systèmes |
| Configuration centralisée | Tous les chemins et réglages dans un seul fichier de configuration |
| Installation simplifiée | Script unique pour configurer tout le système |
| Réparation de compatibilité vidéo | Utilise des vérifications FFmpeg et une reprise via HandBrakeCLI (facultatif) |
| Fonctionnement orienté service | Sessions `tmux` + service `systemd` optionnel |
| Documentation internationale | Liens de langue racine et traductions sous `i18n/` |

## 🗂️ Structure du dépôt

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

## Composants du système {#system-components}

### Traitement principal

| Composant | Rôle |
|---|---|
| `autopub.py` | Moteur de traitement principal orchestrant upload, traitement et publication |
| `process_video.py` | Client de traitement vidéo pour l’upload, le traitement et la gestion des résultats |
| `video_utils.py` / `handbrake.py` | Vérifications de compatibilité et réparations avant upload |

### Gestion des files d’attente

| Composant | Rôle |
|---|---|
| `process_queue.sh` | Consommateur de file avec verrou `flock` et boucle de réessai |
| `queue_file_utility.sh` | Remplissage manuel de file par chemin ou motif de nom |

### Gestion de service

| Composant | Rôle |
|---|---|
| `autopub_monitor_tmux_session.sh` | Lance/arrête les services `tmux` multi-panneaux |
| `autopub.sh` | Wrapper conda/bootstrappage pour `autopub.py` |
| `autopub_sync.sh` | Synchronisation de fichiers depuis des sources distantes/synchronisées |
| `monitor_autopublish.sh` | Observateur `inotify` pour les nouveaux fichiers et la mise en file |

### Utilitaires

| Composant | Rôle |
|---|---|
| `window_info_utility.py` | Utilitaire de fenêtre active via `xdotool` (optionnel) |
| `autopub.config` | Fichier de configuration central |
| `install_autopub_monitor.sh` | Aide à l’installation + configuration `systemd` |

## Prérequis {#prerequisites}

| Exigence | Remarques |
|---|---|
| Environnement Linux avec bash | Cible principale d’exécution |
| Python 3.8+ | L’installateur crée actuellement un environnement Conda Python 3.8 |
| Miniconda à `${HOME}/miniconda3` | Chemin attendu par défaut dans les scripts |
| `ffmpeg` / `ffprobe` | Requis pour la validation/traitement vidéo |
| `tmux` | Orchestration des services |
| `inotify-tools` | Surveillance d’événements de fichiers (`inotifywait`) |
| `rsync` | Synchronisation entre répertoires/systèmes |
| `python3-pip` | Installation des paquets Python |
| Optionnel : `HandBrakeCLI` | Recommandé pour réparer les vidéos problématiques |
| Optionnel : `xdotool` | Nécessaire pour `window_info_utility.py` |

Les paquets Python utilisés dans les scripts du dépôt incluent :

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Installation {#installation}

### 🚀 Installation automatique (scriptée)

Depuis la racine du dépôt :

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

L’installateur :

- Installe les dépendances apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Crée/utilise l’environnement conda `autopub-video`
- Installe les paquets Python (`requests`, `requests_toolbelt`, `selenium`)
- Crée les répertoires et fichiers d’état runtime
- Installe et active `autopub-monitor.service`

### 🧩 Activation/démarrage du service (si non déjà activé par l’installateur)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Configuration manuelle

1. Vérifiez et modifiez `autopub_monitor/autopub.config` pour votre environnement.
2. Créez et activez l’environnement :

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Rendez les scripts exécutables :

```bash
chmod +x autopub_monitor/*.sh
```

> Hypothèse : les fichiers d’état runtime du dépôt (par exemple `queue.lock`, `temp_queue.txt`, `checked_list.txt`) doivent exister déjà ou être créés par votre flux de démarrage/installation.

## Configuration {#configuration}

Fichier de configuration principal : `autopub_monitor/autopub.config`

Paramètres importants :

- Répertoires de données : `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Répertoires de source de synchronisation : `JIANGUOYUN_*`
- Fichiers d’état : `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Fichiers de verrouillage : `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Paramètres API : `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Réglages Conda : `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Remarques :

- La configuration par défaut privilégie actuellement le mode API applicative (`USE_APP_API="true"`) et construit les URLs d’endpoints depuis `APP_API_BASE_URL`.
- Les anciens endpoints sont toujours présents dans la configuration à titre de référence.
- Les noms de files de queue et verrous peuvent être modifiés avec un faible risque si tous les scripts référencent les mêmes entrées de config.

## Utilisation {#usage}

### ▶️ Démarrer les services

Depuis la racine du dépôt :

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Cela lance :

- Le service de synchronisation de fichiers
- Le service de surveillance de répertoires
- Le service de traitement de file d’attente
- Le volet de commande manuelle
- La session rsync de transcription (`am-transcription-sync`)

### ⏹️ Arrêter les services

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Gestion manuelle de la file

```bash
# Ajouter par motif
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Ajouter par chemin complet
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Ajouter avec confirmation automatique (sans invite de sélection)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Traitement vidéo manuel

```bash
# Traiter un fichier précis avec les valeurs par défaut du wrapper
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# CLI directe avec cibles de publication spécifiques
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Options de cache + visualisation de progression
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Upload/traitement sans publication
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

Note de comportement :

- En mode API applicative (`USE_APP_API=true`), la publication est désactivée par défaut sauf si des flags de publication sont passés explicitement.

## 🎛️ Panneau de commandes

| Zone | Exemples |
|---|---|
| Contrôles de service | `autopub_monitor_tmux_session.sh start/stop` |
| Opérations de file | `queue_file_utility.sh`, `process_queue.sh` |
| Synchronisation/traitement de fichiers | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Chaîne d’exécution Python | `autopub.py`, `process_video.py`, `video_utils.py` |

## Architecture de traitement

1. **Détection de fichiers** : `monitor_autopublish.sh` surveille les événements `close_write`/`moved_to`.
2. **Mise en file** : Les fichiers valides sont ajoutés à `queue_list.txt` via `flock`.
3. **Traitement** : `process_queue.sh` consomme les entrées de la file et appelle `autopub.sh`.
4. **Upload/traitement/publication** : `autopub.py` et `process_video.py` appellent les endpoints API configurés.
5. **Suivi** : Les fichiers traités sont enregistrés dans `processed.csv`, les fichiers découverts dans `videos_db.csv`.

## Exemples pratiques

### Exemple 1 : Mode démon en bout en bout 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Puis placez ou synchronisez vos vidéos dans le répertoire source configuré et surveillez les logs dans les panneaux `tmux`.

### Exemple 2 : Relancer de force les fichiers correspondants 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Exemple 3 : Test local sans publication 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 Notes de développement

- Aucun manifeste de dépendances verrouillées n’est présent à la racine du dépôt (`requirements.txt` / `pyproject.toml`).
- Le runtime dépend fortement des outils shell Linux et des conventions de chemin locales.
- Les scripts source du shell dynamiquement (`autopub.config`) ; conservez des expressions de variables compatibles shell.
- La sémantique de queue/verrouillage repose sur `flock` ; évitez les modifications qui fragilisent les mises à jour atomiques de file.
- Les détails du contrat API sont inférés depuis le code client ; l’implémentation serveur est externe à ce dépôt.
- Le répertoire `i18n/` existe mais les documentations traduites ne sont pas entièrement maintenues dans ce cycle de brouillon.
- Les fichiers d’artefacts traités (`queue_list.txt`, `temp_queue.txt`, etc.) sont typiquement générés/gérés à l’exécution et peuvent varier selon l’environnement.

## 🧱 Compatibilité des noms hérités (préservée)

La documentation précédente utilisait des noms de composants renommés. Les noms de fichiers actuels du dépôt restent ceux listés ci-dessous.

| Libellé dans les anciennes docs | Fichier actuel du dépôt |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Pour votre confort, si vous `cd autopub_monitor`, ces formes de commande issues d’anciennes docs correspondent à :

```bash
# Ancien style de docs (commandes équivalentes selon le répertoire)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## 🛠️ Dépannage {#troubleshooting}

| Symptôme | À vérifier |
|---|---|
| `Miniconda not found at ~/miniconda3` | Installez Miniconda ou mettez à jour `CONDA_DIR` dans `autopub.config`. |
| `inotifywait: command not found` | Installez `inotify-tools`. |
| Échecs `ffprobe`/`ffmpeg` | Installez `ffmpeg` ; vérifiez l’intégrité du fichier d’entrée. |
| Vidéos non mises en file de manière répétée | Vérifiez `checked_list.txt`, `temp_queue.txt` et les logs de `monitor_autopublish.sh`. |
| File bloquée ou problèmes de concurrence | Inspectez `queue.lock`, `queue_list.txt` et les processus actifs avec `flock`. |
| Erreurs API upload/traitement/publication | Vérifiez `APP_API_BASE_URL` et les chemins d’endpoints dans `autopub.config`. |
| Service tmux ne démarre pas | Confirmez que `tmux has-session` fonctionne et que les scripts sont exécutables. |

## 🗺️ Feuille de route {#roadmap}

- Ajouter une gestion des dépendances figée (`requirements.txt` ou `pyproject.toml`).
- Ajouter des vérifications CI pour lint shell/Python et tests d’intégration de base.
- Ajouter une documentation sur le contrat API et les hypothèses de déploiement.
- Étendre `i18n/` avec des `README` traduits et maintenus.
- Améliorer l’observabilité (logs structurés et health checks).

## 🤝 Contribuer {#contributing}

Les contributions sont les bienvenues.

Flux recommandé :

1. Forker et créer une branche de fonctionnalité.
2. Garder les changements petits et ciblés (mises à jour script + docs ensemble).
3. Valider sur un environnement Linux avec les outils système requis.
4. Soumettre une pull request avec des notes de reproduction/tests claires.

Si le comportement évolue, mettez à jour :

- `README.md`
- `PROJECT_STRUCTURE.md` et/ou `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Contact

Pour les questions, rapports de bugs et demandes de fonctionnalités :

- Ouvrez une issue sur [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 Remerciements

- Conçu autour d’outillage natif Linux (`tmux`, `inotify`, `rsync`, `ffmpeg`) pour une automatisation fiable sur la durée.
- Merci aux contributeurs et utilisateurs qui soutiennent les améliorations continues.

## 📄 Licence

Apache License 2.0 - Voir [LICENSE](LICENSE) pour plus de détails.
