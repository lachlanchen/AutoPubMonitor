[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt バナー" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#前提条件)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#前提条件)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#使用方法)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

複数プラットフォームへの動画コンテンツの監視・処理・公開を自動化するシステムです。

## 概要

AutoPubMonitor は、動画コンテンツ処理とマルチプラットフォーム公開のための Linux 指向の自動化パイプラインです。新しい動画ファイルを監視し、互換性修復、任意の拡張、API を介した文字起こし/翻訳関連処理などのステップを実行して、設定されたプラットフォームへ結果を公開します。

実行基盤はシェルでオーケストレーションされており（`tmux`, `inotifywait`, `rsync`, `flock`）、Python の処理クライアントと CSV/テキストの状態追跡を組み合わせています。

## 主な機能

| 機能 | 詳細 |
|---|---|
| 自動ファイル検出 | 新しい動画コンテンツをディレクトリ監視で検出 |
| 処理キュー管理 | 制御された逐次方式で動画を処理 |
| 動画処理 | 長さ・フォーマットを確認し動画を準備 |
| マルチプラットフォーム公開 | XiaoHongShu、Bilibili、Douyin、ShiPinHao、YouTube に対応 |
| キャッシュシステム | 結果キャッシュにより処理を最適化 |
| ファイル同期 | システム間のファイル移動を処理 |
| 一元設定 | すべてのパスと設定を単一の設定ファイルで管理 |
| 簡単インストール | 単一スクリプトでシステム全体をセットアップ |
| 動画互換性修復 | FFmpeg チェックと任意の HandBrakeCLI フォールバックを使用 |
| サービス指向の運用 | `tmux` セッション + 任意の `systemd` サービス |

## リポジトリ構成

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

## システム構成要素

### コア処理

| コンポーネント | 役割 |
|---|---|
| `autopub.py` | アップロード/処理/公開のオーケストレーションを担うメイン処理エンジン |
| `process_video.py` | アップロード、処理、結果ハンドリングを行う動画処理クライアント |
| `video_utils.py` / `handbrake.py` | アップロード前の互換性チェックと修復 |

### キュー管理

| コンポーネント | 役割 |
|---|---|
| `process_queue.sh` | `flock` ロックとリトライループを備えたキューコンシューマ |
| `queue_file_utility.sh` | パスまたはファイル名パターンによる手動キュー投入 |

### サービス管理

| コンポーネント | 役割 |
|---|---|
| `autopub_monitor_tmux_session.sh` | マルチペイン tmux サービスの起動/停止 |
| `autopub.sh` | `autopub.py` 用の Conda/ブートストラップラッパー |
| `autopub_sync.sh` | Nutstore/Jianguoyun パスからのファイル同期 |
| `monitor_autopublish.sh` | 新規ファイル監視とキュー投入を行う `inotify` ウォッチャー |

### ユーティリティ

| コンポーネント | 役割 |
|---|---|
| `window_info_utility.py` | `xdotool` を使うアクティブウィンドウユーティリティ（任意） |
| `autopub.config` | 中央設定ファイル |
| `install_autopub_monitor.sh` | インストール + systemd セットアップ補助 |

## 前提条件

| 要件 | 備考 |
|---|---|
| bash が使える Linux 環境 | 主な実行対象 |
| Python 3.8+ | インストーラーは現在 Python 3.8 の conda 環境を作成 |
| `${HOME}/miniconda3` に Miniconda | スクリプトでの既定想定パス |
| `ffmpeg` / `ffprobe` | 動画検証/処理に必須 |
| `tmux` | サービスオーケストレーション |
| `inotify-tools` | ファイルイベント監視（`inotifywait`） |
| `rsync` | ディレクトリ/システム間同期 |
| `python3-pip` | Python パッケージインストール |
| 任意: `HandBrakeCLI` | 問題のある動画の修復に推奨 |
| 任意: `xdotool` | `window_info_utility.py` に必要 |

リポジトリのスクリプトで使用される Python パッケージ:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## インストール

### 🚀 自動インストール（スクリプト）

リポジトリルートから:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

インストーラーは以下を実行します:

- apt 依存関係をインストール（`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`）
- conda 環境 `autopub-video` を作成/利用
- Python パッケージをインストール（`requests`, `requests_toolbelt`, `selenium`）
- 実行用ディレクトリと状態ファイルを作成
- `autopub-monitor.service` をインストールして有効化

### 🧩 サービスの有効化/起動（インストーラーで未有効の場合）

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ 手動セットアップ

1. 環境に合わせて `autopub_monitor/autopub.config` を確認・編集します。
2. 環境を作成して有効化します:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. スクリプトに実行権限を付与します:

```bash
chmod +x autopub_monitor/*.sh
```

## 設定

主要設定ファイル: `autopub_monitor/autopub.config`

主な設定項目:

- データディレクトリ: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- 同期元ディレクトリ: `JIANGUOYUN_*`
- 状態ファイル: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- ロックファイル: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- API 設定: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Conda 設定: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

補足:

- 既定の設定は現在 app API モード（`USE_APP_API="true"`）を優先し、`APP_API_BASE_URL` からエンドポイント URL を構築します。
- 旧エンドポイント設定も参照用として config に残っています。

## 使用方法

### ▶️ サービス起動

リポジトリルートから:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

以下が起動します:

- ファイル同期サービス
- ディレクトリ監視サービス
- キュー処理サービス
- 手動コマンド用ペイン
- 文字起こし rsync セッション（`am-transcription-sync`）

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

# 自動確認ありで追加（選択プロンプトなし）
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 手動動画処理

```bash
# ラッパー既定値で特定ファイルを処理
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# 特定公開先を指定した直接 CLI 実行
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# キャッシュオプション + 進捗可視化
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# 公開せずにアップロード/処理
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

挙動に関する注記:

- app API モード（`USE_APP_API=true`）では、公開フラグを明示的に渡さない限り、公開は既定で無効です。

## 処理アーキテクチャ

1. **ファイル検出**: `monitor_autopublish.sh` が `close_write` / `moved_to` イベントを監視。
2. **キュー**: 有効なファイルを `flock` を使って `queue_list.txt` に追記。
3. **処理**: `process_queue.sh` がキューを消費し、`autopub.sh` を呼び出し。
4. **アップロード/処理/公開**: `autopub.py` と `process_video.py` が設定済み API エンドポイントを呼び出し。
5. **追跡**: 処理済みファイルは `processed.csv`、検出済みファイルは `videos_db.csv` に記録。

## 実用例

### 例1: エンドツーエンドのデーモンモード 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

その後、設定済みソースディレクトリに動画を配置または同期し、tmux ペインのログを監視してください。

### 例2: 一致ファイルを強制再実行 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### 例3: 公開なしでローカルテスト 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 開発ノート

- リポジトリルートに固定依存マニフェスト（`requirements.txt` / `pyproject.toml`）はありません。
- 実行時は Linux のシェルツールとローカルパス規約に強く依存します。
- 現行スクリプトはシェル設定（`autopub.config`）を動的に読み込むため、シェル互換の変数式を維持してください。
- キューとロックの意味論は `flock` に依存しているため、キュー更新の原子性を損なう編集は避けてください。
- API 契約の詳細はクライアントコードから推測されており、サーバー実装はこのリポジトリ外です。
- このドラフトサイクルでは `i18n/` ディレクトリは存在しますが、言語ドキュメントはまだ完全には整備されていません。

## 旧名称との互換性（保持）

過去のドキュメントではリネーム前のコンポーネント名が使われていました。現在のリポジトリ上のファイル名は以下のとおりです。

| 以前のドキュメント名 | 現在のリポジトリファイル |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

利便性のため、`cd autopub_monitor` している場合、旧ドキュメント形式の以下コマンドは同等です:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## トラブルシューティング

| 症状 | 確認事項 |
|---|---|
| `Miniconda not found at ~/miniconda3` | Miniconda をインストールするか、`autopub.config` の `CONDA_DIR` を更新してください。 |
| `inotifywait: command not found` | `inotify-tools` をインストールしてください。 |
| `ffprobe` / `ffmpeg` の失敗 | `ffmpeg` をインストールし、入力ファイルの整合性を確認してください。 |
| 動画が繰り返しキューに入らない | `checked_list.txt`、`temp_queue.txt`、`monitor_autopublish.sh` の監視ログを確認してください。 |
| キュー停止や競合の懸念 | `queue.lock`、`queue_list.txt`、`flock` を使用している実行中プロセスを確認してください。 |
| API の upload/process/publish エラー | `autopub.config` の `APP_API_BASE_URL` とエンドポイントパスを確認してください。 |
| tmux サービスが起動しない | `tmux has-session` が動作することと、スクリプト実行権限が設定済みであることを確認してください。 |

## ロードマップ

- 依存関係の固定管理（`requirements.txt` または `pyproject.toml`）を追加。
- シェル/Python の lint と基本統合テストの CI チェックを追加。
- API 契約とデプロイ前提に関するドキュメントを追加。
- 継続保守される翻訳 README で `i18n/` を拡充。
- 可観測性（構造化ログとヘルスチェック）を改善。

## コントリビューション

コントリビューションを歓迎します。

推奨ワークフロー:

1. Fork して機能ブランチを作成。
2. 変更は小さく焦点を絞る（スクリプト更新とドキュメント更新を一緒に）。
3. 必要なシステムツールを備えた Linux 環境で検証。
4. 再現手順/テストノートを明確にしたプルリクエストを提出。

挙動を変更した場合は、以下の両方を更新してください:

- `README.md`
- `PROJECT_STRUCTURE.md` および/または `autopub_monitor/README.md`

## サポートとスポンサー

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

（`.github/FUNDING.yml` より）

## 謝辞

- 長時間稼働の自動化を安定させるため、Linux ネイティブツール（`tmux`, `inotify`, `rsync`, `ffmpeg`）を中心に構築されています。
- 継続的な改善を支えてくれるコントリビューターとユーザーの皆さまに感謝します。

## ライセンス

Apache License 2.0 - 詳細は [LICENSE](../LICENSE) を参照してください。
