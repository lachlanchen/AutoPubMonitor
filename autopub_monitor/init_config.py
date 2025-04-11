#!/usr/bin/env python3
import os
import sys
import json

def init_system():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, script_dir)
    
    try:
        # Import the config module
        from config import CONFIG
        
        # Create required directories
        directories = [
            CONFIG["data_dir"],
            CONFIG["auto_publish_dir"],
            CONFIG["transcription_data_dir"],
            CONFIG["logs_dir"],
            CONFIG["logs_autopub_dir"]
        ]
        
        for directory in directories:
            os.makedirs(directory, exist_ok=True)
            print(f"Created or verified directory: {directory}")
        
        # Create empty files if they don't exist
        files = [
            CONFIG["videos_db_path"],
            CONFIG["processed_path"],
            CONFIG["queue_list_path"],
            CONFIG["temp_queue_path"],
            CONFIG["checked_list_path"],
            CONFIG["queue_lock_path"]
        ]
        
        for file_path in files:
            if not os.path.exists(file_path):
                with open(file_path, 'a') as f:
                    pass  # Just create an empty file
                print(f"Created empty file: {file_path}")
        
        # Export config to bash format
        export_bash_config(CONFIG)
        
        print("System initialized successfully.")
        return 0
    except Exception as e:
        print(f"Error initializing system: {e}")
        return 1

def export_bash_config(config):
    """Export configuration to bash format for shell scripts"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, "autopub_config.sh")
    
    lines = ["#!/bin/bash", "# AutoPubMonitor configuration", ""]
    
    # Add activation of virtual environment if it exists
    venv_script = os.path.join(script_dir, "activate_venv.sh")
    if os.path.exists(venv_script):
        lines.append(f"# Source virtual environment")
        lines.append(f"if [ -f \"{venv_script}\" ]; then")
        lines.append(f"    source \"{venv_script}\"")
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

if __name__ == "__main__":
    sys.exit(init_system())
