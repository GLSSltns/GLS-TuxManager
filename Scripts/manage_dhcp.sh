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
    echo "Iniciando el servicio DHCP..."
    if systemctl is-active --quiet dhcpd; then
        echo "El servicio DHCP ya está iniciado."
    else
        systemctl start dhcpd
        if [ $? -eq 0 ]; then
            echo "El servicio DHCP se ha iniciado correctamente."
            systemctl enable dhcpd
        else
            echo "Error al iniciar el servicio DHCP."
            journalctl -xe > /dev/null/ 2>&1| grep dhcpd
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

