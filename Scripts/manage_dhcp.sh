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

show_title() {
    clear
    bash Utils/show_title.sh
}

menu_dhcp_man() {
    show_title
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
                sudo systemctl start dhcpd
                sleep 1
                echo -e "${GREEN}DHCP Started successfully"
            2)
                sudo systemctl restart dhcpd
                sleep 1
                echo -e "${GREEN}DHCP Restarted successfully"
            3)
                sudo systemctl stop dhcpd
                sleep 1
                echo -e "${GREEN}DHCP Stopped successfully"
            4)
                break
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${NOCOLOR}"
                ;;
        esac
    done
}

main() {
    menu_dhcp
}

main
