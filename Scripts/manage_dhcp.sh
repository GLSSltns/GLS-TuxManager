#!/bin/bash

# COLORS
MAIN_COLOR="$(tput setaf 26)"
TUXCOLOR="$(tput setaf 172)"
DHCPCOLOR="$(tput setaf 221)"
LIGHTBLUE="$(tput setaf 39)"
BLUE="$(tput setaf 4)"
RED="$(tput setaf 160)"
GREEN="$(tput setaf 40)"
YELLOW="$(tput setaf 220)"
WHITE="$(tput setaf 255)"
NOCOLOR="$(tput sgr0)"

source Utils/show_message.sh
source Utils/progress_bar.sh
source Utils/show_title.sh

is_started=0

is_dhcp_started(){
    is_started=$(systemctl is-active dhcpd | grep -Po "^active" | grep -q ac && echo 1 || echo 0)
}
validate_start(){
    clear
    show_title $YELLOW
    is_dhcp_started
    if [ $is_started -eq 1 ]; then
        show_message $RED "DHCP is already running."
    else
        systemctl start dhcpd > /dev/null 2>&1
        is_dhcp_started
        if [ $is_started -eq 1 ]; then
            show_message $GREEN "DHCP service started successfully."
        else
            error=$(journalctl -xeu dhcpd.service | "/etc/dhcp/dhcpd.conf")
            echo -e "${RED}Failed to start DHCP"
            echo "$error"
        fi
    fi
}


menu_dhcp_man() {
    show_title $DHCPCOLOR
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

