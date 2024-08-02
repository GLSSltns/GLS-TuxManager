#!/bin/bash

# COLORS
MAIN_COLOR='\033[0;1;34;94m'
HTTPCOLOR='\033[1;35m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

# UTILS
source Utils/progress_bar.sh
source Utils/show_message.sh

# FLAGS 
is_web_installed=0

show_title() {
    clear
    bash Utils/show_title.sh $HTTPCOLOR
}

is_installed() {
    is_web_installed=$(yum list installed | grep -q httpd && echo 1 || echo 0)
}

install_pkg() {
    if [ $is_web_installed -eq 1 ]; then
        show_message "!" "HTTP Service Is Already Installed.\n" $YELLOW
    else
        show_title
        echo ""
        show_message "!" 'Downloading HTTP Package (httpd)...' $YELLOW
        sleep 1
        progress_bar 10 $YELLOW &
        yum install -y httpd > /dev/null 2>&1
        wait
        sleep 1
        show_message "-" "HTTP Service Installed Successfully." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        sleep 3.5
        show_title
        show_menu
    fi
}

remove_pkg() {
    if [ $is_web_installed -eq 1 ]; then
        show_title
        echo ""
        show_message "!?" "The HTTP Service Package (httpd) Will Be REMOVED!!" $RED
        echo -ne " Is It Okay? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            sleep 1
            show_message "!" "Removal canceled." $YELLOW
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 2
        else
            echo ""
            sleep 2
            show_message "!" "Removing HTTP Service Package..." $YELLOW
            progress_bar 10 $YELLOW &
            yum remove -y httpd > /dev/null 2>&1
            wait
            show_message "-" "HTTP Service Package Removed Successfully." $GREEN
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 4.5
        fi
        
        show_title
        show_menu
    else
        show_message "X" "HTTP Service Is Not Installed, Cannot Remove.\n" $RED
    fi
}

update_pkg() {
    if [ $is_web_installed -eq 1 ]; then
        local is_update_needed=$(yum check-update httpd | grep -q 'httpd' && echo 1 || echo 0)
        if [ $is_update_needed -eq 1 ]; then
            show_title
            echo ""
            show_message "!" "Updating HTTP Service Package (httpd)..." $YELLOW
            progress_bar 10 $YELLOW &
            yum update -y httpd > /dev/null 2>&1
            wait
            show_message "-" "HTTP Service Package Updated Successfully." $GREEN
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 3.5
            show_title
            show_menu
        else
            show_message "!" "HTTP Service Is Already Up To Date..\n" $GREEN
        fi
    else
        show_message "X" "HTTP Service Is Not Installed, Cannot Update.\n" $RED
    fi
}

show_menu() {
    echo ""
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Install WEB"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Remove WEB"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Update WEB"
    echo -e " ${MAIN_COLOR}[${HTTPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu()
{
    show_title
    show_menu
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${YELLOW}\$${MAIN_COLOR}>:${NOCOLOR} "
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
                echo -e " ${MAIN_COLOR}[${RED}X${MAIN_COLOR}]${RED} Invalid Option\n"
                ;;
        esac
    done
    clear
}

main() {
    menu
}

main
