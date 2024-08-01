#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
LIGHTBLUE='\033[36;40m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
GREEN2='\033[0;32m'
PINK='\033[1;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

# FLAGS
ISDHCP=0 # Check DHCP install
ISHTTP=0 # Check HTTP install

source Utils/show_message.sh

check_services_install() {
    ISDHCP=$(yum list installed | grep -q dhcp-server && echo 1 || echo 0)
    ISHTTP=$(yum list installed | grep -q httpd && echo 1 || echo 0)
}

check_and_continue() {
    local service_name=$1
    local is_installed=$2
    local script_path=$3

    if [ $is_installed -eq 0 ]; then
        show_message "X" "The $service_name Service Package Is Not Installed" $RED 
        show_message "!" "Install The Package Before Continue" $RED
    else
        bash $script_path
    fi
    show_menu_config
}

show_title() {
    bash Utils/show_title.sh $LIGHTBLUE 
}

display_not_installed_message() {
    local service=$1
    local flag=$2
    if [ $flag -eq 0 ]; then
        echo -ne "\t\t${NOCOLOR}[${RED}${service} is not installed${NOCOLOR}]"
    fi
}

show_menu() {
    show_title
    echo -e " \n ${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} Service Installation\t\t${BLUE}[${LIGHTBLUE}5${BLUE}]${NOCOLOR} Info"
    echo -e " ${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} Service Configuration\t\t${BLUE}[${LIGHTBLUE}6${BLUE}]${NOCOLOR} Quit"
    echo -e " ${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Service Management"
    echo -e " ${BLUE}[${LIGHTBLUE}4${BLUE}]${NOCOLOR} Service Monitoring"
    echo ""
}

show_info() {
    show_title
    echo -e "${YELLOW}"
    echo -e '  / ` /  /_`__ /_` _  /   _/_ . _  _   _'
    echo -ne ' /_; /_,._/   ._/ /_// /_//  / /_// /_\ ' 
    echo -e "${BLUE} <\\"
    echo -e "${BLUE} <_______________________________________[]${YELLOW}#######${BLUE}]"
    echo -e '                                         </'
    echo -e " ${BLUE}AUTHORS:"	
    echo -e " ${BLUE}@ Gael Landa ${NOCOLOR}\t\thttps://github.com/GsusLnd"
    echo -e " ${BLUE}@ Leonardo Aceves ${NOCOLOR}\thttps://github.com/L30AM"
    echo -e " ${BLUE}@ Sergio Méndez ${NOCOLOR}\thttps://github.com/sergiomndz15"
    echo -e " ${BLUE}@ Alexandra Gonzáles ${NOCOLOR}\thttps://github.com/AlexMangle"
    echo -ne " \n Press ${BLUE}[${LIGHTBLUE}ENTER${BLUE}]${NOCOLOR} To Continue..."
    read -s
    echo ""
    clear
}

# MENU: INSTALL
show_menu_install() {
    clear
    show_title
    echo ""
    echo -e " ${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} Install DHCP Service"
    echo -e " ${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} Install WEB Service"
    echo -e " ${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_install() {
    show_menu_install
    while true; do
        echo -ne " ${BLUE}Enter An Option ${LIGHTBLUE}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                bash Scripts/install_dhcp.sh
                show_menu_install
                ;;
            2)
                bash Scripts/install_web.sh
                show_menu_install
                ;;
            3)
                clear
                break
                ;;
            *)
                show_message "X" "Invalid Option" $RED
                ;;
        esac
    done
}

# MENU: CONFIGURE
show_menu_config() {
    clear
    show_title

    echo -ne "\n ${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} Configure DHCP Service"
    display_not_installed_message "DHCP" $ISDHCP
    echo -ne "\n ${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} Configure WEB Service"
    display_not_installed_message "WEB (HTTP)" $ISHTTP
    echo -e "\n ${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_config() {
    show_menu_config
    while true; do
        echo -ne " ${BLUE}Enter An Option ${LIGHTBLUE}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                check_and_continue "DHCP" $ISDHCP "Scripts/configure_dhcp.sh"
                ;;
            2)
                check_and_continue "WEB" $ISHTTP "Scripts/configure_web.sh"
                ;;
            3)
                clear
                break
                ;;
            *)
                show_message "X" "Invalid Option" $RED
                ;;
        esac
    done
}

# MENU: MANAGE
show_menu_manage() {
    clear
    show_title

    echo -ne "\n ${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} Manage DHCP Service"
    display_not_installed_message "DHCP" $ISDHCP
    echo -ne "\n ${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} Manage WEB Service"
    display_not_installed_message "WEB (HTTP)" $ISHTTP
    echo -e "\n ${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_manage() {
    show_menu_manage
    while true; do
        echo -ne " ${BLUE}Enter An Option ${LIGHTBLUE}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                bash Scripts/manage_dhcp.sh
                show_menu_manage
                ;;
            2)
                bash Scripts/manage_web.sh
                show_menu_manage
                ;;
            3)
                clear
                break
                ;;
            *)
                show_message "X" "Invalid Option" $RED
                ;;
        esac
    done
}

# MENU: STATUS
show_menu_status() {
    clear
    show_title

    echo -ne "\n ${BLUE}[${LIGHTBLUE}1${BLUE}]${NOCOLOR} DHCP Service Status"
    display_not_installed_message "DHCP" $ISDHCP
    echo -ne "\n ${BLUE}[${LIGHTBLUE}2${BLUE}]${NOCOLOR} WEB Service Status"
    display_not_installed_message "WEB (HTTP)" $ISHTTP
    echo -e "\n ${BLUE}[${LIGHTBLUE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_status() {
    show_menu_status
    while true; do
        echo -ne " ${BLUE}Enter An Option ${LIGHTBLUE}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                bash Scripts/status_dhcp.sh
                show_menu_status
                ;;
            2)
                bash Scripts/status_web.sh
                show_menu_status
                ;;
            3)
                clear
                break
                ;;
            *)
                show_message "X" "Invalid Option" $RED
                ;;
        esac
    done
}

# MENU: MAIN
main_menu() {
	clear
    check_services_install 
    show_menu
    while true; do
        echo -ne " ${BLUE}Enter An Option ${LIGHTBLUE}\$${BLUE}>: ${NOCOLOR}"
        read -r op
        case $op in 
            1)
                clear
                menu_install
                show_menu
                check_services_install
                ;;
            2)
                clear
                menu_config
                show_menu
                ;;
            3)
                clear
                menu_manage
                show_menu
                ;;
            4)
                clear
                menu_status
                show_menu
                ;;
            5)
                clear
                show_info
                show_menu
                ;;
            6)
                break
                ;;
            *)
                show_message "X" "Invalid Option" $RED
                ;;
        esac
    done
}

main() 
{
    if [ $UID != 0 ]; then
        show_message "X" "TuxManager must be run as ROOT.\n" $RED
        exit 1
    fi

    main_menu
}

main