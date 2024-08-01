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

ISINSTALLED=0

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

show_message()
{
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
    # echo ""   
    for ((i = 0; i <= steps; i++)); do
        echo -ne "${BLUE} ["
        for ((j = 0; j < i; j++)); do echo -ne "${color}###"; done
        for ((j = i; j < steps; j++)); do echo -ne "${NOCOLOR}..."; done
        echo -ne "${BLUE}] ${color}$((i * 10))${BLUE}%\r"

        sleep $interval
    done
    echo -e "${NOCOLOR}"
}
is_installed() {
    ISINSTALLED=$(yum list installed | grep -q dhcp-server && echo 1 || echo 0)
}

install_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        show_message "!" "DHCP Service Is Already Installed.\n" $YELLOW
    else
        show_title
        echo ""
        show_message "!" 'Downloanding DHCP Package (dhcp-server)...' $YELLOW
        sleep 1
        progress_bar 10 $YELLOW &
        yum install -y dhcp-server > /dev/null 2>&1
        wait
        sleep 1
        show_message "-" "DHCP Service Installed Successfully." $GREEN
        echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
        sleep 3.5
        show_title
        show_menu
    fi
}

remove_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        show_title
        echo ""
        show_message "!?" "The DHCP Service Package (dhcp-server) Will Be REMOVED!!" $RED
        echo -ne " Is It Okay? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            sleep 1
            show_message "!" "Removal canceled." $YELLOW
            echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 2
        else
            echo ""
            sleep 2
            show_message "!" "Removing DHCP Service Package..." $YELLOW
            progress_bar 10 $YELLOW &
            yum remove -y dhcp-server > /dev/null 2>&1
            wait
            show_message "-" "DHCP Service Package Removed Successfully." $GREEN
            echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sle3p 4.5
        fi
        
        show_title
        show_menu
    else
        show_message "X" "DHCP Service Is Not Installed, Cannot Remove.\n" $RED
    fi
}

update_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        local is_update_needed=$(yum check-update dhcp-server | grep -q 'dhcp-server' && echo 1 || echo 0)
        if [ $is_update_needed -eq 1 ]; then
            show_title
            echo ""
            show_message "!" "Updating DHCP Service Package (dhcp-server)..." $YELLOW
            progress_bar 10 $YELLOW &
            yum update -y dhcp-server > /dev/null 2>&1
            wait
            show_message "-" "DHCP Service Package Updated Successfully." $GREEN
            echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 3.5
            show_title
            show_menu
        else
            show_message "!" "DHCP Service Is Already Up To Date..\n" $GREEN
        fi
    else
        show_message "X" "DHCP Service Is Not Installed, Cannot Update.\n" $RED
    fi
}

show_menu() {
    echo ""
    echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Install DHCP"
    echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Remove DHCP"
    echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Update DHCP"
    echo -e " ${BLUE}[${DHCPCOLOR}4${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu()
{
    show_title
    show_menu
    while true; do
        echo -ne " ${BLUE}Enter An Option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                is_installed
                install_pkg
                ;;
            2)
                is_installed
                remove_pkg
                ;;
            3)
                is_installed
                update_pkg
                ;;
            4)
                break
                ;;
            *)
                echo -e " ${BLUE}[${RED}X${BLUE}]${RED} Invalid Option\n"
                ;;
        esac
    done
    clear
}

main() {
    menu
}

main
