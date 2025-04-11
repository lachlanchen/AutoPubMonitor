#!/usr/bin/env python3
import sys
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)

try:
    from config import CONFIG, export_bash_config
    export_bash_config(CONFIG)
    print('Configuration exported successfully.')
except Exception as e:
    print(f'Error exporting configuration: {e}')
    sys.exit(1)
