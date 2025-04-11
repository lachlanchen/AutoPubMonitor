#!/bin/bash
# setup_config.sh - Configuration setup script

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to display usage
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help          Display this help message"
    echo "  -c, --create        Create default configuration only"
    echo "  -i, --initialize    Initialize the system (create configs and directories)"
    echo "  -e, --export        Export Python config to Bash config"
    echo
    echo "Without any options, this script will initialize the system."
}

# Function to check if Python is available
check_python() {
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is required but not found."
        exit 1
    fi
}

# Function to create default configuration
create_config() {
    check_python
    
    echo "Creating default configuration..."
    python3 "${SCRIPT_DIR}/config.py"
    
    if [ $? -eq 0 ]; then
        echo "Configuration created successfully."
    else
        echo "Error creating configuration."
        exit 1
    fi
}

# Function to initialize the system
initialize_system() {
    check_python
    
    echo "Initializing system..."
    python3 "${SCRIPT_DIR}/config.py"
    
    if [ $? -eq 0 ]; then
        echo "System initialized successfully."
    else
        echo "Error initializing system."
        exit 1
    fi
}

# Function to export configuration to bash
export_config() {
    check_python
    
    echo "Exporting configuration to bash..."
    # Export configuration using Python directly
    python3 "${SCRIPT_DIR}/config.py" --export
}

# Process command line arguments
if [ $# -eq 0 ]; then
    initialize_system
else
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--create)
                create_config
                shift
                ;;
            -i|--initialize)
                initialize_system
                shift
                ;;
            -e|--export)
                export_config
                shift
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
fi

# Check if bash config exists before sourcing
if [ -f "${SCRIPT_DIR}/autopub_config.sh" ]; then
    echo "Bash configuration file exists at: ${SCRIPT_DIR}/autopub_config.sh"
    echo "You can source it in your scripts with: source ${SCRIPT_DIR}/autopub_config.sh"
else
    echo "Warning: Bash configuration file not found."
    echo "You may need to run this script with --export option."
fi

exit 0
