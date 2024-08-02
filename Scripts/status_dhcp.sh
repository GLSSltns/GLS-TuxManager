#!/bin/bash

# COLORS: Define color codes for terminal output
MAIN_COLOR='\033[0;1;34;94m'
DHCPCOLOR='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

# UTILS: Source utility scripts for additional functionality
source Utils/progress_bar.sh
source Utils/show_message.sh

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

check_status() {
    show_title
    echo -e "${MAIN_COLOR}Checking DHCP service status...${NOCOLOR}"

    DHCPDSTATUS=$(systemctl status dhcpd)
    STATUS=$(echo $DHCPDSTATUS | grep -Po "Active: \K[a-z\(\)_]*")
    PID=$(echo $DHCPDSTATUS | grep -Po "PID: \K[\d]*")
    MEMORY=$(echo $DHCPDSTATUS | grep -Po "Memory: \K[\dA-Z.]*")
    CPU=$(echo $DHCPDSTATUS | grep -Po "CPU: \K[\da-z.]*")

    echo -e "${MAIN_COLOR}Status: ${NOCOLOR}$STATUS"
    echo -e "${MAIN_COLOR}PID: ${NOCOLOR}$PID"
    echo -e "${MAIN_COLOR}Memory: ${NOCOLOR}$MEMORY"
    echo -e "${MAIN_COLOR}CPU: ${NOCOLOR}$CPU"
    echo -e "${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -e "${MAIN_COLOR}Press any key to return to the main menu.${NOCOLOR}"
    read -r -n 1
}

show_logs() {
    show_title
    echo -e "${MAIN_COLOR}Showing DHCP leases log...${NOCOLOR}"

    HOSTNAMES=$(grep -Po "client-hostname \K[\d:a-zA-Z^\"]*" /var/lib/dhcpd/dhcpd.leases | sed 's/"//g' | sort | uniq)
    ADDRESSES=$(grep -Po "lease \K[\d.]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq)
    MACS=$(grep -Po "ethernet \K[\d:a-fA-F]*" /var/lib/dhcpd/dhcpd.leases | sort | uniq)

    echo -e "${MAIN_COLOR}--------------------------------------------------${NOCOLOR}"
    printf "${MAIN_COLOR}│ ${WHITE}%-10s${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-17s${MAIN_COLOR} │${NOCOLOR}\n" "HOSTNAME" "ADDRESS" "MAC"
    echo -e "${MAIN_COLOR}--------------------------------------------------${NOCOLOR}"
    
    for i in $(seq 1 $(echo "$HOSTNAMES" | wc -l)); do
        HOSTNAME=$(echo "$HOSTNAMES" | sed -n "${i}p")
        ADDRESS=$(echo "$ADDRESSES" | sed -n "${i}p")
        MAC=$(echo "$MACS" | sed -n "${i}p")
        printf "${MAIN_COLOR}│ ${WHITE}%-10s${MAIN_COLOR} │ ${WHITE}%-15s${MAIN_COLOR} │ ${WHITE}%-17s${MAIN_COLOR} │${NOCOLOR}\n" "$HOSTNAME" "$ADDRESS" "$MAC"
    done

    echo -e "${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -e "${MAIN_COLOR}Press any key to return to the main menu.${NOCOLOR}"
    read -r -n 1
}

main_menu() {
    while [ true ]; do
        show_title
        echo ""
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Check DHCP Service Status"
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Show DHCP Leases Logs"
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Exit DHCP Monitoring"
        echo ""
        echo -ne " ${MAIN_COLOR}Enter an option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
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