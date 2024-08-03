#!/bin/bash

export TERM=linux
color_count=$(tput colors)

if [ $color_count -eq 8 ]; then
    export MAIN_COLOR='\033[0;1;34;94m'
    export TUXCOLOR="$(tput setaf 3)"
    export HTTPCOLOR="$(tput setaf 5)"
    export DHCPCOLOR='\033[1;33m'
    export LIGHTBLUE="$(tput setaf 6)"
    export BLUE="$(tput setaf 4)"
    export RED="$(tput setaf 1)"
    export GREEN="$(tput setaf 2)"
    export YELLOW='\033[1;33m'
    export WHITE="$(tput setaf 7)"
    export NOCOLOR="$(tput sgr0)"
    
else
    export MAIN_COLOR="$(tput setaf 26)"
    export TUXCOLOR="$(tput setaf 172)"
    export HTTPCOLOR="$(tput setaf 162)"
    export DHCPCOLOR="$(tput setaf 221)"
    export LIGHTBLUE="$(tput setaf 39)"
    export BLUE="$(tput setaf 4)"
    export RED="$(tput setaf 160)"
    export GREEN="$(tput setaf 40)"
    export YELLOW="$(tput setaf 220)"
    export WHITE="$(tput setaf 255)"
    export NOCOLOR="$(tput sgr0)"
fi

source Utils/show_message.sh
source Utils/spinner.sh
source Utils/byebye_message.sh

# FLAGS
is_dhcp=0 # Check DHCP install
is_http=0 # Check HTTP install


# Function to display spinner while a command runs
spinner() {
    local msg="$1"
    spin[0]="-"
    spin[1]="\\"
    spin[2]="|"
    spin[3]="/"
  
    echo -n "${msg} ${spin[0]}"
    while true; do
        for i in "${spin[@]}"; do
        echo -ne "\b\b\b[$i]"
        sleep 0.1
        done
    done
}

check_services_install() {
    # Start the spinner in the background
    stty -echo
    stty igncr
    spinner "$(show_message "!" "Checking Packages...  " $YELLOW)" &
    spinner_pid=$!

    # Check for installed packages
    yum list installed | grep -q dhcp-server && is_dhcp=1
    yum list installed | grep -q httpd && is_http=1

    # Stop the spinner
    kill $spinner_pid 
    sleep 1
    clear

    show_menu
    echo -ne "\r$(show_message "!" "Done..." $GREEN)"
    stty echo
    stty -igncr
    echo -ne "\r"
}

check_and_continue() {
    local service_name=$1
    local is_installed=$2
    local script_path=$3
    local menu_function=$4

    if [ $is_installed -eq 0 ]; then
        echo ""
        show_message "X" "The $service_name Service Package Is Not Installed" $RED 
        show_message "!" "Install The Package Before Continuing" $RED
        echo ""
    else
        bash $script_path
        clear
        $menu_function  
    fi
}

display_not_installed_message() {
    local service=$1
    local flag=$2
    if [ $flag -eq 0 ]; then
        echo -ne "\t\t${NOCOLOR}[${RED}${service} is not installed${NOCOLOR}]"
    fi
}

show_title() {
    bash Utils/show_title.sh "${TUXCOLOR}"
}


show_menu() {
    show_title
    echo -e " \n ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} Service Installation\t\t${MAIN_COLOR}[${TUXCOLOR}5${MAIN_COLOR}]${NOCOLOR} Info"
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} Service Configuration\t\t${MAIN_COLOR}[${TUXCOLOR}6${MAIN_COLOR}]${NOCOLOR} Quit"
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Service Management"
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}4${MAIN_COLOR}]${NOCOLOR} Service Monitoring"
    echo ""
}

show_info() {
    show_title
    echo -e "${YELLOW}"
    echo -e '  / ` /  /_`__ /_` _  /   _/_ . _  _   _'
    echo -ne ' /_; /_,._/   ._/ /_// /_//  / /_// /_\ ' 
    echo -e "${MAIN_COLOR} <\\"
    echo -e "${MAIN_COLOR} <_______________________________________[]${YELLOW}#######${MAIN_COLOR}]"
    echo -e '                                         </'
    echo -e " ${MAIN_COLOR}AUTHORS:"	
    echo -e " ${MAIN_COLOR}@ Gael Landa ${NOCOLOR}\t\thttps://github.com/GsusLnd"
    echo -e " ${MAIN_COLOR}@ Leonardo Aceves ${NOCOLOR}\thttps://github.com/L30AM"
    echo -e " ${MAIN_COLOR}@ Sergio Méndez ${NOCOLOR}\thttps://github.com/sergiomndz15"
    echo -e " ${MAIN_COLOR}@ Alexandra Gonzáles ${NOCOLOR}\thttps://github.com/AlexMangle"
    echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    echo -ne " ${MAIN_COLOR}Press [${TUXCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
    read -r -n 1 -s
    clear
}

# MENU: INSTALL
show_menu_install() {
    clear
    show_title
    echo ""
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} Install DHCP Service"
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} Install WEB Service"
    echo -e " ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_install() {
    show_menu_install
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
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
    show_title

    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} Configure DHCP Service"
    display_not_installed_message "DHCP" $is_dhcp
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} Configure WEB Service"
    display_not_installed_message "WEB (HTTP)" $is_http
    echo -e "\n\n ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_config() {
    show_menu_config
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                check_and_continue "DHCP" $is_dhcp "Scripts/configure_dhcp.sh" "show_menu_config"
                ;;
            2)
                check_and_continue "WEB" $is_http "Scripts/configure_web.sh" "show_menu_config"
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
    show_title

    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} Manage DHCP Service"
    display_not_installed_message "DHCP" $is_dhcp
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} Manage WEB Service"
    display_not_installed_message "WEB (HTTP)" $is_http
    echo -e "\n\n ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_manage() {
    show_menu_manage
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                check_and_continue "DHCP" $is_dhcp "Scripts/manage_dhcp.sh" "show_menu_manage"
                ;;
            2)
                check_and_continue "WEB" $is_http "Scripts/manage_web.sh" "show_menu_manage"
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
    show_title

    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}1${MAIN_COLOR}]${NOCOLOR} DHCP Service Status"
    display_not_installed_message "DHCP" $is_dhcp
    echo -ne "\n ${MAIN_COLOR}[${TUXCOLOR}2${MAIN_COLOR}]${NOCOLOR} WEB Service Status"
    display_not_installed_message "WEB (HTTP)" $is_http
    echo -e "\n\n ${MAIN_COLOR}[${TUXCOLOR}3${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_status() {
    show_menu_status
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                check_and_continue "DHCP" $is_dhcp "Scripts/status_dhcp.sh" "show_menu_status"
                ;;
            2)
                check_and_continue "WEB" $is_http "Scripts/status_web.sh" "show_menu_status"
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
    show_menu
    check_services_install 
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${TUXCOLOR}\$${MAIN_COLOR}>: ${NOCOLOR}"
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
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
        fi
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