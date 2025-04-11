#!/bin/bash
# install_autopub_monitor.sh
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

# Get the actual user who executed sudo (or current user if not using sudo)
get_actual_user() {
    if [ -n "$SUDO_USER" ]; then
        echo "$SUDO_USER"
    else
        whoami
    fi
}

# Get the actual user's home directory
get_user_home() {
    local actual_user=$(get_actual_user)
    getent passwd "$actual_user" | cut -d: -f6
}

ACTUAL_USER=$(get_actual_user)
USER_HOME=$(get_user_home)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check package installation
check_package() {
    if ! dpkg -l | grep -q "^ii  $1 "; then
        log "Package $1 is not installed. Installing..."
        apt-get install -y $1 || error "Failed to install $1"
    else
        log "Package $1 is already installed."
    fi
}

# Create virtual environment for Python dependencies
create_virtualenv() {
    log "Creating virtual environment for Python dependencies..."
    
    if ! command -v python3 -m venv &> /dev/null; then
        log "Installing python3-venv package..."
        apt-get install -y python3-venv python3-full
    fi
    
    VENV_DIR="${SCRIPT_DIR}/venv"
    log "Setting up virtual environment at ${VENV_DIR}"
    
    if [ -d "$VENV_DIR" ]; then
        log "Virtual environment already exists, updating it"
    else
        python3 -m venv "$VENV_DIR"
    fi
    
    # Ensure venv is owned by the actual user
    chown -R "$ACTUAL_USER":"$ACTUAL_USER" "$VENV_DIR"
    
    # Install Python dependencies in the venv
    log "Installing Python dependencies in virtual environment..."
    sudo -u "$ACTUAL_USER" bash -c "source ${VENV_DIR}/bin/activate && pip install requests requests-toolbelt selenium"
    
    # Create activation script for the services
    cat > "${SCRIPT_DIR}/activate_venv.sh" << EOF
#!/bin/bash
# Source this file to activate the virtual environment
source "${VENV_DIR}/bin/activate"
EOF
    
    chmod +x "${SCRIPT_DIR}/activate_venv.sh"
    chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/activate_venv.sh"
}

