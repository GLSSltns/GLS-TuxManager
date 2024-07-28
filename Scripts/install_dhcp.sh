#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;1;33;93m'
RED='\033[1;31m'
NOCOLOR='\033[0m'

show_title() {
    bash Utils/show_title.sh $YELLOW
}

progress_bar() {
    echo "Progress bar functionality"
}

is_installed() {
    echo "Check if package is installed functionality"
}

update_pkg() {
    echo "Update package functionality"
}

show_menu() {
    clear
    show_title
    echo ""
    echo -e " ${BLUE}[${YELLOW}1${BLUE}]${NOCOLOR} Install DHCP"
    echo -e " ${BLUE}[${YELLOW}2${BLUE}]${NOCOLOR} Uninstall DHCP"
    echo -e " ${BLUE}[${YELLOW}3${BLUE}]${NOCOLOR} Update DHCP"
    echo -e " ${BLUE}[${YELLOW}4${BLUE}]${NOCOLOR} Go To Menu"
    echo ""
    while true; do
        echo -e -n " ${BLUE}Enter An Option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                echo "Installing"
                ;;
            2)
                echo "Uninstalling"
                ;;
            3)
                echo "Updating"
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
    show_menu
}

main
