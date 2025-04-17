#!/bin/bash
# install_autopub_monitor.sh - Installation script for AutoPub Monitor

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR"

# Source the config file
source "${SCRIPT_DIR}/autopub.config"

# Function to echo with timestamp
echo_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" | grep -q "^ii"
    return $?
}

# Check and install required packages
install_dependencies() {
    echo_with_timestamp "Checking and installing dependencies..."
    
    # List of packages to install
    packages=("tmux" "inotify-tools" "ffmpeg" "python3-pip")
    
    for pkg in "${packages[@]}"; do
        if ! is_package_installed "$pkg"; then
            echo_with_timestamp "Installing $pkg..."
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        else
            echo_with_timestamp "$pkg is already installed."
        fi
    done
    
    # Check for Conda environment
    if [ -d "$CONDA_DIR" ]; then
        if ! conda info --envs | grep -q "$CONDA_ENV"; then
            echo_with_timestamp "Creating Conda environment $CONDA_ENV..."
            conda create -y -n "$CONDA_ENV" python=3.8
            eval "$CONDA_ACTIVATE"
            pip install requests requests_toolbelt selenium
        else
            echo_with_timestamp "Conda environment $CONDA_ENV already exists."
        fi
    else
        echo_with_timestamp "Miniconda not found at $CONDA_DIR. Please install Miniconda first."
        exit 1
    fi
}

# Create directories if they don't exist
create_directories() {
    echo_with_timestamp "Creating required directories..."
    
    mkdir -p "$LOGS_DIR"
    mkdir -p "$AUTOPUB_LOGS_DIR"
    mkdir -p "$AUTOPUBLISH_DIR"
    mkdir -p "$TRANSCRIPTION_DIR"
    mkdir -p "$JIANGUOYUN_AUTOPUBLISH_DIR"
    mkdir -p "$JIANGUOYUN_TRANSCRIPTION_DIR"
    
    # Create empty database files if they don't exist
    touch "$VIDEOS_DB_PATH"
    touch "$PROCESSED_PATH"
    touch "$QUEUE_LIST"
    touch "$TEMP_QUEUE"
    touch "$CHECKED_LIST"
    touch "$QUEUE_LOCK"
}

# Create the systemd service file
create_service() {
    echo_with_timestamp "Creating systemd service..."
    
    cat > "/tmp/autopub-monitor.service" << EOF
[Unit]
Description=AutoPublish Monitoring and Queue Processing
Wants=network-online.target
After=network-online.target

[Service]
User=${USER_NAME}
Type=forking
ExecStart=${AUTOPUB_MONITOR_TMUX_SESSION_SH} start
ExecStop=${AUTOPUB_MONITOR_TMUX_SESSION_SH} stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    sudo mv "/tmp/autopub-monitor.service" "/etc/systemd/system/autopub-monitor.service"
    sudo systemctl daemon-reload
    
    echo_with_timestamp "To enable the service at boot, run: sudo systemctl enable autopub-monitor.service"
    sudo systemctl enable --now autopub-monitor.service
    echo_with_timestamp "To start the service now, run: sudo systemctl start autopub-monitor.service"
}

# Make scripts executable
make_scripts_executable() {
    echo_with_timestamp "Making scripts executable..."
    
    chmod +x "$AUTOPUB_SH"
    chmod +x "$PROCESS_QUEUE_SH"
    chmod +x "$MONITOR_AUTOPUBLISH_SH"
    chmod +x "$AUTOPUB_SYNC_SH"
    chmod +x "$AUTOPUB_MONITOR_TMUX_SESSION_SH"
}

# Main installation process
echo_with_timestamp "Starting installation of AutoPub Monitor..."
install_dependencies
create_directories
make_scripts_executable
create_service
echo_with_timestamp "Installation completed successfully!"
