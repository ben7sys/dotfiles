#!/bin/bash

# Function to create and activate a Python virtual environment
setup_venv() {
    local venv_name="${1:-venv}"
    
    # Check if python3 is installed
    if ! command -v python3 &> /dev/null; then
        echo "Error: python3 is not installed"
        exit 1
    fi

    # Check if venv module is available
    python3 -c "import venv" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "Python venv module not found. Please install python3-venv:"
        echo "For Debian/Ubuntu: sudo apt install python3-venv"
        echo "For RHEL/CentOS/Fedora: sudo dnf install python3-venv"
        exit 1
    fi

    # Create virtual environment if it doesn't exist
    if [ ! -d "$venv_name" ]; then
        echo "Creating new virtual environment: $venv_name"
        python3 -m venv "$venv_name"
    else
        echo "Virtual environment $venv_name already exists"
    fi

    # Activate the virtual environment
    echo "To activate the virtual environment, run:"
    echo "source $venv_name/bin/activate"
    echo
    echo "After activation, you can use pip safely:"
    echo "pip install <package-name>"
    echo
    echo "To deactivate when finished:"
    echo "deactivate"
}

# Create a virtual environment in the current directory
setup_venv "$@"
