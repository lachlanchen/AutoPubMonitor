[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="LazyingArt banner" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#المتطلبات-الأساسية)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#المتطلبات-الأساسية)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#الاستخدام)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

نظام آلي لمراقبة محتوى الفيديو ومعالجته ونشره على منصات متعددة.

## نظرة عامة

AutoPubMonitor هو مسار أتمتة موجّه لأنظمة Linux لمعالجة محتوى الفيديو والنشر متعدد المنصات. يراقب النظام ملفات الفيديو الجديدة، ثم يعالجها عبر خطوات تشمل إصلاح التوافق، والتحسين الاختياري، والمعالجة المرتبطة بالتفريغ/الترجمة عبر واجهة API، ثم نشر النتائج على المنصات المُعدّة.

بيئة التشغيل تُدار عبر سكربتات Shell (`tmux`, `inotifywait`, `rsync`, `flock`) مع عملاء معالجة Python وتتبع الحالة عبر ملفات CSV/نصية.

## الميزات الرئيسية

| الإمكانية | التفاصيل |
|---|---|
| اكتشاف الملفات تلقائيًا | يراقب الأدلة لاكتشاف محتوى فيديو جديد |
| إدارة طابور المعالجة | يتعامل مع الفيديوهات بشكل متسلسل ومضبوط |
| معالجة الفيديو | يفحص المدة والصيغ ويُحضّر الفيديوهات |
| نشر متعدد المنصات | يدعم XiaoHongShu وBilibili وDouyin وShiPinHao وYouTube |
| نظام تخزين مؤقت | يحسن المعالجة عبر تخزين النتائج مؤقتًا |
| مزامنة الملفات | يدير نقل الملفات بين الأنظمة |
| إعداد مركزي | جميع المسارات والإعدادات في ملف إعداد واحد |
| تثبيت سهل | سكربت واحد لإعداد النظام بالكامل |
| إصلاح توافق الفيديو | يستخدم فحوصات FFmpeg مع بديل اختياري HandBrakeCLI |
| تشغيل قائم على الخدمات | جلسات `tmux` + خدمة `systemd` اختيارية |

## بنية المستودع

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

## مكونات النظام

### المعالجة الأساسية

| المكوّن | الدور |
|---|---|
| `autopub.py` | محرك المعالجة الرئيسي الذي يدير تنسيق الرفع/المعالجة/النشر |
| `process_video.py` | عميل معالجة الفيديو للرفع والمعالجة والتعامل مع النتائج |
| `video_utils.py` / `handbrake.py` | فحوصات وإصلاحات التوافق قبل الرفع |

### إدارة الطابور

| المكوّن | الدور |
|---|---|
| `process_queue.sh` | مستهلك الطابور مع قفل `flock` وحلقة إعادة محاولة |
| `queue_file_utility.sh` | أداة تغذية يدوية للطابور عبر المسار أو نمط اسم الملف |

### إدارة الخدمات

| المكوّن | الدور |
|---|---|
| `autopub_monitor_tmux_session.sh` | بدء/إيقاف خدمات tmux متعددة الأجزاء |
| `autopub.sh` | غلاف Conda/تهيئة لتشغيل `autopub.py` |
| `autopub_sync.sh` | مزامنة الملفات من مسار Nutstore/Jianguoyun |
| `monitor_autopublish.sh` | مراقب `inotify` للملفات الجديدة وإضافتها للطابور |

### الأدوات المساعدة

| المكوّن | الدور |
|---|---|
| `window_info_utility.py` | أداة النافذة النشطة باستخدام `xdotool` (اختياري) |
| `autopub.config` | ملف الإعداد المركزي |
| `install_autopub_monitor.sh` | مساعد التثبيت + إعداد systemd |

## المتطلبات الأساسية

| المتطلب | ملاحظات |
|---|---|
| بيئة Linux مع bash | الهدف الأساسي للتشغيل |
| Python 3.8+ | المثبّت ينشئ حاليًا بيئة conda بإصدار Python 3.8 |
| Miniconda في `${HOME}/miniconda3` | المسار الافتراضي المتوقع في السكربتات |
| `ffmpeg` / `ffprobe` | مطلوب للتحقق من الفيديو/المعالجة |
| `tmux` | تنسيق الخدمات |
| `inotify-tools` | مراقبة أحداث الملفات (`inotifywait`) |
| `rsync` | المزامنة بين الأدلة/الأنظمة |
| `python3-pip` | تثبيت حزم Python |
| اختياري: `HandBrakeCLI` | موصى به لإصلاح الفيديوهات الإشكالية |
| اختياري: `xdotool` | مطلوب لـ `window_info_utility.py` |

حزم Python المستخدمة في سكربتات المستودع تتضمن:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## التثبيت

### 🚀 التثبيت التلقائي (عبر سكربت)

من جذر المستودع:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

يقوم المثبّت بما يلي:

- يثبت تبعيات apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- ينشئ/يستخدم بيئة conda باسم `autopub-video`
- يثبت حزم Python (`requests`, `requests_toolbelt`, `selenium`)
- ينشئ أدلة التشغيل وملفات الحالة
- يثبت ويفعّل `autopub-monitor.service`

### 🧩 تمكين/بدء الخدمة (إذا لم تكن مفعّلة مسبقًا عبر المثبّت)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ إعداد يدوي

1. راجع وعدّل `autopub_monitor/autopub.config` بحسب بيئتك.
2. أنشئ البيئة وفعّلها:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. اجعل السكربتات قابلة للتنفيذ:

```bash
chmod +x autopub_monitor/*.sh
```

## الإعداد

ملف الإعداد الرئيسي: `autopub_monitor/autopub.config`

الإعدادات المهمة تشمل:

- أدلة البيانات: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- أدلة مصدر المزامنة: `JIANGUOYUN_*`
- ملفات الحالة: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- ملفات القفل: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- إعدادات API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- إعدادات Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

ملاحظات:

- الإعداد الافتراضي يفضّل حاليًا وضع app API (`USE_APP_API="true"`) ويُنشئ عناوين النقاط الطرفية من `APP_API_BASE_URL`.
- ما تزال النقاط الطرفية القديمة موجودة في الإعداد للرجوع إليها.

## الاستخدام

### ▶️ بدء الخدمات

من جذر المستودع:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

يؤدي هذا إلى تشغيل:

- خدمة مزامنة الملفات
- خدمة مراقبة الدليل
- خدمة معالجة الطابور
- جزء أوامر يدوي
- جلسة rsync للتفريغ (`am-transcription-sync`)

### ⏹️ إيقاف الخدمات

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 إدارة الطابور يدويًا

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 معالجة فيديو يدويًا

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

## خيارات سطر الأوامر (`autopub.py`)

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

ملاحظة سلوكية:

- في وضع app API (`USE_APP_API=true`)، يكون النشر معطّلًا افتراضيًا ما لم يتم تمرير أعلام النشر صراحةً.

## معمارية المعالجة

1. **اكتشاف الملفات**: يراقب `monitor_autopublish.sh` أحداث `close_write`/`moved_to`.
2. **الطابور**: تُضاف الملفات الصالحة إلى `queue_list.txt` باستخدام `flock`.
3. **المعالجة**: يستهلك `process_queue.sh` مدخلات الطابور ويستدعي `autopub.sh`.
4. **الرفع/المعالجة/النشر**: يستدعي `autopub.py` و`process_video.py` نقاط API الطرفية المُعدّة.
5. **التتبع**: تُكتب الملفات المعالجة إلى `processed.csv`، والملفات المكتشفة إلى `videos_db.csv`.

## أمثلة عملية

### المثال 1: وضع الخدمة الكامل end-to-end 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

بعد ذلك، انقل أو زامن الفيديوهات إلى دليل المصدر المُعدّ لديك وراقب السجلات ضمن أجزاء tmux.

### المثال 2: فرض إعادة التشغيل للملفات المطابقة 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### المثال 3: اختبار محلي بدون نشر 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## ملاحظات التطوير

- لا يوجد ملف تبعيات مثبتة الإصدارات (`requirements.txt` / `pyproject.toml`) في جذر المستودع.
- بيئة التشغيل مرتبطة بقوة بأدوات Linux shell وأنماط المسارات المحلية.
- السكربتات الحالية تستورد إعدادات shell ديناميكيًا (`autopub.config`)؛ حافظ على تعبيرات المتغيرات المتوافقة مع shell.
- دلالات الطابور والقفل تعتمد على `flock`؛ تجنّب التعديلات التي تضعف التحديثات الذرية للطابور.
- تفاصيل عقد API مستنتجة من كود العميل؛ تنفيذ الخادم خارج هذا المستودع.
- دليل `i18n/` موجود لكن مستندات اللغات لم تُملأ بعد في دورة المسودة هذه.

## توافق الأسماء القديمة (محفوظ)

استخدمت الوثائق السابقة تسميات مكوّنات مُعاد تسميتها. أسماء الملفات الحالية في المستودع تبقى كما هو موضح أدناه.

| تسمية الوثائق السابقة | ملف المستودع الحالي |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

للتسهيل، إذا نفّذت `cd autopub_monitor`، فإن صيغ الأوامر ذات النمط القديم من الوثائق الأقدم تقابل:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## استكشاف الأخطاء وإصلاحها

| العَرَض | ما يجب التحقق منه |
|---|---|
| `Miniconda not found at ~/miniconda3` | ثبّت Miniconda أو حدّث `CONDA_DIR` في `autopub.config`. |
| `inotifywait: command not found` | ثبّت `inotify-tools`. |
| أخطاء `ffprobe`/`ffmpeg` | ثبّت `ffmpeg` وتحقق من سلامة ملف الإدخال. |
| الفيديوهات لا تُضاف للطابور بشكل متكرر | افحص `checked_list.txt` و`temp_queue.txt` وسجلات `monitor_autopublish.sh`. |
| تعلّق الطابور أو مخاوف تعارض | افحص `queue.lock` و`queue_list.txt` والعمليات النشطة التي تستخدم `flock`. |
| أخطاء API في الرفع/المعالجة/النشر | تحقّق من `APP_API_BASE_URL` ومسارات النقاط الطرفية في `autopub.config`. |
| خدمة tmux لا تبدأ | تأكد أن `tmux has-session` يعمل وأن صلاحيات التنفيذ مضبوطة للسكربت. |

## خارطة الطريق

- إضافة إدارة تبعيات مثبتة الإصدارات (`requirements.txt` أو `pyproject.toml`).
- إضافة فحوصات CI لتدقيق shell/Python واختبارات تكامل أساسية.
- إضافة وثائق لعقد API وافتراضات النشر.
- توسيع `i18n/` بملفات README مترجمة ومصانة.
- تحسين قابلية الرصد (سجلات مهيكلة وفحوصات صحة).

## المساهمة

المساهمات مرحّب بها.

سير عمل موصى به:

1. اعمل Fork وأنشئ فرع ميزة.
2. اجعل التعديلات صغيرة ومركزة (تحديثات السكربتات + الوثائق معًا).
3. تحقّق من العمل على بيئة Linux مع أدوات النظام المطلوبة.
4. أرسل Pull Request مع ملاحظات إعادة إنتاج/اختبار واضحة.

إذا تغيّر السلوك، حدّث كِلا الملفين:

- `README.md`
- `PROJECT_STRUCTURE.md` و/أو `autopub_monitor/README.md`

## الدعم والرعاية

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Website: https://lazying.art
- Community chat: https://chat.lazying.art
- Ideas hub: https://onlyideas.art

(من `.github/FUNDING.yml`)

## الشكر والتقدير

- بُني المشروع حول أدوات Linux الأصلية (`tmux`, `inotify`, `rsync`, `ffmpeg`) لأتمتة موثوقة وطويلة التشغيل.
- الشكر للمساهمين والمستخدمين الداعمين للتحسينات المستمرة.

## الترخيص

Apache License 2.0 - راجع [LICENSE](../LICENSE) للتفاصيل.
