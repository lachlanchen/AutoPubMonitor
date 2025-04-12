#!/bin/bash
# autopub.sh - Wrapper script for executing autopub.py with proper environment

# Source the config file
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/autopub.config"

# Load the user's bash profile to ensure all environment variables are set
source ~/.bashrc

# Activate Conda environment
eval "$CONDA_ACTIVATE"

# Capture the first argument as the full path
full_path="$1"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

echo_with_timestamp "Executing autopub.py with file: ${full_path}..."

# Create log directory if it doesn't exist
mkdir -p "${AUTOPUB_LOGS_DIR}"

# Wait for lock file to be released
while [ -f "${AUTOPUB_LOCK}" ]; do
    echo_with_timestamp "Another instance of the script is running. Waiting..."
    sleep 10  # Check every 10 seconds
done

# Create a lock file
touch "${AUTOPUB_LOCK}"

# Ensure the lock file is removed when the script finishes
trap 'rm -f "${AUTOPUB_LOCK}"; exit' INT TERM EXIT

echo_with_timestamp "Executing autopub.py..."
if [ -n "${full_path}" ]; then
    # If a full path is provided, run the script with the --path argument
    echo_with_timestamp "Processing file: ${full_path}..."
    sleep 10
    python "${AUTOPUB_PY}" --use-cache --use-metadata-cache --use-translation-cache --path "${full_path}" > "${AUTOPUB_LOGS_DIR}/autopub_$(date '+%Y-%m-%d_%H-%M-%S').log" 2>&1
else
    sleep 10
    # If no path is provided, run the script without the --path argument
    python "${AUTOPUB_PY}" --use-cache --use-metadata-cache --use-translation-cache > "${AUTOPUB_LOGS_DIR}/autopub_$(date '+%Y-%m-%d_%H-%M-%S').log" 2>&1
fi

echo_with_timestamp "Finished executing autopub.py with file: ${full_path}..."

# Remove the lock file and clear the trap
rm -f "${AUTOPUB_LOCK}"
trap - INT TERM EXIT

echo_with_timestamp "Finished autopub.sh..."