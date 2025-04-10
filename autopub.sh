#!/bin/bash

# Load the user's bash profile to ensure all environment variables are set
source ~/.bashrc  # or source ~/.profile if you're using bash

# Activate Conda environment
source /home/lachlan/miniconda3/bin/activate autopub-video

# Capture the first argument as the full path
full_path="$1"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

echo_with_timestamp "Executing autopub.py with file: ${full_path}..."

# Define the lock file and log file
lock_file="/home/lachlan/ProjectsLFS/autopub_monitor/autopub.lock"
log_dir="/home/lachlan/ProjectsLFS/autopub_monitor/logs-autopub"
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
if [ -n "${full_path}" ]; then
    # If a full path is provided, run the script with the --path argument
    echo_with_timestamp "Processing file: ${full_path}..."
    sleep 10
    /home/lachlan/miniconda3/envs/autopub-video/bin/python /home/lachlan/ProjectsLFS/autopub_monitor/autopub.py --use-cache --use-metadata-cache --use-translation-cache --path "${full_path}" > "${log_file}" 2>&1
else
    sleep 10
    # If no path is provided, run the script without the --path argument
    /home/lachlan/miniconda3/envs/autopub-video/bin/python /home/lachlan/ProjectsLFS/autopub_monitor/autopub.py --use-cache --use-metadata-cache --use-translation-cache > "${log_file}" 2>&1
fi

echo_with_timestamp "Finished executing autopub.py with file: ${full_path}..."

# Remove the lock file and clear the trap
rm -f "${lock_file}"
trap - INT TERM EXIT

echo_with_timestamp "Finished autopub.sh..."
