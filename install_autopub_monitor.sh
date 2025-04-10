#!/bin/bash
# install-autopub-monitor.sh
# Installation script for autopub-monitor system

set -e

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Print with timestamp
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Print step information
step() {
    echo -e "\n${BOLD}${GREEN}Step $1: $2${NC}"
}

# Print warning
warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Print error and exit
error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root (use sudo)"
    fi
}

# Check package installation
check_package() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        log "Package $1 is not installed. Installing..."
        apt-get update && apt-get install -y $1 || error "Failed to install $1"
    else
        log "Package $1 is already installed."
    fi
}

# Create directories if they don't exist
create_directories() {
    local dirs=(
        "$HOME/Projects/autopub_monitor"
        "$HOME/ProjectsLFS/autopub_monitor"
        "$HOME/AutoPublishDATA/AutoPublish"
        "$HOME/AutoPublishDATA/transcription_data"
        "$HOME/ProjectsLFS/autopub_monitor/logs"
        "$HOME/ProjectsLFS/autopub_monitor/logs-autopub"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log "Creating directory: $dir"
            mkdir -p "$dir"
        else
            log "Directory already exists: $dir"
        fi
    done
}

# Create empty files if they don't exist
create_empty_files() {
    local files=(
        "$HOME/ProjectsLFS/autopub_monitor/videos_db.csv"
        "$HOME/ProjectsLFS/autopub_monitor/processed.csv"
        "$HOME/Projects/autopub_monitor/queue_list.txt"
        "$HOME/Projects/autopub_monitor/temp_queue.txt"
        "$HOME/Projects/autopub_monitor/checked_list.txt"
        "$HOME/Projects/autopub_monitor/queue.lock"
    )
    
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            log "Creating empty file: $file"
            touch "$file"
        else
            log "File already exists: $file"
        fi
    done
}

# Copy files to their proper locations
copy_files() {
    local current_dir=$(pwd)
    
    # Files that go in Projects/autopub_monitor
    local project_files=(
        "autopub_monitor_tmux_session.sh"
        "autopub_sync.sh"
        "requeue.sh"
        "process_queue.sh"
        "monitor_autopublish.sh"
    )
    
    # Files that go in ProjectsLFS/autopub_monitor
    local projectslfs_files=(
        "autopub.py"
        "autopub.sh"
        "process_video.py"
    )
    
    log "Copying files to their proper locations..."
    
    # Make destination directories
    mkdir -p "$HOME/Projects/autopub_monitor"
    mkdir -p "$HOME/ProjectsLFS/autopub_monitor"
    
    # Copy project files
    for file in "${project_files[@]}"; do
        if [ -f "$current_dir/$file" ]; then
            cp "$current_dir/$file" "$HOME/Projects/autopub_monitor/"
            chmod +x "$HOME/Projects/autopub_monitor/$file"
            log "Copied and made executable: $file to Projects/autopub_monitor/"
        else
            warning "File not found: $file"
        fi
    done
    
    # Copy projectslfs files
    for file in "${projectslfs_files[@]}"; do
        if [ -f "$current_dir/$file" ]; then
            cp "$current_dir/$file" "$HOME/ProjectsLFS/autopub_monitor/"
            chmod +x "$HOME/ProjectsLFS/autopub_monitor/$file"
            log "Copied and made executable: $file to ProjectsLFS/autopub_monitor/"
        else
            warning "File not found: $file"
        fi
    done
}

# Create named pipe for queue if it doesn't exist
create_named_pipe() {
    local pipe_path="$HOME/Projects/autopub_monitor/queue.pipe"
    
    if [ ! -p "$pipe_path" ]; then
        log "Creating named pipe at $pipe_path"
        mkfifo "$pipe_path"
    else
        log "Named pipe already exists at $pipe_path"
    fi
}

# Install systemd service
install_service() {
    local service_name="autopub-monitor.service"
    local service_path="/etc/systemd/system/$service_name"
    
    log "Creating systemd service file: $service_path"
    
    cat > "$service_path" << EOF
[Unit]
Description=AutoPublish Monitoring and Queue Processing
Wants=network-online.target
After=network-online.target

[Service]
User=$(whoami)
Type=forking
ExecStart=$HOME/Projects/autopub_monitor/autopub_monitor_tmux_session.sh start
ExecStop=$HOME/Projects/autopub_monitor/autopub_monitor_tmux_session.sh stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    log "Reloading systemd daemon"
    systemctl daemon-reload
    
    log "Enabling $service_name"
    systemctl enable "$service_name"
    
    log "Starting $service_name"
    systemctl start "$service_name"
    
    log "Service status:"
    systemctl status "$service_name"
}

# Install dependencies
install_dependencies() {
    log "Installing required packages..."
    apt-get update
    
    local packages=(
        "tmux"
        "inotify-tools"
        "ffmpeg"
        "python3"
        "python3-pip"
    )
    
    for pkg in "${packages[@]}"; do
        check_package "$pkg"
    done
    
    log "Installing Python dependencies..."
    pip3 install requests requests-toolbelt selenium
}

# Setup Conda environment if needed
setup_conda_env() {
    if command -v conda &>/dev/null; then
        log "Conda is installed."
        
        if conda env list | grep -q "autopub-video"; then
            log "Conda environment 'autopub-video' exists."
        else
            log "Creating Conda environment 'autopub-video'..."
            conda create -y -n autopub-video python=3.8
            conda activate autopub-video
            pip install requests requests-toolbelt selenium
            conda deactivate
            log "Conda environment created and packages installed."
        fi
    else
        warning "Conda is not installed. Skipping Conda environment setup."
        warning "You may need to manually set up the 'autopub-video' environment later."
    fi
}

# Main function
main() {
    step "1" "Checking prerequisites"
    check_root
    
    step "2" "Installing dependencies"
    install_dependencies
    
    step "3" "Creating directories"
    create_directories
    
    step "4" "Creating empty files"
    create_empty_files
    
    step "5" "Copying files"
    copy_files
    
    step "6" "Creating named pipe"
    create_named_pipe
    
    step "7" "Setting up Conda environment"
    setup_conda_env
    
    step "8" "Installing systemd service"
    install_service
    
    echo -e "\n${BOLD}${GREEN}Installation complete!${NC}"
    echo -e "The autopub-monitor service is now running."
    echo -e "To check the status, run: ${BOLD}sudo systemctl status autopub-monitor${NC}"
    echo -e "To view logs, run: ${BOLD}sudo journalctl -u autopub-monitor${NC}"
    echo -e "To manually start/stop/restart: ${BOLD}sudo systemctl [start|stop|restart] autopub-monitor${NC}"
}

# Run the main function
main
