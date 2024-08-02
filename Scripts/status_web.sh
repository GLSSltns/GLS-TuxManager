#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
GREEN2='\033[0;32m'
PINK='\033[1;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'
HTTPCOLOR='\033[1;35m'

show_title() {
    clear
    bash Utils/show_title.sh $HTTPCOLOR
}

show_message() {
    local c=$1
    local message=$2
    local color=$3
    echo -e " ${BLUE}[${color}${c}${BLUE}]${color} ${message}${NOCOLOR}"
}

progress_bar() {
    local duration=$1
    local steps=10
    local interval=$((duration / steps))

    local color=$2
    for ((i = 0; i <= steps; i++)); do
        echo -ne "${BLUE} ["
        for ((j = 0; j < i; j++)); do echo -ne "${color}###"; done
        for ((j = i; j < steps; j++)); do echo -ne "${NOCOLOR}..."; done
        echo -ne "${BLUE}] ${color}$((i * 10))${BLUE}%\r"
        sleep $interval
    done
    echo -e "${NOCOLOR}"
}

check_service_status() {
    local service_name=$1
    local service_color=$2

    systemctl is-active --quiet $service_name
    if [ $? -eq 0 ]; then
        show_message "✓" "$service_name is running." $service_color
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

