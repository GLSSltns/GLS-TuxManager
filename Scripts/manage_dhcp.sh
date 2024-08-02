#!/bin/bash

# COLORS
MAIN_COLOR='\033[0;1;34;94m'
DHCPCOLOR='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

source Utils/show_message.sh
source Utils/progress_bar.sh
source Utils/show_title.sh


validate_start(){
    progress_bar "5" "${YELLOW}"
    if systemctl is-active --quiet dhcpd; then
        echo "${YELLOW}Service is now started"
    else
        systemctl start dhcpd
        if [ $? -eq 0 ]; then
            echo "${GREEN}Service started succesfully"
        else
            echo -e "${RED}Error while starting service"
            journalctl -xeu dhcpd.service | grep dhcpd /dev/null 2>&1
        fi
    fi
}

validate_stop(){
    progress_bar "5" "${YELLOW}"
    if systemctl is-active --quiet dhcpd; then
        systemctl stop dhcpd
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Service stopped succesfully"
        else
            echo -e "${RED}Error while stopping service"
            journalctl -xeu dhcpd.service | grep dhcpd
        fi
    else
        echo -e "${YELLOW}Service is not running"
    fi
}

validate_restart(){
    progress_bar "5" "${YELLOW}"
    if systemctl is-active --quiet dhcpd; then
        systemctl restart dhcpd
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Service restarted succesfully"
        else
            echo -e "${RED}Error while restarting service"
            journalctl -xeu dhcpd.service | grep dhcpd
        fi
    else
        echo -e "${YELLOW}Service is not running"
    fi
}


menu_dhcp_man() {
    echo -ne "\n${MAIN_COLOR}[${LIGHTBLUE}1${MAIN_COLOR}]${NOCOLOR} Start DHCP service"
    echo -ne "\n${MAIN_COLOR}[${LIGHTBLUE}2${MAIN_COLOR}]${NOCOLOR} Restart DHCP service"
    echo -ne "\n${MAIN_COLOR}[${LIGHTBLUE}3${MAIN_COLOR}]${NOCOLOR} Stop DHCP service"
    echo -e "\n${MAIN_COLOR}[${LIGHTBLUE}4${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_dhcp() {
    menu_dhcp_man
    while true; do
        echo -ne "${MAIN_COLOR}Enter An Option${LIGHTBLUE}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                #DHCP start
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_start
                ;;
            2)
                #DHCP restart
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_restart
                ;;
            3)
                #DHCP stop
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_stop
                ;;
            4)
                #Go back to main menu
                break
                ;;
            *)
                #Invalid option
                show_message
                ;;
        esac
    done
}

main() {
    menu_dhcp
}

main

