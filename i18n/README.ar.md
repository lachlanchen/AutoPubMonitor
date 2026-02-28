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

> نظام آلي لمراقبة ومعالجة ونشر محتوى الفيديو على منصات متعددة.

| What to expect | Detail |
|---|---|
| نموذج التشغيل | أتمتة لنظام لينكس باستخدام `tmux`، و`systemd` اختياريًا، وقفل الطوابير |
| تصميم الطابور | مراقب الملفات → طابور → حلقة العامل، مع تتبع حالة دائم |
| قابلية التوسع | تنسيق عبر Shell + عملاء نشر Python لمنافذ المنصات |
| نقاط الدخول الأساسية | `autopub_monitor_tmux_session.sh`، `autopub.sh`، `autopub.py` |

---

## 🧭 خريطة التوثيق

| Section | Why it matters |
|---|---|
| [لمحة المشروع](#project-at-a-glance) | فهم سريع لنموذج التشغيل والأهداف |
| [التثبيت](#installation) | الانتقال من الاستنساخ إلى تشغيل الخدمة |
| [الإعداد](#configuration) | الإحاطة بجميع مفاتيح التهيئة المهمة |
| [الاستخدام](#usage) | تشغيل الخدمات/إيقافها وإدارة الطابور وسير المعالجة |
| [مكونات النظام](#system-components) | تحديد مسؤوليات سكربتات Shell وPython |
| [استكشاف الأخطاء](#troubleshooting) | حل مشاكل الإقلاع والطابور بسرعة |
| [خارطة الطريق](#roadmap) | متابعة خطط التطوير القريب |
| [المساهمة](#contributing) | فهم طريقة المساهمة الآمنة |

## 🧭 نظرة سريعة

| الهدف | الأمر | الملاحظات |
|---|---|---|
| تشغيل خط المراقبة | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | يبدأ مراقب الملفات + الطابور + المزامنة + لوح الأوامر اليدوي |
| إيقاف كل الخدمات | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | إيقاف نظيف مع تنظيف الألواح |
| إدراج بالصيغة | `./autopub_monitor/queue_file_utility.sh "pattern"` | يضيف الملفات المطابقة إلى طابور المعالجة |
| معالجة ملف واحد | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | يستخدم إعدادات النشر والمعالجة الافتراضية |

<a id="project-at-a-glance"></a>
## 🎯 لمحة المشروع

| البند | التفاصيل |
|---|---|
| هدف التشغيل | لينكس، مع تنسيق `tmux` و`systemd` اختياريًا |
| نموذج الطابور | مراقبة الملفات → طابور → سكربتات العامل → خط النشر |
| نقاط الدخول الأساسية | `autopub_monitor_tmux_session.sh`، `autopub.py`، `autopub.config` |
| تتبع الحالة | `queue_list.txt`، `queue.lock`، `processed.csv`، `videos_db.csv` |

## 🔎 النظرة العامة

AutoPubMonitor هو خط أتمتة موجّه إلى لينكس لمعالجة فيديوهات المحتوى والنشر متعدد المنصات. يراقب النظام ملفات الفيديو الجديدة، ويعالجها عبر مراحل تشمل إصلاح التوافق، والتحسين الاختياري، ومعالجة مرتبطة بالتفريغ النصي/الترجمة عبر API، ثم ينشر النتائج على المنصات المكوَّنة.

التشغيل مبني على Shell (`tmux`، `inotifywait`، `rsync`، `flock`) مع عملاء معالجة مكتوبة بـ Python وتتبّع للحالة عبر ملفات CSV/نصية.

## ⚡ الميزات الرئيسية

| القدرة | التفاصيل |
|---|---|
| كشف الملفات تلقائيًا | يراقب الأدلة لاكتشاف فيديوهات جديدة |
| إدارة طوابير المعالجة | يعالج الفيديوهات بطريقة متسلسلة ومنظمة |
| معالجة الفيديو | يفحص الطول والصيغ ويهيئ الفيديوهات |
| نشر متعدد المنصات | يدعم XiaoHongShu وBilibili وDouyin وShiPinHao وYouTube |
| نظام التخزين المؤقت | يحسن الأداء عبر إعادة استخدام النتائج المخزنة |
| مزامنة الملفات | يتعامل مع نقل الملفات بين الأنظمة |
| إعداد مركزي | جميع المسارات والإعدادات في ملف تكوين واحد |
| التثبيت السهل | سكربت واحد لإعداد النظام بالكامل |
| إصلاح توافق الفيديو | يستخدم فحوص FFmpeg مع HandBrakeCLI كخيار احتياطي |
| تشغيل موجه للخدمة | جلسات `tmux` + خدمة `systemd` اختيارية |
| وثائق متعددة اللغات | روابط لغات جذرية وملفات ترجمة في `i18n/` |

## 🗂️ بنية المستودع

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
## مكونات النظام

### المعالجة الأساسية

| المكون | الدور |
|---|---|
| `autopub.py` | محرك المعالجة الرئيسي الذي ينسق تحميل الملفات والمعالجة والنشر |
| `process_video.py` | عميل معالجة الفيديو للتحميل والمعالجة والتعامل مع النتائج |
| `video_utils.py` / `handbrake.py` | فحوصات التوافق وإصلاحات ما قبل التحميل |

### إدارة الطابور

| المكون | الدور |
|---|---|
| `process_queue.sh` | مستهلك طابور بقفل `flock` وحلقة إعادة المحاولة |
| `queue_file_utility.sh` | إدخال يدوي للطابور عبر المسار أو نمط اسم الملف |

### إدارة الخدمة

| المكون | الدور |
|---|---|
| `autopub_monitor_tmux_session.sh` | تشغيل وإيقاف خدمات متعددة الألواح في `tmux` |
| `autopub.sh` | غلاف Conda/تهيئة للتعامل مع `autopub.py` |
| `autopub_sync.sh` | مزامنة الملفات من أدلة المصدر المتزامنة أو البعيدة |
| `monitor_autopublish.sh` | مراقب `inotify` لملفات جديدة وإضافتها للطابور |

### الأدوات المساعدة

| المكون | الدور |
|---|---|
| `window_info_utility.py` | أداة النافذة النشطة باستخدام `xdotool` (اختياري) |
| `autopub.config` | ملف الإعدادات الموحد |
| `install_autopub_monitor.sh` | مساعد التثبيت وإعداد `systemd` |

<a id="prerequisites"></a>
## المتطلبات الأساسية

| المتطلب | الملاحظات |
|---|---|
| بيئة لينكس مع Bash | الهدف الأساسي للتشغيل |
| Python 3.8+ | مثبتات الإعداد تنشئ بيئة Conda `Python 3.8` |
| Miniconda في `${HOME}/miniconda3` | المسار المتوقع افتراضيًا في السكربتات |
| `ffmpeg` / `ffprobe` | مطلوب للتحقق من الفيديو والمعالجة |
| `tmux` | تنسيق الخدمات |
| `inotify-tools` | مراقبة أحداث الملفات (`inotifywait`) |
| `rsync` | المزامنة بين الأدلة/الأنظمة |
| `python3-pip` | تثبيت حزم Python |
| اختياري: `HandBrakeCLI` | موصى به لإصلاح مقاطع الفيديو التي تعاني مشاكل توافق |
| اختياري: `xdotool` | مطلوب لـ `window_info_utility.py` |

Python packages used in repo scripts include:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

<a id="installation"></a>
## التثبيت

### 🚀 التثبيت التلقائي (سطر الأوامر)

من جذر المستودع:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

يؤدي المثبّت إلى:

- تثبيت اعتمادات `apt` (`tmux`، `inotify-tools`، `ffmpeg`، `python3-pip`)
- إنشاء/استخدام بيئة Conda باسم `autopub-video`
- تثبيت حزم Python (`requests`، `requests_toolbelt`، `selenium`)
- إنشاء أدلة التشغيل وملفات الحالة
- تثبيت وتفعيل خدمة `autopub-monitor.service`

### 🧩 تفعيل/تشغيل الخدمة (إذا لم يقم المثبّت بذلك)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ الإعداد اليدوي

1. راجع وعدّل `autopub_monitor/autopub.config` بما يناسب بيئتك.
2. أنشئ وفعّل البيئة:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. اجعل السكربتات قابلة للتنفيذ:

```bash
chmod +x autopub_monitor/*.sh
```

> افتراض: ملفات حالة التشغيل في المستودع (مثل `queue.lock` و`temp_queue.txt` و`checked_list.txt`) يجب أن تكون موجودة مسبقًا أو تُنشأ في مسار الإقلاع/التثبيت.

<a id="configuration"></a>
## الإعداد

ملف الإعداد الأساسي: `autopub_monitor/autopub.config`

الإعدادات المهمة تشمل:

- أدلة البيانات: `AUTOPUBLISH_DIR`، `TRANSCRIPTION_DIR`، `PREPROCESSED_VIDEOS_DIR`
- أدلة المزامنة: `JIANGUOYUN_*`
- ملفات الحالة: `QUEUE_LIST`، `TEMP_QUEUE`، `CHECKED_LIST`، `VIDEOS_DB_PATH`، `PROCESSED_PATH`
- ملفات القفل: `QUEUE_LOCK`، `AUTOPUB_LOCK`
- إعدادات API: `USE_APP_API`، `APP_API_BASE_URL`، `UPLOAD_URL`، `PROCESS_URL`، `PUBLISH_URL`
- إعدادات Conda: `CONDA_ENV`، `CONDA_DIR`، `CONDA_ACTIVATE`

ملاحظات:

- التكوين الحالي مفضلًا للوضع عبر API التطبيق (`USE_APP_API="true"`) ويبني عناوين النهاية من `APP_API_BASE_URL`.
- لا تزال نهايات API القديمة موجودة في ملف الإعداد كمرجع.
- يمكن تغيير أسماء ملفات الطابور والقفل بمخاطر منخفضة بشرط أن جميع السكربتات تعتمد نفس مفاتيح التكوين.

<a id="usage"></a>
## الاستخدام

### ▶️ بدء الخدمات

من جذر المستودع:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

هذا الأمر يبدأ:

- خدمة المزامنة
- خدمة مراقبة الأدلة
- خدمة معالجة الطابور
- لوحة الأوامر اليدوية
- جلسة `rsync` للتفريغ النصي (`am-transcription-sync`)

### ⏹️ إيقاف الخدمات

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 إدارة الطابور يدويًا

```bash
# الإضافة عبر مطابقة نمط
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# الإضافة عبر مسار كامل
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# الإضافة بتأكيد تلقائي (بدون مطالبة اختيار)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 المعالجة اليدوية للفيديو

```bash
# معالجة ملف محدد عبر إعدادات الغلاف الافتراضية
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# CLI مباشر مع أهداف نشر محددة
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# خيارات التخزين المؤقت + عرض التقدّم
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# رفع/معالجة دون نشر
python autopub_monitor/autopub.py --no-pub --path "/path/to/video.mp4"
```

## خيارات CLI (`autopub.py`)

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

- في وضع App API (`USE_APP_API=true`)، يكون النشر معطّلًا افتراضيًا حتى تُمرّر أعلام النشر صراحة.

## 🎛️ لوحة الأوامر

| المجال | أمثلة |
|---|---|
| التحكم بالخدمات | `autopub_monitor_tmux_session.sh start/stop` |
| عمليات الطابور | `queue_file_utility.sh`، `process_queue.sh` |
| مزامنة/معالجة الملفات | `autopub_sync.sh`، `autopub.sh`، `monitor_autopublish.sh` |
| مسار التنفيذ في Python | `autopub.py`، `process_video.py`، `video_utils.py` |

## هندسة المعالجة

1. **كشف الملفات**: يراقب `monitor_autopublish.sh` أحداث `close_write`/`moved_to`.
2. **إدراج الطابور**: تُضاف الملفات الصالحة إلى `queue_list.txt` باستخدام `flock`.
3. **المعالجة**: يستهلك `process_queue.sh` عناصر الطابور ويستدعي `autopub.sh`.
4. **الرفع/المعالجة/النشر**: تتواصل `autopub.py` و`process_video.py` مع نقاط نهاية API المكونة.
5. **التتبع**: تُكتب الملفات المعالجة في `processed.csv`، والمكتشفة في `videos_db.csv`.

## أمثلة عملية

### المثال 1: تشغيل كامل بنمط الخدمة الخلفية (Daemon) 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

ثم ضع ملفات الفيديو في دليل المصدر المكون أو قم بمزامنتها، وتابع السجلات من ألواح `tmux`.

### المثال 2: إعادة تشغيل الملفات المطابقة بالإجبار 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### المثال 3: اختبار محلي بدون نشر 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## 🧠 ملاحظات التطوير

- لا يوجد ملف تثبيت نسخات (requirements manifest) في جذر المستودع (`requirements.txt` / `pyproject.toml`).
- زمن التشغيل مرتبط بقوة بأدوات سطر أوامر لينكس واتفاقيات المسارات المحلية.
- السكربتات تحمل إعدادات `autopub.config` في وقت التشغيل؛ احتفظ بتعبيرات متغيرات متوافقة مع Shell.
- تعتمد دلالات الطابور والقفل على `flock`؛ تجنب تغييرات تضعف تحديثات الطابور الذرية.
- تفاصيل عقد API تُستخلص من كود العميل؛ تنفيذ الخادم خارجي عن هذا المستودع.
- دليل `i18n/` موجود لكن ترجمات التوثيق ليست محدثة بالكامل خلال هذه الدورة.
- ملفات آثار التشغيل (`queue_list.txt`، `temp_queue.txt` وغيرها) تُنشأ عادة أثناء التشغيل وقد تختلف حسب البيئة.

<a id="contributing"></a>
## 🧱 التوافق مع الأسماء القديمة (محفوظ)

توثيق سابق استخدم أسماء مكونات معاد تسميتها. أسماء الملفات الحالية بالمستودع كما هو موضح:

| اسم سابق في التوثيق | ملف المستودع الحالي |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

للتوضيح، إذا نفذت `cd autopub_monitor`، فهذه الأوامر من التوثيق القديم تقابل:

```bash
# أوامر التوثيق القديم (مكافئات حسب المسار الحالي)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

<a id="troubleshooting"></a>
## استكشاف الأخطاء وإصلاحها

| العرض | ما يجب فحصه |
|---|---|
| `Miniconda not found at ~/miniconda3` | ثبّت Miniconda أو حدّث `CONDA_DIR` في `autopub.config`. |
| `inotifywait: command not found` | ثبّت `inotify-tools`. |
| فشل `ffprobe`/`ffmpeg` | ثبّت `ffmpeg` وتأكد من سلامة ملف الإدخال. |
| تكرار عدم إدخال الفيديوهات إلى الطابور | افحص `checked_list.txt` و`temp_queue.txt` وسجلات المراقبة في `monitor_autopublish.sh`. |
| الطابور متوقف أو مشاكل تزامن | افحص `queue.lock` و`queue_list.txt` والعمليات النشطة باستخدام `flock`. |
| أخطاء رفع/معالجة/نشر API | تأكد من `APP_API_BASE_URL` ومسارات النهاية في `autopub.config`. |
| خدمة tmux لا تبدأ | تأكد أن `tmux has-session` تعمل وأن صلاحيات تنفيذ السكربتات صحيحة. |

<a id="roadmap"></a>
## 🗺️ خارطة الطريق

- إضافة إدارة اعتمادات مثبتة (`requirements.txt` أو `pyproject.toml`).
- إضافة فحوص CI لفحص shell/Python وواجهات تكامل أساسية.
- توسيع توثيق عقد API وافتراضات النشر.
- توسيع `i18n/` بملفات README مترجمة ومُصانة.
- تحسين القابلية للملاحظة (سجلات بنيوية وفحوص صحة).

## 🤝 المساهمة

المساهمات مرحّب بها.

سير العمل الموصى به:

1. إنشاء fork وفرع ميّزة.
2. إبقاء التغييرات صغيرة ومركّزة (السكربتات + التوثيق معًا).
3. التحقق على بيئة Linux مع الأدوات النظامية المطلوبة.
4. تقديم pull request مع ملاحظات إعادة إنتاج واختبارات واضحة.

إذا تغيّر السلوك، حدّث:

- `README.md`
- `PROJECT_STRUCTURE.md` و/أو `autopub_monitor/README.md`

## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 📬 جهة الاتصال

للاستفسارات وتقارير الأعطال وطلبات الميزات:

- افتح issue على [github.com/lachlanchen/AutoPubMonitor/issues](https://github.com/lachlanchen/AutoPubMonitor/issues)

## 🙌 شكر وتقدير

- مبني على أدوات لينكس أصلية (`tmux`، `inotify`، `rsync`، `ffmpeg`) لأتمتة طويلة الأمد موثوقة.
- شكر للمساهمين والمستخدمين الذين يساهمون في تحسينه باستمرار.

## 📄 الترخيص

Apache License 2.0 - راجع [LICENSE](LICENSE) للمزيد من التفاصيل.
