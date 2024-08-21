#!/bin/bash
# Script to connect corellium iOS device with your local machine
# Tested in Debian (Kali), Ubuntu and Mint
# Script from Sid (https://github.com/dr34mhacks) 


# Color definitions
RESET='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'

# Function to print a message with a decorative border and color
print_message() {
    local message="$1"
    local color="$2"
    local border="=============================="
    echo -e "\n${color}${border}${RESET}"
    echo -e "${color}${message}${RESET}"
    echo -e "${color}${border}${RESET}"
}

# Function to install necessary packages
install_packages() {
    print_message "Updating package list..." "$CYAN"
    sudo apt update

    # Check if packages are already installed
    if dpkg -l | grep -q usbmuxd; then
        echo -e "${GREEN}usbmuxd is already installed.${RESET}"
    else
        print_message "Installing usbmuxd..." "$YELLOW"
        sudo apt install -y usbmuxd
    fi

    if dpkg -l | grep -q libimobiledevice-utils; then
        echo -e "${GREEN}libimobiledevice-utils is already installed.${RESET}"
    else
        print_message "Installing libimobiledevice-utils..." "$YELLOW"
        sudo apt install -y libimobiledevice-utils
    fi

    if ! command -v socat > /dev/null 2>&1; then
        print_message "Installing socat..." "$YELLOW"
        sudo apt install -y socat
    fi
}

# Function to download and install usbfluxd
install_usbfluxd() {
    print_message "Checking if usbfluxd is installed..." "$CYAN"

    if command -v usbfluxd > /dev/null 2>&1; then
        echo -e "${GREEN}usbfluxd is already installed.${RESET}"
    else
        print_message "Downloading and installing usbfluxd..." "$YELLOW"
        local download_url="https://github.com/corellium/usbfluxd/releases/download/v1.0/usbfluxd-x86_64-libc6-libdbus13.tar.gz"
        local temp_dir="/tmp/usbfluxd_install"
        mkdir -p $temp_dir
        wget $download_url -O $temp_dir/usbfluxd.tar.gz
        tar -xzf $temp_dir/usbfluxd.tar.gz -C $temp_dir

        if [ -f "$temp_dir/usbfluxd-x86_64-libc6-libdbus13/usbfluxd" ]; then
            sudo cp $temp_dir/usbfluxd-x86_64-libc6-libdbus13/usbfluxd /usr/local/bin/
            sudo chmod +x /usr/local/bin/usbfluxd
            echo -e "${GREEN}usbfluxd installed successfully.${RESET}"
        else
            echo -e "${RED}Failed to find usbfluxd binary. Installation may be incomplete.${RESET}"
            exit 1
        fi

        # Clean up , why not?
        rm -rf $temp_dir
    fi
}

# Function to start and enable services
start_services() {
    print_message "Starting and enabling usbmuxd service..." "$CYAN"

    if systemctl is-active --quiet usbmuxd; then
        echo -e "${GREEN}usbmuxd service is already running.${RESET}"
    else
        echo -e "${YELLOW}Starting usbmuxd service...${RESET}"
        sudo systemctl start usbmuxd
        sudo systemctl enable usbmuxd
        echo -e "${GREEN}usbmuxd service started and enabled.${RESET}"
    fi
}

# Function to check the status of usbfluxd and usbmuxd
check_service_status() {
    print_message "Checking status of usbfluxd and usbmuxd..." "$CYAN"
    echo -e "${BOLD}usbfluxd status:${RESET}"
    sudo systemctl status usbfluxd --no-pager
    echo -e "${BOLD}usbmuxd status:${RESET}"
    sudo systemctl status usbmuxd --no-pager
}

# Function to check for USB device detection
check_device_detection() {
    print_message "Checking if device is detected..." "$CYAN"
    idevice_id -l
}

# Function to reload udev rules 
reload_udev_rules() {
    print_message "Reloading udev rules..." "$CYAN"
    sudo udevadm control --reload-rules
}

# Function to diagnose and fix issues
diagnose_and_fix() {
    # Check and start services
    start_services

    # Check USB permissions
    print_message "Checking USB device permissions..." "$CYAN"
    if ! lsusb > /dev/null 2>&1; then
        echo -e "${RED}No USB devices detected. Please check your USB connections and try again.${RESET}"
        exit 1
    fi

    # Reload udev rules and check device detection again
    reload_udev_rules
    check_device_detection
}

# Function to start avahi-daemon, expose usbmuxd, and setup usbfluxd
setup_network_exposure() {
    print_message "Starting avahi-daemon..." "$CYAN"
    sudo nohup avahi-daemon > /dev/null 2>&1 &

    # Prompt user for the IP address of iOS device
    local ip_address
    read -p "Please enter the IP address of the Corellium host: " ip_address

    # Expose /var/run/usbmuxd on port 5000
    echo "Starting socat..."
    sudo socat tcp-listen:5000,fork unix-connect:/var/run/usbmuxd &
    socat_pid=$!

    # Wait for socat to start
    sleep 2

    # Run usbfluxd on the remote host
    export PATH=/usr/local/sbin:${PATH}
    echo "Starting usbfluxd with remote IP $ip_address..."
    sudo usbfluxd -f -r ${ip_address}:5000

    # Clean up socat process after usbfluxd setup
    wait $socat_pid
}

# Main script execution
print_message "Starting diagnostics and setup for Corellium connection..." "$CYAN"

# Install necessary packages
install_packages

# Install usbfluxd if necessary
install_usbfluxd

# Diagnose and fix issues
diagnose_and_fix

# Setup network exposure and connect to Corellium
setup_network_exposure

# Verify device connection
print_message "Verifying device connection..." "$CYAN"
check_device_detection

# Final instructions
print_message "Setup Complete" "$GREEN"
echo -e "If the device is detected, you can now connect it using Corellium."
