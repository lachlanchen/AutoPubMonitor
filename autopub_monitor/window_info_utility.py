#!/usr/bin/env python3
# window_info_utility.py - Utility to get current window name (formerly test_xdo.py)

import os
import subprocess
import argparse
from datetime import datetime

def get_current_window_name():
    """Get the name of the currently active window.
    
    Returns:
        str or None: The name of the active window if successful, None otherwise.
    """
    try:
        # Get the ID of the active window
        active_window_id = subprocess.check_output(["xdotool", "getactivewindow"]).decode().strip()

        # Get the name of the active window using its ID
        window_name = subprocess.check_output(["xdotool", "getwindowname", active_window_id]).decode().strip()

        return window_name
    except subprocess.CalledProcessError as e:
        print(f"Error: {e.output.decode() if hasattr(e, 'output') else str(e)}")
        return None

def save_window_info(output_path=None):
    """Save current window information to a file.
    
    Args:
        output_path (str, optional): Path to save the window info. 
                                     If None, saves to current directory.
    
    Returns:
        str: Path to the saved file.
    """
    window_name = get_current_window_name()
    
    # Generate output path if not provided
    if output_path is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_path = f"window_info_{timestamp}.txt"
    
    # Save the window information
    with open(output_path, 'w') as f:
        f.write(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Active Window: {window_name if window_name else 'Unable to determine'}\n")
        f.write(f"User: {os.getenv('USER')}\n")
        f.write(f"Hostname: {subprocess.check_output(['hostname']).decode().strip()}\n")
    
    return output_path

if __name__ == "__main__":
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Get information about the current active window")
    parser.add_argument("-o", "--output", help="Path to save window info (default: current directory)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Print verbose output")
    args = parser.parse_args()

    # Get window name
    window_name = get_current_window_name()
    
    if window_name:
        if args.verbose:
            print(f"The name of the current active window is: '{window_name}'")
        else:
            print(window_name)
            
        # Save window info if output path is specified
        if args.output:
            output_file = save_window_info(args.output)
            if args.verbose:
                print(f"Window information saved to: {output_file}")
    else:
        print("Failed to retrieve the active window name.")