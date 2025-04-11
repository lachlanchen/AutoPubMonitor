#!/bin/bash
# autopub.sh - Script to execute autopub.py with proper environment

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration file if it exists
CONFIG_FILE="${SCRIPT_DIR}/autopub_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Warning: Configuration file not found at $CONFIG_FILE"
    echo "Running setup_config.sh to generate configuration..."
    bash "${SCRIPT_DIR}/setup_config.sh" --export
    
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Error: Failed to generate configuration. Using default values."
    fi
fi

# Try to load the user's bash profile to ensure all environment variables are set
source ~/.bashrc 2>/dev/null || source ~/.profile 2>/dev/null || true

# Try to activate Conda environment if available
CONDA_PATH="${AUTOPUB_CONDA_PATH:-${HOME}/miniconda3/bin/activate}"
CONDA_ENV="${AUTOPUB_CONDA_ENV:-autopub-video}"

if [ -f "$CONDA_PATH" ]; then
    source "$CONDA_PATH" "$CONDA_ENV" || echo "Warning: Could not activate conda environment $CONDA_ENV"
else
    echo "Warning: Conda not found at $CONDA_PATH, using system Python"
fi

# Capture the first argument as the full path
full_path="$1"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

echo_with_timestamp "Executing autopub.py with file: ${full_path}..."

# Define the lock file and log file
lock_file="${SCRIPT_DIR}/autopub.lock"
log_dir="${AUTOPUB_LOGS_AUTOPUB_DIR:-${SCRIPT_DIR}/logs-autopub}"
log_file="${log_dir}/autopub_$(date '+%Y-%m-%d_%H-%M-%S').log"

# Create log directory if it doesn't exist
mkdir -p "${log_dir}"

# Wait for lock file to be released
while [ -f "${lock_file}" ]; do
    echo_with_timestamp "Another instance of the script is running. Waiting..."
    sleep 10  # Adjusted to check every 10 seconds
done

# Create a lock file
touch "${lock_file}"

# Ensure the lock file is removed when the script finishes
trap 'rm -f "${lock_file}"; exit' INT TERM EXIT

echo_with_timestamp "Executing autopub.py..."

# Find python in conda env or use system python
if [ -n "$CONDA_PREFIX" ]; then
    PYTHON_CMD="${CONDA_PREFIX}/bin/python"
else
    PYTHON_CMD="python3"
fi

if [ -n "${full_path}" ]; then
    # If a full path is provided, run the script with the --path argument
    echo_with_timestamp "Processing file: ${full_path}..."
    sleep 10
    $PYTHON_CMD "${SCRIPT_DIR}/autopub.py" --use-cache --use-metadata-cache --use-translation-cache --path "${full_path}" > "${log_file}" 2>&1
else
    sleep 10
    # If no path is provided, run the script without the --path argument
    $PYTHON_CMD "${SCRIPT_DIR}/autopub.py" --use-cache --use-metadata-cache --use-translation-cache > "${log_file}" 2>&1
fi

echo_with_timestamp "Finished executing autopub.py with file: ${full_path}..."

# Remove the lock file and clear the trap
rm -f "${lock_file}"
trap - INT TERM EXIT

echo_with_timestamp "Finished autopub.sh..."