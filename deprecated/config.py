#!/usr/bin/env python3
# config.py - Central configuration for AutoPubMonitor system

import os
import json
from pathlib import Path
import getpass

# Base directories - Get current user even when running with sudo
try:
    SUDO_USER = os.environ.get('SUDO_USER')
    CURRENT_USER = SUDO_USER if SUDO_USER else getpass.getuser()
    if SUDO_USER:
        HOME_DIR = os.path.expanduser(f"~{SUDO_USER}")
    else:
        HOME_DIR = os.path.expanduser("~")
except Exception:
    # Fallback to standard home directory if any error occurs
    HOME_DIR = os.path.expanduser("~")

DEFAULT_BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Data directories
DEFAULT_DATA_DIR = os.path.join(HOME_DIR, "AutoPublishDATA")
DEFAULT_AUTO_PUBLISH_DIR = os.path.join(DEFAULT_DATA_DIR, "AutoPublish")
DEFAULT_TRANSCRIPTION_DATA_DIR = os.path.join(DEFAULT_DATA_DIR, "transcription_data")

# Configuration file path
CONFIG_FILE = os.path.join(DEFAULT_BASE_DIR, "autopub_config.json")

# Default configuration
DEFAULT_CONFIG = {
    # System paths
    "base_dir": DEFAULT_BASE_DIR,
    "data_dir": DEFAULT_DATA_DIR,
    "auto_publish_dir": DEFAULT_AUTO_PUBLISH_DIR,
    "transcription_data_dir": DEFAULT_TRANSCRIPTION_DATA_DIR,
    "logs_dir": os.path.join(DEFAULT_BASE_DIR, "logs"),
    "logs_autopub_dir": os.path.join(DEFAULT_BASE_DIR, "logs-autopub"),

    # Database files
    "videos_db_path": os.path.join(DEFAULT_BASE_DIR, "videos_db.csv"),
    "processed_path": os.path.join(DEFAULT_BASE_DIR, "processed.csv"),
    
    # Queue files
    "queue_list_path": os.path.join(DEFAULT_BASE_DIR, "queue_list.txt"),
    "temp_queue_path": os.path.join(DEFAULT_BASE_DIR, "temp_queue.txt"),
    "checked_list_path": os.path.join(DEFAULT_BASE_DIR, "checked_list.txt"),
    "queue_lock_path": os.path.join(DEFAULT_BASE_DIR, "queue.lock"),
    "queue_pipe_path": os.path.join(DEFAULT_BASE_DIR, "queue.pipe"),
    
    # Script paths
    "autopub_script_path": os.path.join(DEFAULT_BASE_DIR, "autopub.py"),
    "autopub_sh_path": os.path.join(DEFAULT_BASE_DIR, "autopub.sh"),
    "monitor_script_path": os.path.join(DEFAULT_BASE_DIR, "monitor_autopublish.sh"),
    "process_queue_script_path": os.path.join(DEFAULT_BASE_DIR, "process_queue.sh"),
    "sync_script_path": os.path.join(DEFAULT_BASE_DIR, "autopub_sync.sh"),
    
    # Server URLs
    "upload_url": "http://localhost:8081/upload",
    "process_url": "http://localhost:8081/video-processing",
    "publish_url": "http://lazyingart:8081/publish",
    
    # Publishing platforms default (when no flags provided)
    "default_publish_platforms": {
        "publish_xhs": True,
        "publish_bilibili": True,
        "publish_douyin": True, 
        "publish_shipinhao": True,
        "publish_y2b": True
    },
    
    # Sync configuration
    "sync_source": os.path.join(HOME_DIR, "jianguoyun", "AutoPublishDATA", "AutoPublish"),
    "sync_target": os.path.join(HOME_DIR, "AutoPublishDATA", "AutoPublish"),
    "sync_interval": 10,  # seconds
    
    # Video processing
    "min_video_length": 7,  # seconds
    "video_file_extensions": ["mp4", "mov", "avi", "flv", "wmv", "mkv"],
    
    # Conda environment
    "conda_path": os.path.join(HOME_DIR, "miniconda3", "bin", "activate"),
    "conda_env": "autopub-video",
    
    # Python virtual environment
    "venv_path": os.path.join(DEFAULT_BASE_DIR, "venv"),
    "venv_activate_script": os.path.join(DEFAULT_BASE_DIR, "activate_venv.sh")
}

