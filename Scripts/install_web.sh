#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
PINK='\033[1;36m'
RED='\033[1;31m'
NOCOLOR='\033[0m'

show_title() {
    bash Utils/show_title.sh $PINK
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
    echo -e " ${BLUE}[${PINK}1${BLUE}]${NOCOLOR} Install WEB"
    echo -e " ${BLUE}[${PINK}2${BLUE}]${NOCOLOR} Uninstall WEB"
    echo -e " ${BLUE}[${PINK}3${BLUE}]${NOCOLOR} Update WEB"
    echo -e " ${BLUE}[${PINK}4${BLUE}]${NOCOLOR} Go To Menu"
    echo ""
    while true; do
        echo -e -n " ${BLUE}Enter An Option ${PINK}\$${BLUE}>:${NOCOLOR} "
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
