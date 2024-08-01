#!/bin/bash
# COLORS
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;1;33;93m'
RED='\033[1;31m'
GREEN='\033[0;1;32;92m'
NOCOLOR='\033[0m'

show_title() {
    clear
    bash Utils/show_title.sh
}

menu_dhcp_man() {
    show_title
    echo -ne "\n${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} Start DHCP service"
    echo -ne "\n${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} Restart DHCP service"
    echo -ne "\n${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Stop DHCP service"
    echo -e "\n${BLUE}[${LIGHTBLUE}4${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_dhcp() {
    menu_dhcp_man
    while true; do
        echo -ne "${BLUE}Enter An Option${LIGHTBLUE}\$${BLUE}>:${NOCOLOR} "
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
