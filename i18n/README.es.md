[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)



<p align="center">
  <img src="https://raw.githubusercontent.com/lachlanchen/lachlanchen/main/logos/banner.png" alt="Banner de LazyingArt" />
</p>

# AutoPubMonitor

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](../LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-lightgrey)](#requisitos)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](#requisitos)
[![Service](https://img.shields.io/badge/runtime-tmux%20%2B%20systemd-2ea44f)](#uso)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ea4aaa)](https://github.com/sponsors/lachlanchen)

Un sistema automatizado para monitorear, procesar y publicar contenido de video en múltiples plataformas.

## Descripción General

AutoPubMonitor es una canalización de automatización orientada a Linux para procesamiento de contenido de video y publicación multiplataforma. El sistema detecta archivos de video nuevos, los procesa mediante pasos que incluyen reparación de compatibilidad, mejora opcional, procesamiento relacionado con transcripción/traducción vía API, y publica los resultados en las plataformas configuradas.

La ejecución está orquestada por shell (`tmux`, `inotifywait`, `rsync`, `flock`) con clientes de procesamiento en Python y seguimiento de estado en archivos CSV/texto.

## Características Principales

| Capacidad | Detalles |
|---|---|
| Detección automática de archivos | Monitorea directorios para contenido de video nuevo |
| Gestión de cola de procesamiento | Maneja videos de forma controlada y secuencial |
| Procesamiento de video | Verifica duración, formatos y prepara videos |
| Publicación multiplataforma | Soporta XiaoHongShu, Bilibili, Douyin, ShiPinHao y YouTube |
| Sistema de caché | Optimiza el procesamiento almacenando resultados |
| Sincronización de archivos | Gestiona movimiento de archivos entre sistemas |
| Configuración centralizada | Todas las rutas y ajustes en un único archivo de configuración |
| Instalación sencilla | Un solo script configura todo el sistema |
| Reparación de compatibilidad de video | Usa verificaciones con FFmpeg y fallback opcional con HandBrakeCLI |
| Operación orientada a servicios | Sesiones de `tmux` + servicio `systemd` opcional |

## Estructura del Repositorio

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

## Componentes del Sistema

### Procesamiento Central

| Componente | Rol |
|---|---|
| `autopub.py` | Motor principal de procesamiento que maneja la orquestación de carga/proceso/publicación |
| `process_video.py` | Cliente de procesamiento de video para carga, procesamiento y manejo de resultados |
| `video_utils.py` / `handbrake.py` | Verificaciones y reparaciones de compatibilidad antes de la carga |

### Gestión de Cola

| Componente | Rol |
|---|---|
| `process_queue.sh` | Consumidor de cola con bloqueo `flock` y bucle de reintentos |
| `queue_file_utility.sh` | Alimentador manual de cola por ruta o patrón de nombre de archivo |

### Gestión de Servicios

| Componente | Rol |
|---|---|
| `autopub_monitor_tmux_session.sh` | Inicia/detiene servicios `tmux` en múltiples paneles |
| `autopub.sh` | Wrapper de Conda/bootstrap para `autopub.py` |
| `autopub_sync.sh` | Sincronización de archivos desde ruta de Nutstore/Jianguoyun |
| `monitor_autopublish.sh` | Monitor `inotify` para archivos nuevos y encolado |

### Utilidades

| Componente | Rol |
|---|---|
| `window_info_utility.py` | Utilidad de ventana activa usando `xdotool` (opcional) |
| `autopub.config` | Archivo de configuración central |
| `install_autopub_monitor.sh` | Instalación + asistente de configuración de systemd |

## Requisitos

| Requisito | Notas |
|---|---|
| Entorno Linux con bash | Objetivo principal de ejecución |
| Python 3.8+ | El instalador crea actualmente un entorno conda Python 3.8 |
| Miniconda en `${HOME}/miniconda3` | Ruta predeterminada esperada en scripts |
| `ffmpeg` / `ffprobe` | Requerido para validación/procesamiento de video |
| `tmux` | Orquestación de servicios |
| `inotify-tools` | Monitoreo de eventos de archivos (`inotifywait`) |
| `rsync` | Sincronización entre directorios/sistemas |
| `python3-pip` | Instalación de paquetes Python |
| Opcional: `HandBrakeCLI` | Recomendado para reparar videos problemáticos |
| Opcional: `xdotool` | Necesario para `window_info_utility.py` |

Los paquetes de Python usados en los scripts del repositorio incluyen:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Instalación

### 🚀 Instalación Automática (con script)

Desde la raíz del repositorio:

```bash
cd autopub_monitor
chmod +x install_autopub_monitor.sh
./install_autopub_monitor.sh
```

El instalador:

- Instala dependencias apt (`tmux`, `inotify-tools`, `ffmpeg`, `python3-pip`)
- Crea/usa el entorno conda `autopub-video`
- Instala paquetes de Python (`requests`, `requests_toolbelt`, `selenium`)
- Crea directorios de ejecución y archivos de estado
- Instala y habilita `autopub-monitor.service`

### 🧩 Habilitar/Iniciar Servicio (si el instalador aún no lo habilitó)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Configuración Manual

1. Revisa y modifica `autopub_monitor/autopub.config` para tu entorno.
2. Crea y activa el entorno:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Haz ejecutables los scripts:

```bash
chmod +x autopub_monitor/*.sh
```

## Configuración

Archivo de configuración principal: `autopub_monitor/autopub.config`

Los ajustes importantes incluyen:

- Directorios de datos: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Directorios fuente de sincronización: `JIANGUOYUN_*`
- Archivos de estado: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Archivos de bloqueo: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Ajustes de API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Ajustes de Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Notas:

- La configuración predeterminada actualmente prioriza el modo de app API (`USE_APP_API="true"`) y construye URLs de endpoint desde `APP_API_BASE_URL`.
- Los endpoints heredados siguen presentes en la configuración como referencia.

## Uso

### ▶️ Iniciar Servicios

Desde la raíz del repositorio:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Esto inicia:

- Servicio de sincronización de archivos
- Servicio de monitoreo de directorio
- Servicio de procesamiento de cola
- Panel de comandos manuales
- Sesión rsync de transcripción (`am-transcription-sync`)

### ⏹️ Detener Servicios

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Gestión Manual de Cola

```bash
# Add by pattern match
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Add by full path
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Add with auto-confirmation (no selection prompt)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Procesamiento Manual de Video

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

## Opciones CLI (`autopub.py`)

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

Nota de comportamiento:

- En modo app API (`USE_APP_API=true`), la publicación está desactivada por defecto a menos que se pasen explícitamente flags de publicación.

## Arquitectura de Procesamiento

1. **Detección de Archivos**: `monitor_autopublish.sh` vigila eventos `close_write`/`moved_to`.
2. **Cola**: Los archivos válidos se agregan a `queue_list.txt` usando `flock`.
3. **Procesamiento**: `process_queue.sh` consume entradas de cola y llama a `autopub.sh`.
4. **Carga/Proceso/Publicación**: `autopub.py` y `process_video.py` llaman a los endpoints API configurados.
5. **Seguimiento**: Los archivos procesados se escriben en `processed.csv` y los descubiertos en `videos_db.csv`.

## Ejemplos Prácticos

### Example 1: End-to-end daemon mode 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Luego coloca o sincroniza videos en tu directorio fuente configurado y monitorea logs en paneles tmux.

### Example 2: Force re-run matching files 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Example 3: Local test without publish 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Notas de Desarrollo

- No hay un manifiesto de dependencias fijadas (`requirements.txt` / `pyproject.toml`) en la raíz del repositorio.
- La ejecución está fuertemente ligada a herramientas shell de Linux y convenciones de rutas locales.
- Los scripts actuales cargan configuración shell dinámicamente (`autopub.config`); mantén expresiones de variables compatibles con shell.
- La semántica de cola y bloqueo depende de `flock`; evita cambios que debiliten actualizaciones atómicas de la cola.
- Los detalles del contrato API se infieren desde el código cliente; la implementación del servidor es externa a este repositorio.
- El directorio `i18n/` existe, pero la documentación de idiomas puede no estar completamente poblada en este ciclo de borrador.

## Compatibilidad con Nombres Heredados (Preservado)

La documentación anterior usaba etiquetas de componentes renombradas. Los nombres de archivo actuales del repositorio se mantienen como se lista abajo.

| Etiqueta en docs antiguas | Archivo actual del repositorio |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Para mayor comodidad, si haces `cd autopub_monitor`, estas formas de comandos estilo documentación antigua se mapean a:

```bash
# Older docs style (equivalent location-dependent commands)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Solución de Problemas

| Síntoma | Qué revisar |
|---|---|
| `Miniconda not found at ~/miniconda3` | Instala Miniconda o actualiza `CONDA_DIR` en `autopub.config`. |
| `inotifywait: command not found` | Instala `inotify-tools`. |
| Fallos de `ffprobe`/`ffmpeg` | Instala `ffmpeg`; valida la integridad del archivo de entrada. |
| Videos repetidamente no encolados | Revisa `checked_list.txt`, `temp_queue.txt` y los logs de `monitor_autopublish.sh`. |
| Cola atascada o preocupaciones de carrera | Inspecciona `queue.lock`, `queue_list.txt` y procesos activos usando `flock`. |
| Errores de upload/process/publish API | Verifica `APP_API_BASE_URL` y rutas de endpoints en `autopub.config`. |
| Servicio tmux no inicia | Confirma que `tmux has-session` funcione y que los scripts tengan permisos de ejecución. |

## Hoja de Ruta

- Añadir gestión de dependencias fijadas (`requirements.txt` o `pyproject.toml`).
- Añadir verificaciones CI para linting shell/Python y pruebas básicas de integración.
- Añadir documentación para el contrato API y supuestos de despliegue.
- Ampliar `i18n/` con READMEs traducidos y mantenidos.
- Mejorar observabilidad (logs estructurados y health checks).

## Contribuir

Las contribuciones son bienvenidas.

Flujo de trabajo recomendado:

1. Haz un fork y crea una rama de funcionalidad.
2. Mantén los cambios pequeños y enfocados (script + actualización de docs juntos).
3. Valida en un entorno Linux con las herramientas de sistema requeridas.
4. Envía un pull request con notas claras de reproducción/pruebas.

Si cambia el comportamiento, actualiza ambos:

- `README.md`
- `PROJECT_STRUCTURE.md` y/o `autopub_monitor/README.md`

## Soporte y Patrocinio

- GitHub Sponsors: https://github.com/sponsors/lachlanchen
- Sitio web: https://lazying.art
- Chat de la comunidad: https://chat.lazying.art
- Hub de ideas: https://onlyideas.art

(De `.github/FUNDING.yml`)

## Agradecimientos

- Construido sobre herramientas nativas de Linux (`tmux`, `inotify`, `rsync`, `ffmpeg`) para una automatización confiable de larga duración.
- Gracias a colaboradores y usuarios por apoyar las mejoras continuas.

## Licencia

Apache License 2.0 - Consulta [LICENSE](../LICENSE) para más detalles.