# Load configuration
def load_config():
    """Load configuration from file, creating default if it doesn't exist"""
    if os.path.isfile(CONFIG_FILE):
        try:
            with open(CONFIG_FILE, 'r') as f:
                config = json.load(f)
            
            # Ensure all default config keys exist in the loaded config
            for key, value in DEFAULT_CONFIG.items():
                if key not in config:
                    config[key] = value
            
            return config
        except Exception as e:
            print(f"Error loading config file: {e}")
            print("Using default configuration instead.")
            return DEFAULT_CONFIG
    else:
        # Create default config file
        save_config(DEFAULT_CONFIG)
        return DEFAULT_CONFIG

# Save configuration
def save_config(config):
    """Save configuration to file"""
    try:
        os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=4)
    except Exception as e:
        print(f"Error saving config file: {e}")

# Create required directories
def create_required_directories(config):
    """Create all required directories from configuration"""
    directories = [
        config["data_dir"],
        config["auto_publish_dir"],
        config["transcription_data_dir"],
        config["logs_dir"],
        config["logs_autopub_dir"]
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"Created or verified directory: {directory}")

# Create required files
def create_required_files(config):
    """Create empty files if they don't exist"""
    files = [
        config["videos_db_path"],
        config["processed_path"],
        config["queue_list_path"],
        config["temp_queue_path"],
        config["checked_list_path"],
        config["queue_lock_path"]
    ]
    
    for file_path in files:
        if not os.path.exists(file_path):
            with open(file_path, 'a') as f:
                pass  # Just create an empty file
            print(f"Created empty file: {file_path}")

# Create named pipe
def create_named_pipe(config):
    """Create named pipe if it doesn't exist"""
    pipe_path = config["queue_pipe_path"]
    if not os.path.exists(pipe_path):
        try:
            os.mkfifo(pipe_path)
            print(f"Created named pipe: {pipe_path}")
        except Exception as e:
            print(f"Error creating named pipe: {e}")
            print("Named pipe creation may require running with sudo")

# Export config to bash format for shell scripts
def export_bash_config(config, output_path=None):
    """Export configuration to bash format for shell scripts"""
    if output_path is None:
        output_path = os.path.join(os.path.dirname(CONFIG_FILE), "autopub_config.sh")
    
    lines = ["#!/bin/bash", "# AutoPubMonitor configuration", ""]
    
    # Add activation of virtual environment if it exists
    if "venv_activate_script" in config and os.path.exists(config["venv_activate_script"]):
        lines.append(f"# Source virtual environment")
        lines.append(f"if [ -f \"{config['venv_activate_script']}\" ]; then")
        lines.append(f"    source \"{config['venv_activate_script']}\"")
        lines.append(f"fi")
        lines.append("")
    
    for key, value in config.items():
        # Handle nested dictionaries
        if isinstance(value, dict):
            for sub_key, sub_value in value.items():
                lines.append(f'export AUTOPUB_{key.upper()}_{sub_key.upper()}="{str(sub_value)}"')
        # Handle strings, numbers, and booleans
        else:
            lines.append(f'export AUTOPUB_{key.upper()}="{str(value)}"')
    
    with open(output_path, 'w') as f:
        f.write('\n'.join(lines))
    
    # Make the file executable
    os.chmod(output_path, 0o755)
    print(f"Exported bash configuration to: {output_path}")
    
    return output_path

# Initialize the system
def init_system():
    """Initialize the system with configuration"""
    print(f"Using home directory: {HOME_DIR}")
    config = load_config()
    create_required_directories(config)
    create_required_files(config)
    create_named_pipe(config)
    export_bash_config(config)
    return config

# Get configuration
CONFIG = load_config()

if __name__ == "__main__":
    # If run directly, initialize the system
    config = init_system()
    print("System initialized with configuration:")
    for key, value in config.items():
        if not isinstance(value, dict):
            print(f"  {key}: {value}")
        else:
            print(f"  {key}:")
            for sub_key, sub_value in value.items():
                print(f"    {sub_key}: {sub_value}")
