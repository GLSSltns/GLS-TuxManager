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
DHCPCOLOR='\033[1;33m'

#Utils
source Utils/progress_bar.sh

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

show_message() {
    local c=$1
    local message=$2
    local color=$3
    echo -e " ${BLUE}[${color}${c}${BLUE}]${color} ${message}${NOCOLOR}"
}

check_status() {
    show_title
    echo -e "${BLUE}Checking DHCP service status...${NOCOLOR}"
    systemctl status dhcpd
    # DHCPDSTATUS=$(systemctl status dhcpd)
    # STATUS: echo $DHCPDSTATUS | grep -Po "Active: \K[a-z\(\)_]*"
    # PID: echo $DHCPDSTATUS | grep -Po "PID: \K[\d]*"
    # MEMORY: echo $DHCPDSTATUS | grep -Po "Memory: \K[\dA-Z.]*"
    # CPU: echo $DHCPDSTATUS | grep -Po "CPU: \K[\da-z.]*"
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -e "${BLUE}Press any key to return to the main menu.${NOCOLOR}"
    read -r -n 1
}

show_logs() {
    show_title
    echo -e "${BLUE}Showing DHCP leases log...${NOCOLOR}"
    cat /var/lib/dhcpd/dhcpd.leases
    # HOSTNAME: grep -Po "client-hostname \K[\d:a-zA-Z^\"]*" /var/lib/dhcpd/dhcpd.leases | sed 's/"//g' | sort | uniq
    # ADDRESS: grep -Po "lease \K[\d.]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq
    # MAC: grep -Po "ethernet \K[\d:a-fA-F]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq 


    #  HOSTNAME   |    ADDRESS     |        MAC        <- print_header
    #-------------------------------------------------
    #      PC     |  192.168.1.1   | xx:xx:xx:xx:xx:xx <- CICLO FOR (print_row)
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -e "${BLUE}Press any key to return to the main menu.${NOCOLOR}"
    read -r -n 1
}

main_menu() {
    while [ true ]; do
        show_title
        echo ""
        echo -e " ${BLUE}[${YELLOW}1${BLUE}]${NOCOLOR} Check DHCP Service Status"
        echo -e " ${BLUE}[${YELLOW}2${BLUE}]${NOCOLOR} Show DHCP Leases Logs"
        echo -e " ${BLUE}[${YELLOW}3${BLUE}]${NOCOLOR} Exit"
        echo ""
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) check_status ;;
            2) show_logs ;;
            3) break ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
}

main_menu
