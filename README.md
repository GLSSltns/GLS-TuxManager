# TuxManager
**CentOS DHCP and HTTP manager tool**

TuxManager is a tool designed to manage DHCP and HTTP services on CentOS systems. It includes various scripts that automate the installation, configuration, management, and monitoring of these services.

## Scripts

### tuxmanager.sh
Main script that acts as the entry point for all TuxManager functions. This script provides an interface to interact with all other scripts easily.

### Scripts/install_dhcp.sh
This script installs the DHCP service on a CentOS system. It automates the installation process, ensuring that all necessary dependencies and configurations are properly implemented.

### Scripts/install_web.sh
Similar to the previous script, this one installs a web server (HTTP) on CentOS. It handles downloading, installing, and configuring the web server with default settings.

### Scripts/configure_dhcp.sh
This script is used to configure the DHCP service after installation. It allows customization of DHCP options such as IP range, default gateway, DNS servers, and more.

### Scripts/configure_web.sh
Used to configure the installed web server. It allows adjustment of parameters such as document root, access permissions, enabled modules, and more.

### Scripts/manage_dhcp.sh
Provides functions to manage the DHCP service, including options to start, stop, restart, and reload the service configuration.

### Scripts/manage_web.sh
Similar to the previous one, this script manages the web service, allowing actions such as starting, stopping, restarting, and reloading the web server configuration.

### Scripts/status_dhcp.sh
This script checks the status of the DHCP service, providing information on whether the service is active, uptime, and any relevant errors or warnings.

### Scripts/status_web.sh
Script that checks the status of the web service. It reports on whether the server is active, uptime, and possible errors or warnings in the service.
