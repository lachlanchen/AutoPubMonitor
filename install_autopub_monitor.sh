#!/bin/bash
# install-autopub-monitor.sh
# Simple installation script for autopub-monitor system

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

# Make sure autopub_monitor_tmux_session.sh is executable
ensure_executable() {
    local script_path="$(pwd)/autopub_monitor_tmux_session.sh"
    
    if [ ! -f "$script_path" ]; then
        error "Required script not found: autopub_monitor_tmux_session.sh"
    fi
    
    chmod +x "$script_path"
    log "Made autopub_monitor_tmux_session.sh executable"
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

# Install basic dependencies
ensure_dependencies() {
    log "Ensuring tmux is installed (required for the daemon script)"
    apt-get update && apt-get install -y tmux || error "Failed to install tmux"
}

# Main function
main() {
    log "Starting installation of autopub-monitor service"
    check_root
    ensure_dependencies
    ensure_executable
    install_service
    
    echo -e "\n${BOLD}${GREEN}Installation complete!${NC}"
    echo -e "The autopub-monitor service is now running from $(pwd)"
    echo -e "To check the status, run: ${BOLD}sudo systemctl status autopub-monitor${NC}"
    echo -e "To view logs, run: ${BOLD}sudo journalctl -u autopub-monitor${NC}"
    echo -e "To manually start/stop/restart: ${BOLD}sudo systemctl [start|stop|restart] autopub-monitor${NC}"
}

# Run the main function
main