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

> 動画コンテンツを複数のプラットフォームへ監視・処理・公開するための自動化システムです。

| What to expect | Detail |
|---|---|
| Runtime model | Linux-first automation with `tmux`, optional `systemd`, and queue locks |
| Queue design | File watcher → queue -> worker loop, with persistent state tracking |
| Extensibility | Shell orchestration + Python publish clients for platform adapters |
| Core entry points | `autopub_monitor_tmux_session.sh`, `autopub.sh`, `autopub.py` |

---

## 🧭 ドキュメントマップ

| セクション | 重要な理由 |
|---|---|
| [プロジェクトの全体像](#project-at-a-glance) | 実行モデルと目的を素早く把握 |
| [インストール](#installation) | クローンからサービス起動まで |
| [設定](#configuration) | 主要な設定項目とスクリプトの挙動を理解 |
| [使用方法](#usage) | 起動・停止・キュー投入・処理フローを確認 |
| [システム構成要素](#system-components) | shell と Python の役割分担を把握 |
| [トラブルシューティング](#troubleshooting) | 起動・キュー関連の問題を素早く解決 |
| [ロードマップ](#roadmap) | 近い将来の拡張計画を確認 |
| [コントリビューション](#contributing) | 安全に貢献する方法を確認 |

## 🧭 一覧で使えるクイックスタート

| 目的 | コマンド | 補足 |
|---|---|---|
| 監視パイプライン開始 | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | ウォッチャー + キュー + 同期 + 手動ペインを起動 |
| 全サービス停止 | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | 安全に停止し、ペインを整理 |
| パターン指定でキュー追加 | `./autopub_monitor/queue_file_utility.sh "pattern"` | 条件一致ファイルを処理キューへ追加 |
| ファイル単体処理 | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | 既定の処理設定と公開設定で実行 |

<a id="project-at-a-glance"></a>
## 🎯 プロジェクトの全体像

| 注目点 | 詳細 |
|---|---|
| 実行ターゲット | Linux（`tmux` オーケストレーション、`systemd` は任意） |
| キューモデル | ファイル監視 → キュー → ワーカー → 公開パイプライン |
| コアエントリポイント | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| 状態管理 | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## 🔎 概要

AutoPubMonitor は、動画コンテンツの処理とマルチプラットフォーム公開を目的とした、Linux 向けの自動化パイプラインです。新着の動画ファイルを監視し、互換性修復、必要に応じた補助処理、API 経由の文字起こし・翻訳関連処理を経て、設定済みのプラットフォームへ公開します。

ランタイムは shell オーケストレーション（`tmux`、`inotifywait`、`rsync`、`flock`）で構成され、Python の処理クライアントと CSV / テキストベースの状態管理を組み合わせています。

## ⚡ 主な機能

| 機能 | 詳細 |
|---|---|
| 自動ファイル検知 | 新規動画コンテンツを監視し、検出時に追加 |
| キュー管理 | 動画を制御された順序で順次処理 |
| 動画処理 | 長さと形式を検証し、公開向けに整形 |
| マルチプラットフォーム公開 | XiaoHongShu、Bilibili、Douyin、ShiPinHao、YouTube に対応 |
| キャッシュ | 重複処理を減らすキャッシュ機能 |
| ファイル同期 | 端末間のファイル移動をハンドリング |
| 集約設定 | すべてのパスと設定を1つの設定ファイルで管理 |
| 簡易導入 | 1 本のセットアップスクリプトで初期構成 |
| 動画互換性修復 | FFmpeg 検査＋必要に応じた HandBrakeCLI フォールバック |
| サービス運用 | `tmux` セッション + `systemd` サービス（任意） |
| 多言語ドキュメント | ルートの言語切替リンクと `i18n/` の翻訳 |

## 🗂️ リポジトリ構成

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
## システム構成要素

### コア処理

| コンポーネント | 役割 |
|---|---|
| `autopub.py` | アップロード・処理・公開を統括するメインエンジン |
| `process_video.py` | アップロード、動画処理、結果処理を担当するクライアント |
| `video_utils.py` / `handbrake.py` | アップロード前の互換性チェックと修復 |

### キュー管理

| コンポーネント | 役割 |
|---|---|
| `process_queue.sh` | `flock` によるロックと再試行ループを持つキューコンシューマ |
| `queue_file_utility.sh` | パスまたはファイル名パターンで手動キュー投入 |

### サービス管理

| コンポーネント | 役割 |
|---|---|
| `autopub_monitor_tmux_session.sh` | マルチペインの tmux サービスを起動 / 停止 |
| `autopub.sh` | `autopub.py` 向けの Conda / bootstrap ラッパー |
| `autopub_sync.sh` | リモートまたは同期元ディレクトリからのファイル同期 |
| `monitor_autopublish.sh` | `inotify` ウォッチャーとして新規ファイル監視とキュー登録 |

### ユーティリティ

| コンポーネント | 役割 |
|---|---|
| `window_info_utility.py` | `xdotool` を使ったアクティブウィンドウ情報取得（任意） |
| `autopub.config` | 中央設定ファイル |
| `install_autopub_monitor.sh` | インストールと `systemd` 設定補助 |

<a id="prerequisites"></a>
## 前提条件

| 要件 | 補足 |
|---|---|
| bash 利用可能な Linux 環境 | 主な実行ターゲット |
| Python 3.8+ | インストーラーは Python 3.8 の conda 環境を作成 |
| `${HOME}/miniconda3` に Miniconda | スクリプトの既定パス |
| `ffmpeg` / `ffprobe` | 動画の検証・処理に必須 |
| `tmux` | サービスオーケストレーション |
| `inotify-tools` | ファイルイベント監視（`inotifywait`） |
| `rsync` | ディレクトリ / システム間の同期 |
| `python3-pip` | Python パッケージのインストール |
| 任意: `HandBrakeCLI` | 問題動画の修復に推奨 |
| 任意: `xdotool` | `window_info_utility.py` 実行時に必要 |

リポジトリ内スクリプトで利用される Python パッケージ:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

<a id="installation"></a>
## インストール

### 🚀 自動インストール（スクリプト）

リポジトリルートから:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

インストーラーは次を実行します:

- 依存パッケージを apt でインストール（`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`）
- conda 環境 `autopub-video` を作成・有効化
- Python パッケージをインストール（`requests`, `requests_toolbelt`, `selenium`）
- ランタイムディレクトリと状態ファイルを作成
- `autopub-monitor.service` をインストールして有効化

### 🧩 サービスの有効化／起動（インストーラーが未実行の場合）

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 手動セットアップ

1. 環境に合わせて `autopub_monitor/autopub.config` を確認・編集します。
2. 環境作成と有効化:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. スクリプトに実行権限を付与:

```bash
chmod +x autopub_monitor/*.sh
```

> 想定: 実行時の状態ファイル（例: `queue.lock`, `temp_queue.txt`, `checked_list.txt`）は、既存または起動時/インストール時に作成済みである必要があります。

<a id="configuration"></a>
## 設定

主設定ファイル: `autopub_monitor/autopub.config`

主な設定項目:

- データディレクトリ: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 同期元ディレクトリ: `JIANGUOYUN_*`
- 状態ファイル: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- ロックファイル: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 設定: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 設定: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

補足:

- 既定では app API モード（`USE_APP_API="true"`）が優先され、`APP_API_BASE_URL` からエンドポイント URL が構成されます。
- 旧 API エンドポイントは参照用として config に残されています。
- すべてのスクリプトが同じ設定項目を参照する限り、キュー／ロック関連ファイル名の変更は低リスクです。

<a id="usage"></a>
## 使用方法

### ▶️ サービス起動

リポジトリルートから:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

起動されるもの:

- ファイル同期サービス
- ディレクトリ監視サービス
- キュー処理サービス
- 手動コマンド用ペイン
- 字幕同期 rsync セッション（`am-transcription-sync`）

### ⏹️ サービス停止

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 手動キュー管理

```bash
# パターン一致で追加
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# フルパスで追加
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# 自動承認（選択確認なし）
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 手動動画処理

```bash
# ラッパーの既定値で特定ファイルを処理
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 公開ターゲットを明示して CLI を直接実行
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# キャッシュ利用 + 進捗表示
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 公開せずにアップロード/処理のみ
python autopub_monitor/autopub.py --no-pub --path "/path/to/video.mp4"
```

## CLI オプション（`autopub.py`）

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

動作メモ:

- app API モード（`USE_APP_API=true`）では、公開オプション（`--pub-*`）を明示しない限り既定で公開は無効化されます。

## 🎛️ コマンドパレット

| 領域 | 例 |
|---|---|
| サービス操作 | `autopub_monitor_tmux_session.sh start/stop` |
| キュー操作 | `queue_file_utility.sh`, `process_queue.sh` |
| ファイル同期 / 処理 | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Python 実行経路 | `autopub.py`, `process_video.py`, `video_utils.py` |

## 処理アーキテクチャ

1. **ファイル検出**: `monitor_autopublish.sh` が `close_write` / `moved_to` イベントを監視
2. **キュー登録**: 有効なファイルは `flock` で `queue_list.txt` に追記
3. **処理**: `process_queue.sh` がキューエントリを消費し `autopub.sh` を実行
4. **アップロード / 処理 / 公開**: `autopub.py` と `process_video.py` が設定済み API エンドポイントを呼び出し
5. **追跡**: 処理済みファイルは `processed.csv` に、発見ファイルは `videos_db.csv` に保存

## 実践例

### 例1: エンドツーエンドのデーモン運用 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

その後、設定済みのソースディレクトリに動画を置くか同期し、tmux ペインでログを確認します。

### 例2: 一致ファイルの再実行 🧭

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 例3: 公開なしのローカルテスト 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 開発ノート

- リポジトリルートには固定の依存定義ファイル（`requirements.txt` / `pyproject.toml`）は存在しません。
- 実行は Linux の shell ツールとローカルのパス規約に強く依存しています。
- 現行スクリプトは起動時に `autopub.config` を動的に読み込むため、シェル互換の変数式を維持してください。
- キューとロックは `flock` に依存するため、原子的なキュー更新を崩す変更は避けてください。
- API 契約の詳細はクライアント実装から推定されるため、サーバ実装はこのリポジトリ外です。
- `i18n/` は存在しますが、翻訳 README はこのドラフト周期では完全に維持されていません。
- 処理済みアーティファクト（`queue_list.txt`, `temp_queue.txt` など）は、実行時に生成・管理されることが多く、環境で差があります。

## Legacy Name Compatibility（互換）

過去のドキュメントでは、リネーム前のコンポーネント名が使われていました。現行のファイル名は下記です。

| 旧ドキュメント名 | 現在のリポジトリファイル |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

`cd autopub_monitor` 時、旧ドキュメント形式のコマンドは以下と同等です。

```bash
# 旧ドキュメント形式（同等の相対パスコマンド）
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

<a id="troubleshooting"></a>
## 🛠️ トラブルシューティング

| 症状 | 確認項目 |
|---|---|
| `Miniconda not found at ~/miniconda3` | Miniconda をインストールするか、`autopub.config` の `CONDA_DIR` を更新 |
| `inotifywait: command not found` | `inotify-tools` をインストール |
| `ffprobe` / `ffmpeg` の失敗 | `ffmpeg` をインストールし、入力ファイルの整合性を確認 |
| Videos repeatedly not queued | `checked_list.txt`、`temp_queue.txt`、`monitor_autopublish.sh` の監視ログを確認 |
| Queue stuck or race concerns | `queue.lock`、`queue_list.txt`、`flock` 利用中プロセスを確認 |
| API upload/process/publish errors | `autopub.config` の `APP_API_BASE_URL` とエンドポイントパスを確認 |
| tmux service not starting | `tmux has-session` が動作し、スクリプトに実行権限があるか確認 |

<a id="roadmap"></a>
## 🗺️ ロードマップ

- 依存関係の固定化（`requirements.txt` または `pyproject.toml`）を追加
- シェル/Python の lint と基本統合テストを含む CI を追加
- API 契約とデプロイ前提のドキュメントを追加
- 維持更新可能な `i18n/` の拡充
- 観測可能性（構造化ログとヘルスチェック）の改善

<a id="contributing"></a>
## 🤝 コントリビューション

コントリビューションを歓迎します。

推奨ワークフロー:

1. フォークして feature branch を作成
2. 変更は小さく絞る（スクリプトとドキュメントをまとめて更新）
3. Linux 環境で必須システムツールを整え、検証
4. 再現手順と検証メモを明示した Pull Request を提出

動作に変更がある場合は次も更新してください。

- `README.md`
- `PROJECT_STRUCTURE.md` と/または `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 Contact

ご質問、バグ報告、機能要望は以下で受け付けます。

- [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues) で issue を開いてください。

## 謝辞

- Linux のネイティブツール（`tmux`、`inotify`、`rsync`、`ffmpeg`）を軸に、長時間安定稼働する自動化を実現しています。
- 改善を継続するために協力してくださるコントリビューターとユーザーに感謝します。

## 📄 License

Apache License 2.0 - 詳細は [LICENSE](../LICENSE) を参照してください。
