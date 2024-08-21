## Overview

This script is designed to streamline the process of connecting an iOS device from the Corellium instance over USB on a Linux machine. It automates the installation of necessary packages, sets up services, and configures network exposure for `usbfluxd`, making it easier for users to connect their devices and start working with Corellium.

## Purpose

Working with iOS devices in Corellium often requires a specific setup on a Linux machine, including the installation and configuration of various services like `usbmuxd`, `socat`, and `usbfluxd`. This script automates the setup process, ensuring that all dependencies are installed and configured correctly. Additionally, it handles network exposure, allowing `usbfluxd` to be accessible over the network, which is essential for remote connections to Corellium instances.

## Features

- **Automated Installation**: The script checks for and installs all required packages (`usbmuxd`, `libimobiledevice-utils`, `socat`, and `usbfluxd`), ensuring the environment is properly set up.
- **Service Management**: It starts and enables the `usbmuxd` service, and starts `usbfluxd` and `avahi-daemon` with the necessary configurations.
- **Network Exposure**: The script exposes the `usbmuxd` socket on port 5000, allowing remote Corellium instances to connect to the device.
- **User Interaction**: Prompts the user for the IP address of the Corellium host and configures `usbfluxd` to connect to the specified remote instance.
- **Diagnostic Tools**: Includes checks for device detection and service status, helping users troubleshoot any issues.

## Prerequisite

- iOS device must be connected via openvpn.
- IP address of corellium host (could be found at **Connect** tab of corellium or Wifi setting of iOS application)

## Installation

1. **Clone the Bash file**:
    ```bash
    git clone https://github.com/dr34mhacks/corellium-ios-connect.git
    cd corellium-ios-connect
    ```

2. **Make the Script Executable**:
    ```bash
    chmod +x corellium-ios-connect-fix.sh
    ```

3. **Run the Script**:
    ```bash
    sudo ./corellium-ios-connect-fix.sh
    ```

### Running the script

<img width="1496" alt="image" src="https://github.com/user-attachments/assets/6181ad55-74bb-481a-b1c1-31434ed38c79">

### Provided IP address when prompted:

<img width="1496" alt="image" src="https://github.com/user-attachments/assets/dc46710c-84f7-45b3-bec4-2523bba806e8">

### Enumerating Frida Processes on corellium iOS device

<img width="1496" alt="image" src="https://github.com/user-attachments/assets/60dbea9b-d149-4666-958b-dab957ee4e80">

## Working

When you run the script, it will:
1. Update the package list.
2. Check for and install `usbmuxd`, `libimobiledevice-utils`, `socat`, and `usbfluxd` if they are not already installed.
3. Start and enable the `usbmuxd` service.
4. Start `avahi-daemon` and `usbfluxd` in the background.
5. Prompt you for the IP address of the Corellium host to which you want to connect.
6. Set up the necessary network exposure to allow `usbfluxd` to communicate with the Corellium instance.
7. Check if the device is detected and display the connection status.

After the script completes, your Linux machine should be ready to connect your iOS device to Corellium.

## Contributing

Contributions to improve the script or address any issues are welcome. Please submit a pull request with a clear description of the changes.

## Acknowledgments

This script was created to simplify the setup process for connecting iOS devices to Corellium, based on common requirements and configurations needed in the field. Special thanks to the open-source community for providing the tools and documentation that made this script possible.
