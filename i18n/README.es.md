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

> Sistema automatizado para supervisar, procesar y publicar contenido de vídeo en múltiples plataformas.

## 🧭 Mapa de documentación

| Sección | Por qué importa |
|---|---|
| [Resumen del proyecto](#project-at-a-glance) | Entender rápidamente el modelo de ejecución y objetivos |
| [Instalación](#installation) | Pasar de clonar el repositorio a ejecutar el servicio |
| [Configuración](#configuration) | Conocer cada opción relevante de los scripts |
| [Uso](#usage) | Iniciar, detener, encolar y procesar flujos de trabajo |
| [Componentes del sistema](#system-components) | Distinguir responsabilidades entre shell y Python |
| [Resolución de problemas](#troubleshooting) | Resolver problemas de arranque y encolado rápidamente |
| [Hoja de ruta](#roadmap) | Seguir planes cercanos de plataforma y herramientas |
| [Contribuciones](#contributing) | Entender patrones seguros para colaborar |

## 🧭 Inicio rápido en un vistazo

| Objetivo | Comando | Notas |
|---|---|---|
| Iniciar el pipeline de monitoreo | `./autopub_monitor/autopub_monitor_tmux_session.sh start` | Inicia observador + cola + sincronización + panel manual |
| Detener todos los servicios | `./autopub_monitor/autopub_monitor_tmux_session.sh stop` | Apagado limpio y limpieza de paneles |
| Encolar por patrón | `./autopub_monitor/queue_file_utility.sh "pattern"` | Añade archivos coincidentes a la cola de procesamiento |
| Procesar un archivo | `./autopub_monitor/autopub.sh "/path/to/video.mp4"` | Usa la configuración y publicación predeterminadas |

## 🎯 Resumen del proyecto

| Enfoque | Detalles |
|---|---|
| Objetivo de ejecución | Linux, con orquestación `tmux` y `systemd` opcional |
| Modelo de cola | Observador de archivos → cola → scripts de trabajo → pipeline de publicación |
| Puntos de entrada principales | `autopub_monitor_tmux_session.sh`, `autopub.py`, `autopub.config` |
| Seguimiento de estado | `queue_list.txt`, `queue.lock`, `processed.csv`, `videos_db.csv` |

## Visión general

AutoPubMonitor es una canalización de automatización orientada a Linux para el procesamiento de contenido en vídeo y publicación multiplataforma. El sistema detecta nuevos archivos de vídeo, los procesa por etapas (incluyendo reparación de compatibilidad, enriquecimiento opcional, procesamiento relacionado con transcripción/traducción mediante API) y publica los resultados en las plataformas configuradas.

El tiempo de ejecución está orquestado por shell (`tmux`, `inotifywait`, `rsync`, `flock`) con clientes de procesamiento en Python y seguimiento de estado basado en CSV/texto.

## Funcionalidades clave

| Capacidad | Detalles |
|---|---|
| Detección automática de archivos | Supervisa directorios para nuevos contenidos de vídeo |
| Gestión de cola de procesamiento | Gestiona vídeos de forma controlada y secuencial |
| Procesamiento de vídeo | Comprueba duración, formatos y prepara los vídeos |
| Publicación multiplataforma | Soporta XiaoHongShu, Bilibili, Douyin, ShiPinHao y YouTube |
| Sistema de caché | Optimiza el procesamiento reutilizando resultados en caché |
| Sincronización de archivos | Gestiona movimientos de archivos entre sistemas |
| Configuración centralizada | Todas las rutas y opciones en un único archivo de configuración |
| Instalación sencilla | Un script para configurar todo el sistema |
| Reparación de compatibilidad de vídeo | Usa comprobaciones de FFmpeg y fallback opcional de HandBrakeCLI |
| Operación orientada a servicio | Sesiones `tmux` + servicio `systemd` opcional |
| Documentación internacional | Enlaces de idioma en la raíz e `i18n/` con traducciones |

## Estructura del repositorio

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

## Componentes del sistema

### Procesamiento principal

| Componente | Rol |
|---|---|
| `autopub.py` | Motor principal que orquesta carga, procesamiento y publicación |
| `process_video.py` | Cliente de procesamiento de vídeo para carga, procesamiento y manejo de resultados |
| `video_utils.py` / `handbrake.py` | Comprobaciones de compatibilidad y reparaciones antes de la carga |

### Gestión de cola

| Componente | Rol |
|---|---|
| `process_queue.sh` | Consumidor de cola con bloqueo `flock` y bucle de reintento |
| `queue_file_utility.sh` | Entrada manual a la cola por ruta o patrón de nombre |

### Gestión de servicios

| Componente | Rol |
|---|---|
| `autopub_monitor_tmux_session.sh` | Inicia y detiene servicios en múltiples paneles de tmux |
| `autopub.sh` | Wrapper de Conda/bootstrap para `autopub.py` |
| `autopub_sync.sh` | Sincroniza archivos desde directorios remotos/sincronizados |
| `monitor_autopublish.sh` | Observador `inotify` para nuevos archivos y encolado |

### Utilidades

| Componente | Rol |
|---|---|
| `window_info_utility.py` | Utilidad de ventana activa usando `xdotool` (opcional) |
| `autopub.config` | Archivo de configuración central |
| `install_autopub_monitor.sh` | Script de instalación y configuración de `systemd` |

## Requisitos

| Requisito | Notas |
|---|---|
| Entorno Linux con bash | Objetivo principal de tiempo de ejecución |
| Python 3.8+ | El instalador actualmente crea un entorno conda Python 3.8 |
| Miniconda en `${HOME}/miniconda3` | Ruta esperada por defecto en los scripts |
| `ffmpeg` / `ffprobe` | Requeridos para validación/procesamiento de vídeo |
| `tmux` | Orquestación de servicios |
| `inotify-tools` | Monitorización de eventos de archivo (`inotifywait`) |
| `rsync` | Sincronización entre directorios/sistemas |
| `python3-pip` | Instalación de paquetes de Python |
| Opcional: `HandBrakeCLI` | Recomendado para reparar vídeos problemáticos |
| Opcional: `xdotool` | Requerido por `window_info_utility.py` |

Los paquetes Python usados en scripts del repositorio incluyen:

- `requests`
- `requests_toolbelt`
- `selenium`
- `tqdm`
- `numpy`

## Instalación

### 🚀 Instalación automática (guiada por script)

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

### 🧩 Habilitar/iniciar el servicio (si no lo habilitó el instalador)

```bash
sudo systemctl enable autopub-monitor.service
sudo systemctl start autopub-monitor.service
```

### 🛠️ Configuración manual

1. Revisa y modifica `autopub_monitor/autopub.config` para tu entorno.
2. Crea y activa el entorno:

```bash
conda create -n autopub-video python=3.8 -y
conda activate autopub-video
pip install requests requests_toolbelt selenium tqdm numpy
```

3. Haz que los scripts sean ejecutables:

```bash
chmod +x autopub_monitor/*.sh
```

> Suposición: los archivos de estado del repositorio en ejecución (por ejemplo, `queue.lock`, `temp_queue.txt`, `checked_list.txt`) ya deben existir o crearse por tu flujo de arranque/instalación.

## Configuración

Archivo de configuración principal: `autopub_monitor/autopub.config`

Ajustes importantes incluyen:

- Directorios de datos: `AUTOPUBLISH_DIR`, `TRANSCRIPTION_DIR`, `PREPROCESSED_VIDEOS_DIR`
- Directorios de origen para sincronización: `JIANGUOYUN_*`
- Archivos de estado: `QUEUE_LIST`, `TEMP_QUEUE`, `CHECKED_LIST`, `VIDEOS_DB_PATH`, `PROCESSED_PATH`
- Archivos de bloqueo: `QUEUE_LOCK`, `AUTOPUB_LOCK`
- Ajustes de API: `USE_APP_API`, `APP_API_BASE_URL`, `UPLOAD_URL`, `PROCESS_URL`, `PUBLISH_URL`
- Ajustes de Conda: `CONDA_ENV`, `CONDA_DIR`, `CONDA_ACTIVATE`

Notas:

- La configuración predeterminada actualmente prefiere el modo API de aplicación (`USE_APP_API="true"`) y construye las URLs de endpoint desde `APP_API_BASE_URL`.
- Los endpoints antiguos siguen presentes en la configuración como referencia.
- Los nombres de archivos de cola y bloqueo pueden cambiarse con bajo riesgo si todos los scripts usan las mismas entradas de configuración.

## Uso

### ▶️ Iniciar servicios

Desde la raíz del repositorio:

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Esto inicia:

- Servicio de sincronización de archivos
- Servicio de monitoreo de directorios
- Servicio de procesamiento de cola
- Panel de comando manual
- Sesión de `rsync` de transcripción (`am-transcription-sync`)

### ⏹️ Detener servicios

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh stop
```

### 📥 Gestión manual de la cola

```bash
# Añadir por coincidencia de patrón
./autopub_monitor/queue_file_utility.sh "pattern_to_match"

# Añadir por ruta completa
./autopub_monitor/queue_file_utility.sh "/full/path/to/video.mp4"

# Añadir con auto-confirmación (sin aviso de selección)
./autopub_monitor/queue_file_utility.sh -y "pattern_to_match"
```

### 🎬 Procesamiento manual de vídeo

```bash
# Procesar un archivo específico usando los valores por defecto del wrapper
./autopub_monitor/autopub.sh "/path/to/video.mp4"

# CLI directa con objetivos de publicación concretos
python autopub_monitor/autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"

# Opciones de caché + visualización de progreso
python autopub_monitor/autopub.py --use-cache --use-translation-cache --use-metadata-cache --path "/path/to/video.mp4" -v

# Subida/proceso sin publicar
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

- En modo API de aplicación (`USE_APP_API=true`), la publicación está desactivada de forma predeterminada, salvo que se pasen flags de publicación explícitamente.

## 🎛️ Panel de comandos

| Área | Ejemplos |
|---|---|
| Controles del servicio | `autopub_monitor_tmux_session.sh start/stop` |
| Operaciones de cola | `queue_file_utility.sh`, `process_queue.sh` |
| Sincronización/proceso de archivos | `autopub_sync.sh`, `autopub.sh`, `monitor_autopublish.sh` |
| Ruta de ejecución Python | `autopub.py`, `process_video.py`, `video_utils.py` |

## Arquitectura de procesamiento

1. **Detección de archivos**: `monitor_autopublish.sh` vigila los eventos `close_write`/`moved_to`.
2. **Encolado**: Los archivos válidos se añaden a `queue_list.txt` usando `flock`.
3. **Procesamiento**: `process_queue.sh` consume entradas de la cola y llama a `autopub.sh`.
4. **Carga/proceso/publicación**: `autopub.py` y `process_video.py` llaman a los endpoints de API configurados.
5. **Seguimiento**: Los archivos procesados se escriben en `processed.csv`, los archivos descubiertos en `videos_db.csv`.

## Ejemplos prácticos

### Ejemplo 1: Modo demonio de extremo a extremo 🧪

```bash
./autopub_monitor/autopub_monitor_tmux_session.sh start
```

Después, añade o sincroniza vídeos en tu directorio de origen configurado y observa los logs en paneles de tmux.

### Ejemplo 2: Volver a ejecutar archivos que coincidan 🔁

```bash
python autopub_monitor/autopub.py --force "keyword1,keyword2" --use-cache --use-translation-cache --use-metadata-cache -v
```

### Ejemplo 3: Prueba local sin publicación 🧷

```bash
python autopub_monitor/autopub.py --no-pub --test --path "/path/to/video.mp4"
```

## Notas de desarrollo

- No hay manifiesto de dependencias fijadas (`requirements.txt` / `pyproject.toml`) en la raíz del repositorio.
- El tiempo de ejecución depende fuertemente de herramientas de shell Linux y convenciones locales de rutas.
- Los scripts cargan la configuración de shell dinámicamente (`autopub.config`); conserva expresiones de variables compatibles con shell.
- La semántica de cola y bloqueo se basa en `flock`; evita cambios que debiliten las actualizaciones atómicas de la cola.
- Los detalles del contrato API se infieren del código del cliente; la implementación del servidor es externa a este repositorio.
- El directorio `i18n/` existe, pero en este ciclo de redacción las traducciones de documentación no están completamente actualizadas.
- Los archivos de artefactos procesados (`queue_list.txt`, `temp_queue.txt`, etc.) suelen generarse/administrarse en tiempo de ejecución y pueden variar según el entorno.

## Compatibilidad de nombres heredados (conservada)

La documentación anterior usaba etiquetas renombradas de componentes. Los nombres actuales de los archivos del repositorio permanecen como se indica abajo.

| Etiqueta anterior en documentación | Archivo actual del repositorio |
|---|---|
| `video_processor_core.py` | `autopub.py` |
| `video_processing_client.py` | `process_video.py` |
| `queue_manager_service.sh` | `process_queue.sh` |
| `service_manager.sh` | `autopub_monitor_tmux_session.sh` |
| `process_video_wrapper.sh` | `autopub.sh` |
| `file_sync_service.sh` | `autopub_sync.sh` |
| `file_watcher_service.sh` | `monitor_autopublish.sh` |

Si estás en `cd autopub_monitor`, estas formas equivalentes de comandos de documentación antigua corresponden a:

```bash
# Estilo de documentación antigua (comandos equivalentes por ubicación)
./autopub_monitor_tmux_session.sh start
./autopub_monitor_tmux_session.sh stop
./queue_file_utility.sh "pattern_to_match"
./autopub.sh "/path/to/video.mp4"
python autopub.py --pub-xhs --pub-bilibili --path "/path/to/video.mp4"
python autopub.py --use-cache --use-translation-cache --path "/path/to/video.mp4" -v
```

## Solución de problemas

| Síntoma | Qué comprobar |
|---|---|
| `Miniconda not found at ~/miniconda3` | Instala Miniconda o actualiza `CONDA_DIR` en `autopub.config`. |
| `inotifywait: command not found` | Instala `inotify-tools`. |
| Fallos de `ffprobe`/`ffmpeg` | Instala `ffmpeg`; valida la integridad del archivo de entrada. |
| Vídeos que no se encolan repetidamente | Revisa `checked_list.txt`, `temp_queue.txt` y los logs del monitor en `monitor_autopublish.sh`. |
| Cola bloqueada o problemas de carrera | Inspecciona `queue.lock`, `queue_list.txt` y procesos activos con `flock`. |
| Errores de subida/proceso/publicación de API | Verifica `APP_API_BASE_URL` y rutas de endpoints en `autopub.config`. |
| Servicio de tmux no arranca | Confirma que `tmux has-session` funcione y que los scripts tengan permisos de ejecución. |

## Hoja de ruta

- Añadir gestión de dependencias con versiones fijadas (`requirements.txt` o `pyproject.toml`).
- Añadir comprobaciones CI para linting de shell/Python y pruebas de integración básicas.
- Añadir documentación de contrato API y supuestos de despliegue.
- Ampliar `i18n/` con READMEs traducidos y mantenidos.
- Mejorar observabilidad (registros estructurados y checks de salud).

## Contribución

Las contribuciones son bienvenidas.

Flujo de trabajo recomendado:

1. Haz un fork y crea una rama de características.
2. Mantén cambios pequeños y enfocados (scripts + docs juntos).
3. Valida en un entorno Linux con las herramientas de sistema requeridas.
4. Envía un pull request con notas de reproducción y pruebas claramente explicadas.

Si cambia el comportamiento, actualiza ambos:

- `README.md`
- `PROJECT_STRUCTURE.md` y/o `autopub_monitor/README.md`

## Agradecimientos

- Construido en torno a herramientas nativas de Linux (`tmux`, `inotify`, `rsync`, `ffmpeg`) para automatización continua y fiable.
- Gracias a contribuyentes y usuarias/es que sostienen las mejoras continuas.

## Licencia

Apache License 2.0 - Consulta [LICENSE](LICENSE) para más detalles.


## ❤️ Support

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://camo.githubusercontent.com/24a4914f0b42c6f435f9e101621f1e52535b02c225764b2f6cc99416926004b7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f446f6e6174652d4c617a79696e674172742d3045413545393f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f2d6669266c6f676f436f6c6f723d7768697465)](https://chat.lazying.art/donate) | [![PayPal](https://camo.githubusercontent.com/d0f57e8b016517a4b06961b24d0ca87d62fdba16e18bbdb6aba28e978dc0ea21/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f50617950616c2d526f6e677a686f754368656e2d3030343537433f7374796c653d666f722d7468652d6261646765266c6f676f3d70617970616c266c6f676f436f6c6f723d7768697465)](https://paypal.me/RongzhouChen) | [![Stripe](https://camo.githubusercontent.com/1152dfe04b6943afe3a8d2953676749603fb9f95e24088c92c97a01a897b4942/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f5374726970652d446f6e6174652d3633354246463f7374796c653d666f722d7468652d6261646765266c6f676f3d737472697065266c6f676f436f6c6f723d7768697465)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |
