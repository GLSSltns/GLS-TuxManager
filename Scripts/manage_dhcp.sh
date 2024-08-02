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

show_error_details() {
    error_type=$1
    error_details=$2

    echo -e "${RED}Error: $error_type"
    echo -e "${YELLOW}Details:"
    echo -e "${WHITE}$error_details${NOCOLOR}"
}

categorize_error() {
    error_log=$1
    if echo "$error_log" | grep -q "subnet"; then
        show_error_details "Subnet Configuration Error" "$error_log"
    elif echo "$error_log" | grep -q "interface"; then
        show_error_details "Interface Configuration Error" "$error_log"
    else
        show_error_details "Unknown Error" "$error_log"
    fi
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
            error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
            show_message $RED "Failed to start DHCP. Check details below."
            categorize_error "$error_log"
        fi
    fi
}

validate_restart(){
    clear
    show_title $YELLOW
    systemctl restart dhcpd > /dev/null 2>&1
    is_dhcp_started
    if [ $is_started -eq 1 ]; then
        show_message $GREEN "DHCP service restarted successfully."
    else
        error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
        show_message $RED "Failed to restart DHCP. Check details below."
        categorize_error "$error_log"
    fi
}

validate_stop(){
    clear
    show_title $YELLOW
    systemctl stop dhcpd > /dev/null 2>&1
    is_dhcp_started
    if [ $is_started -eq 0 ]; then
        show_message $GREEN "DHCP service stopped successfully."
    else
        error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
        show_message $RED "Failed to stop DHCP. Check details below."
        categorize_error "$error_log"
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
                # DHCP start
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_start
                ;;
            2)
                # DHCP restart
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_restart
                ;;
            3)
                # DHCP stop
                echo -e "${YELLOW}Checking for DHCP status"
                sleep 2
                validate_stop
                ;;
            4)
                # Go back to main menu
                break
                ;;
            *)
                # Invalid option
                show_message $RED "Invalid option. Please enter a number between 1 and 4."
                ;;
        esac
    done
}

main() {
    menu_dhcp
}

main
