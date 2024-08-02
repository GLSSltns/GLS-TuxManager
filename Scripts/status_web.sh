#!/bin/bash

# COLORS: Define color codes for terminal output
MAIN_COLOR='\033[0;1;34;94m'
HTTPCOLOR='\033[1;35m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'  # Reset color

# UTILS: Source utility scripts for additional functionality
source Utils/progress_bar.sh
source Utils/show_message.sh

show_title() {
    clear
    bash Utils/show_title.sh $HTTPCOLOR
}

check_service_status() {
    local service_name=$1
    local service_color=$2

    systemctl is-active --quiet $service_name
    if [ $? -eq 0 ]; then
        show_message "-" "$service_name is running." $service_color
    else
        show_message "X" "$service_name is not running." $RED
    fi
}

check_web_service() {
    check_service_status "httpd" $HTTPCOLOR
}

main() {
    show_title
    show_message "!" "Checking WEB Service status..." $YELLOW
    progress_bar 5 $YELLOW &
    wait
    check_web_service
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 4.5
}

main

