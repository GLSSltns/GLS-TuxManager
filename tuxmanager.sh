#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[1;31m'
GREEN='\033[0;1;32;92m'
GREEN2='\033[0;32;40m'
PINK='\033[1;36;40m'
YELLOW='\033[0;33;40m'
WHITE='\033[1;37;40m'
NOCOLOR='\033[0m'

# FLAGS 
ISDHCP=0 # Check DHCP install
ISHTTP=0 # Check HTTP install

check_services_install() {
    ISDHCP=$(yum list installed | grep -q dhcp-server && echo 1 || echo 0)
    ISHTTP=$(yum list installed | grep -q httpd && echo 1 || echo 0)
}

show_title() {
    bash Utils/show_title.sh $ORANGE
}

show_menu() {
    show_title
    echo -e " \n ${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Services Installation\t\t${BLUE}[${ORANGE}5${BLUE}]${NOCOLOR} Info"
    echo -e " ${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Services Configuration\t\t${BLUE}[${ORANGE}6${NOCOLOR}${BLUE}]${NOCOLOR} Quit"
    echo -e " ${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Services Management"
    echo -e " ${BLUE}[${ORANGE}4${BLUE}]${NOCOLOR} Services Status"
    echo ""
}

show_info() {
    show_title
    echo -e "${ORANGE}"
    echo -e '  / ` /  /_`__ /_` _  /   _/_ . _  _   _'
    echo -n -e ' /_; /_,._/   ._/ /_// /_//  / /_// /_\ ' 
    echo -e "${BLUE} <\\"
    echo -e "${BLUE} <_______________________________________[]${ORANGE}#######${BLUE}]"
    echo -e '                                         </'
    echo -e " ${BLUE}AUTHORS:"
    echo -e " ${BLUE}@ Gael Landa ${NOCOLOR}\t\thttps://github.com/GsusLnd"
    echo -e " ${BLUE}@ Leonardo Aceves ${NOCOLOR}\thttps://github.com/L30AM"
    echo -e " ${BLUE}@ Sergio Méndez ${NOCOLOR}\thttps://github.com/sergiomndz15"
    echo -e " ${BLUE}@ Alexandra Gonzáles ${NOCOLOR}\thttps://github.com/AlexMangle"
    echo -e -n " \n ${BLUE}[${ORANGE}ENTER${BLUE}]${NOCOLOR} Go Back"
    read -s
    echo ""
    clear
}

show_menu_install() {
    clear
    show_title
    echo ""
    echo -e " ${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Install DHCP Service"
    echo -e " ${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Install WEB Service"
    echo -e " ${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_install() {
    show_menu_install
    while true; do
        echo -e -n " ${BLUE}Enter An Option ${ORANGE}\$${BLUE}>:${NOCOLOR} "
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
                echo -e " ${BLUE}[${RED}X${BLUE}]${RED} Invalid Option\n"
                ;;
        esac
    done
}

show_menu_config() {
    clear
    show_title

    echo -e -n "\n ${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Configure DHCP Service"
    if [ $ISDHCP -eq 0 ]; then
        echo -n -e "\t\t${NOCOLOR}[${RED}DHCP is not installed${NOCOLOR}]"
    fi
    echo -e -n "\n ${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Configure WEB Service"
    if [ $ISHTTP -eq 0 ]; then
        echo -n -e "\t\t${NOCOLOR}[${RED}WEB (HTTP) is not installed${NOCOLOR}]"
    fi
    echo -e "\n ${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu_config() {
    show_menu_config
    while true; do
        echo -e -n " ${BLUE}Enter An Option ${ORANGE}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                bash Scripts/configure_dhcp.sh
                show_menu_config
                ;;
            2)
                bash Scripts/configure_web.sh
                show_menu_config
                ;;
            3)
                clear
                break
                ;;
            *)
                echo -e " ${BLUE}[${RED}X${BLUE}]${RED} Invalid Option\n"
                ;;
        esac
    done
}

main() {
    check_services_install
    show_menu
    while true; do
        echo -e -n " ${BLUE}Enter An Option ${ORANGE}\$${BLUE}>: ${NOCOLOR}"
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
                echo "Management"
                ;;
            4)
                echo "Status"
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
                echo -e " ${BLUE}[${RED}X${BLUE}]${RED} Invalid Option\n"
                ;;
        esac
    done
}

main
