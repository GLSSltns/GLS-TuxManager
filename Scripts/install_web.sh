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

HTTPCOLOR='\033[0;35m'

ISINSTALLED=0

show_title() {
    clear
    bash Utils/show_title.sh $HTTPCOLOR
}

display_not_installed_message() {
    local service=$1
    local flag=$2
    if [ $flag -eq 0 ]; then
        echo -ne "\t\t${NOCOLOR}[${RED}${service} is not installed${NOCOLOR}]"
    fi
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
    ISINSTALLED=$(yum list installed | grep -q httpd && echo 1 || echo 0)
}

install_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        show_message "!" "WEB (HTTP) Service Is Already Installed.\n" $YELLOW
    else
        show_title
        show_message "!" 'Installing WEB (HTTP)...' $YELLOW
        progress_bar 10 $YELLOW &
        yum install -y httpd > /dev/null 2>&1
        wait
        show_message "-" "WEB Service Installed Successfully." $GREEN
        echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
        sleep 4.5
        show_title
        show_menu
    fi
}

remove_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        show_title

        show_message "!?" "The WEB Service Package (httpd) Will Be REMOVED!!" $RED
        echo -ne " Is It Okay? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
        read -r confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            show_message "!" "Removal canceled." $YELLOW
            echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 2
        else
            echo ""
            sleep 2
            show_message "!" "Removing WEB (HTTP) Service..." $YELLOW
            progress_bar 10 $YELLOW &
            yum remove -y httpd > /dev/null 2>&1
            wait
            show_message "-" "WEB Service Removed Successfully." $GREEN
            echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 4.5
        fi
        
        show_title
        show_menu
    else
        show_message "X" "WEB (HTTP) Service Is Not Installed, Cannot Remove.\n" $RED
    fi
}

update_pkg() {
    if [ $ISINSTALLED -eq 1 ]; then
        local is_update_needed=$(yum check-update httpd | grep -q 'httpd' && echo 1 || echo 0)
        if [ $is_update_needed -eq 1 ]; then
            show_title
            show_message "!" "Updating WEB (HTTP) Service..." $YELLOW
            progress_bar 10 $YELLOW &
            yum update -y httpd > /dev/null 2>&1
            wait
            show_message "-" "WEB Service Updated Successfully." $GREEN
            echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 4.5
            show_title
            show_menu
        else
            show_message "!" "WEB (HTTP) Service Is Already Up To Date..\n" $GREEN
        fi
    else
        show_message "X" "WEB (HTTP) Service Is Not Installed, Cannot Update.\n" $RED
    fi
}

show_menu() {
    echo ""
    echo -e " ${BLUE}[${HTTPCOLOR}1${BLUE}]${NOCOLOR} Install WEB"
    echo -e " ${BLUE}[${HTTPCOLOR}2${BLUE}]${NOCOLOR} Remove WEB"
    echo -e " ${BLUE}[${HTTPCOLOR}3${BLUE}]${NOCOLOR} Update WEB"
    echo -e " ${BLUE}[${HTTPCOLOR}4${BLUE}]${NOCOLOR} Go Back"
    echo ""
}

menu()
{
    show_title
    show_menu
    while true; do
        echo -ne " ${BLUE}Enter An Option ${HTTPCOLOR}\$${BLUE}>:${NOCOLOR} "
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