# Make sure required files are executable
ensure_executables() {
    local scripts=(
        "autopub_monitor_tmux_session.sh"
        "autopub_sync.sh"
        "monitor_autopublish.sh"
        "process_queue.sh"
        "requeue.sh"
        "autopub.sh"
        "setup_config.sh"
        "activate_venv.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "${SCRIPT_DIR}/$script" ]; then
            chmod +x "${SCRIPT_DIR}/$script"
            chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/$script"
            log "Made $script executable and set ownership"
        else
            if [ "$script" != "activate_venv.sh" ]; then  # Ignore missing activate_venv.sh
                warning "Script not found: $script (not critical, but may be needed)"
            fi
        fi
    done
    
    # Check for critical script
    if [ ! -f "${SCRIPT_DIR}/autopub_monitor_tmux_session.sh" ]; then
        error "Required script not found: autopub_monitor_tmux_session.sh"
    fi
}

# Create named pipe for queue if it doesn't exist
create_named_pipe() {
    local pipe_path="${SCRIPT_DIR}/queue.pipe"
    
    if [ ! -p "$pipe_path" ]; then
        log "Creating named pipe at $pipe_path"
        mkfifo "$pipe_path"
        chown "$ACTUAL_USER":"$ACTUAL_USER" "$pipe_path"
    else
        log "Named pipe already exists at $pipe_path"
        chown "$ACTUAL_USER":"$ACTUAL_USER" "$pipe_path"
    fi
}

# Create necessary files if they don't exist
create_empty_files() {
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
        if [ ! -f "${SCRIPT_DIR}/$file" ]; then
            log "Creating empty file: $file"
            touch "${SCRIPT_DIR}/$file"
        else
            log "File already exists: $file"
        fi
        chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/$file"
    fi
}

# Update config.py with correct user home path
update_config_py() {
    if [ -f "${SCRIPT_DIR}/config.py" ]; then
        log "Updating config.py with correct user home path..."
        # Backup original config.py
        cp "${SCRIPT_DIR}/config.py" "${SCRIPT_DIR}/config.py.bak"
        
        # Replace HOME_DIR in config.py
        sed -i "s|^HOME_DIR = os.path.expanduser(\"~\")|HOME_DIR = \"${USER_HOME}\"|" "${SCRIPT_DIR}/config.py"
        
        chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/config.py"
    else
        error "config.py file not found at ${SCRIPT_DIR}/config.py"
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
User=$ACTUAL_USER
Type=forking
WorkingDirectory=$SCRIPT_DIR
ExecStart=$SCRIPT_DIR/autopub_monitor_tmux_session.sh start
ExecStop=$SCRIPT_DIR/autopub_monitor_tmux_session.sh stop
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    log "Reloading systemd daemon"
    systemctl daemon-reload
    
    log "Enabling $service_name"
    systemctl enable "$service_name"
}

# Create data directories
create_directories() {
    local dirs=(
        "${USER_HOME}/AutoPublishDATA"
        "${USER_HOME}/AutoPublishDATA/AutoPublish"
        "${USER_HOME}/AutoPublishDATA/transcription_data"
        "${USER_HOME}/jianguoyun/AutoPublishDATA/AutoPublish"
        "${USER_HOME}/jianguoyun/AutoPublishDATA/transcription_data"
        "${SCRIPT_DIR}/logs"
        "${SCRIPT_DIR}/logs-autopub"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log "Creating directory: $dir"
            mkdir -p "$dir"
            chown "$ACTUAL_USER":"$ACTUAL_USER" "$dir"
        else
            log "Directory already exists: $dir"
            chown "$ACTUAL_USER":"$ACTUAL_USER" "$dir"
        fi
    done
}

# Install dependencies as root
install_dependencies() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error "This part of the script must be run as root (use sudo)"
    fi
    
    log "Updating package lists..."
    apt-get update || error "Failed to update package lists"
    
    log "Installing required packages..."
    local packages=(
        "tmux"
        "inotify-tools"
        "ffmpeg"
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-full"
        "rsync"
    )
    
    for pkg in "${packages[@]}"; do
        check_package "$pkg"
    done
    
    # Create Python virtual environment
    create_virtualenv
}

# Run initial configuration as the actual user
run_initial_config() {
    log "Running initial configuration setup as user $ACTUAL_USER..."
    sudo -u "$ACTUAL_USER" bash -c "cd ${SCRIPT_DIR} && source ./activate_venv.sh && python3 ./setup_config.sh --initialize --export"
    
    # Ensure config files are owned by the actual user
    if [ -f "${SCRIPT_DIR}/autopub_config.json" ]; then
        chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/autopub_config.json"
    fi
    if [ -f "${SCRIPT_DIR}/autopub_config.sh" ]; then
        chown "$ACTUAL_USER":"$ACTUAL_USER" "${SCRIPT_DIR}/autopub_config.sh"
        chmod +x "${SCRIPT_DIR}/autopub_config.sh"
    fi
}

# Start the service
start_service() {
    log "Starting autopub-monitor service..."
    systemctl start autopub-monitor.service
    systemctl status autopub-monitor.service
}

# Check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        error "This script must be run as root (use sudo)"
    fi
}

# Main function
main() {
    log "Starting installation of autopub-monitor service"
    
    # This script needs to be run with sudo
    check_root
    
    log "Installing as user: $ACTUAL_USER (home: $USER_HOME)"
    
    log "Installing system dependencies..."
    install_dependencies
    
    log "Updating config.py with correct paths..."
    update_config_py
    
    log "Setting up required directories..."
    create_directories
    
    log "Creating required files..."
    create_empty_files
    
    log "Setting up queue pipe..."
    create_named_pipe
    
    log "Setting executable permissions..."
    ensure_executables
    
    log "Running initial configuration..."
    run_initial_config
    
    log "Installing systemd service..."
    install_service
    
    log "Starting service..."
    start_service
    
    echo -e "\n${BOLD}${GREEN}Installation complete!${NC}"
    echo -e "The autopub-monitor service is now running from ${SCRIPT_DIR}"
    echo -e "To check the status, run: ${BOLD}sudo systemctl status autopub-monitor${NC}"
    echo -e "To view logs, run: ${BOLD}sudo journalctl -u autopub-monitor${NC}"
    echo -e "To manually start/stop/restart: ${BOLD}sudo systemctl [start|stop|restart] autopub-monitor${NC}"
    echo -e "To check service status: ${BOLD}${SCRIPT_DIR}/autopub_monitor_tmux_session.sh status${NC}"
}

# Run the main function
main
