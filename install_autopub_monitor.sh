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
        apt-get install -y $1 || error "Failed to install $1"
    else
        log "Package $1 is already installed."
    fi
}

# Make sure required files are executable
ensure_executables() {
    local current_dir=$(pwd)
    local scripts=(
        "autopub_monitor_tmux_session.sh"
        "autopub_sync.sh"
        "monitor_autopublish.sh"
        "process_queue.sh"
        "requeue.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$current_dir/$script" ]; then
            chmod +x "$current_dir/$script"
            log "Made $script executable"
        else
            warning "Script not found: $script (not critical, but may be needed)"
        fi
    done
    
    # Check for critical script
    if [ ! -f "$current_dir/autopub_monitor_tmux_session.sh" ]; then
        error "Required script not found: autopub_monitor_tmux_session.sh"
    fi
}

# Create named pipe for queue if it doesn't exist
create_named_pipe() {
    local current_dir=$(pwd)
    local pipe_path="$current_dir/queue.pipe"
    
    if [ ! -p "$pipe_path" ]; then
        log "Creating named pipe at $pipe_path"
        mkfifo "$pipe_path"
    else
        log "Named pipe already exists at $pipe_path"
    fi
}

# Create necessary files if they don't exist
create_empty_files() {
    local current_dir=$(pwd)
    local files=(
        "queue_list.txt"
        "temp_queue.txt"
        "checked_list.txt"
        "queue.lock"
        "processed.csv"
        "videos_db.csv"
        "ignore_list.txt"
    )
    
    for file in "${files[@]}"; do
        if [ ! -f "$current_dir/$file" ]; then
            log "Creating empty file: $file"
            touch "$current_dir/$file"
        else
            log "File already exists: $file"
        fi
    done
}

# Install systemd service
install_service() {
    local service_name="autopub-monitor.service"
    local service_path="/etc/systemd/system/$service_name"
    local current_dir=$(pwd)
    local username=$(stat -c '%U' "$current_dir/autopub_monitor_tmux_session.sh")
    
    log "Creating systemd service file: $service_path"
    
    cat > "$service_path" << EOF
[Unit]
Description=AutoPublish Monitoring and Queue Processing
Wants=network-online.target
After=network-online.target

[Service]
User=$username
Type=forking
WorkingDirectory=$current_dir
ExecStart=$current_dir/autopub_monitor_tmux_session.sh start
ExecStop=$current_dir/autopub_monitor_tmux_session.sh stop
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
    systemctl status "$service_name" || true
}

# Create data directories
create_directories() {
    local username=$(stat -c '%U' "$(pwd)/autopub_monitor_tmux_session.sh")
    local user_home=$(eval echo ~$username)
    
    local dirs=(
        "$user_home/AutoPublishDATA"
        "$user_home/AutoPublishDATA/AutoPublish"
        "$user_home/AutoPublishDATA/transcription_data"
        "$(pwd)/logs"
        "$(pwd)/logs-autopub"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log "Creating directory: $dir"
            mkdir -p "$dir"
            chown $username:$username "$dir"
        else
            log "Directory already exists: $dir"
        fi
    done
}

# Install dependencies
install_dependencies() {
    log "Updating package lists..."
    apt-get update || error "Failed to update package lists"
    
    log "Installing required packages..."
    local packages=(
        "tmux"
        "inotify-tools"
        "ffmpeg"
        "python3"
        "python3-pip"
        "rsync"
    )
    
    for pkg in "${packages[@]}"; do
        check_package "$pkg"
    done
    
    log "Installing Python dependencies..."
    pip3 install requests requests-toolbelt selenium || warning "Failed to install some Python dependencies"
}

# Main function
main() {
    log "Starting installation of autopub-monitor service"
    
    check_root
    
    log "Installing dependencies..."
    install_dependencies
    
    log "Setting up required directories..."
    create_directories
    
    log "Creating required files..."
    create_empty_files
    
    log "Setting up queue pipe..."
    create_named_pipe
    
    log "Setting executable permissions..."
    ensure_executables
    
    log "Installing systemd service..."
    install_service
    
    echo -e "\n${BOLD}${GREEN}Installation complete!${NC}"
    echo -e "The autopub-monitor service is now running from $(pwd)"
    echo -e "To check the status, run: ${BOLD}sudo systemctl status autopub-monitor${NC}"
    echo -e "To view logs, run: ${BOLD}sudo journalctl -u autopub-monitor${NC}"
    echo -e "To manually start/stop/restart: ${BOLD}sudo systemctl [start|stop|restart] autopub-monitor${NC}"
}

# Run the main function
main