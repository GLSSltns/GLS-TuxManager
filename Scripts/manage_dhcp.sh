#!/bin/bash

# COLORS
MAIN_COLOR="$(tput setaf 26)"
TUXCOLOR="$(tput setaf 172)"
DHCPCOLOR="$(tput setaf 221)"
LIGHTBLUE="$(tput setaf 39)"
BLUE="$(tput setaf 4)"
RED="$(tput setaf 160)"
GREEN="$(tput setaf 40)"
YELLOW="$(tput setaf 220)"
WHITE="$(tput setaf 255)"
NOCOLOR="$(tput sgr0)"

source Utils/show_message.sh
source Utils/progress_bar.sh
source Utils/spinner.sh

is_started=0

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

is_dhcp_started(){
    is_started=$(systemctl is-active dhcpd | grep -Po "^active" | grep -q ac && echo 1 || echo 0)
}

show_error_details() {
    error_details=$1
    echo -e "${RED}Error:${NOCOLOR}"
    echo -e "${YELLOW}Details:${NOCOLOR}"
    echo -e "${WHITE}$error_details${NOCOLOR}"
}

read_config() {
    config_file=$1
    subnet=$(grep -Po 'subnet \K[\d.]+' "$config_file")
    netmask=$(grep -Po 'netmask \K[\d.]+' "$config_file")
    range=$(grep -Po 'range \K[\d. ]+' "$config_file")
    routers=$(grep -Po 'option routers \K[\d.]+' "$config_file")
    domain_name=$(grep -Po 'option domain-name "\K[^"]+' "$config_file")
    domain_name_servers=$(grep -Po 'option domain-name-servers \K[\d., ]+' "$config_file")
    default_lease_time=$(grep -Po 'default-lease-time \K\d+' "$config_file")
    max_lease_time=$(grep -Po 'max-lease-time \K\d+' "$config_file")
}

read_interface_config() {
    interface_config_file=$1
    interface=$(grep -Po 'DHCPDARGS=\K[^;]*' "$interface_config_file")
    ip_prefix=$(nmcli con show "$interface" | grep ipv4.addresses | awk '{print $2}')
    gateway=$(nmcli con show "$interface" | grep ipv4.gateway | awk '{print $2}')  
    dns=$(nmcli con show "$interface" | grep ipv4.dns: | awk '{print $2}')
}

show_dhcp_config() {
    read_config /etc/dhcp/dhcpd.conf
    read_interface_config /etc/sysconfig/dhcpd
    echo -e " ${YELLOW}Current DHCP Configuration:${NOCOLOR}"
    echo ""
    echo -e " ${YELLOW}Interface configuration: "
    echo -e " ${MAIN_COLOR}Interface: ${NOCOLOR}$interface"
    echo -e " ${MAIN_COLOR}IP Prefix: ${NOCOLOR}$ip_prefix"
    echo -e " ${MAIN_COLOR}Gateway: ${NOCOLOR}$gateway"
    echo -e " ${MAIN_COLOR}DNS: ${NOCOLOR}$dns"

    echo -e "\n${YELLOW} DHCP configuration: "
    echo -e " ${MAIN_COLOR}Subnet: ${NOCOLOR}$subnet"
    echo -e " ${MAIN_COLOR}Netmask: ${NOCOLOR}$netmask"
    echo -e " ${MAIN_COLOR}Range: ${NOCOLOR}$range"
    echo -e " ${MAIN_COLOR}Routers: ${NOCOLOR}$routers"
    echo -e " ${MAIN_COLOR}Domain Name: ${NOCOLOR}$domain_name"
    echo -e " ${MAIN_COLOR}Domain Name Servers: ${NOCOLOR}$domain_name_servers"
    echo -e " ${MAIN_COLOR}Default Lease Time: ${NOCOLOR}$default_lease_time"
    echo -e " ${MAIN_COLOR}Max Lease Time: ${NOCOLOR}$max_lease_time${NOCOLOR}"
}

prompt_confirmation() {
    prompt_message=$1
    while true; do
        echo ""
        echo -ne "${WHITE} $prompt_message [${GREEN}Y${WHITE}/${RED}n${NOCOLOR}]: "
        read -r yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) show_message "X" "Prease answer yes (Y) or no (n)." $RED ;;
        esac
    done
}

validate_start(){
    clear
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking for DHCP status..." $YELLOW)"
    show_message "!" "Done...\n" $GREEN
    sleep 3
    clear
    show_title
    is_dhcp_started
    if [ $is_started -eq 1 ]; then
        echo ""
        show_message "!" "DHCP is already running." $YELLOW
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
        read -r -n 1 -s
    else
        show_dhcp_config
        if prompt_confirmation "Are you sure you want to start the DHCP service with this configuration?"; then
            echo ""
            show_message "!" "Starting DHCP service..." $YELLOW
            systemctl start dhcpd > /dev/null 2>&1
            progress_bar 5 $YELLOW
            is_dhcp_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "DHCP service started successfully." $GREEN
            else
                error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
                show_message "X" "Failed to start DHCP. Check details below." $RED
                show_error_details "$error_log"
            fi
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
            read -r -n 1 -s
        else
            show_message "!" "DHCP service start aborted." $YELLOW
            sleep 3
        fi
    fi
}

validate_restart(){
    show_title
    is_dhcp_started
    if [ $is_started -eq 0 ]; then
        show_message $RED "DHCP service is not running. Would you like to start it instead?"
        if prompt_confirmation "Start DHCP service?"; then
            validate_start
        else
            show_message $YELLOW "DHCP service restart aborted by user."
        fi
    else
        systemctl restart dhcpd > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            show_message $GREEN "DHCP service restarted successfully."
        else
            error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
            show_message $RED "Failed to restart DHCP. Check details below."
            show_error_details "$error_log"
        fi
    fi
}

validate_stop(){
    show_title
    is_dhcp_started
    if [ $is_started -eq 0 ]; then
        show_message $RED "DHCP service is already stopped."
    else
        if prompt_confirmation "Are you sure you want to stop the DHCP service?"; then
            systemctl stop dhcpd > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                show_message $GREEN "DHCP service stopped successfully."
            else
                error_log=$(journalctl -xeu dhcpd.service | tail -n 10)
                show_message $RED "Failed to stop DHCP. Check details below."
                show_error_details "$error_log"
            fi
        else
            show_message $YELLOW "DHCP service stop aborted by user."
        fi
    fi
}

menu_dhcp_man() {
    show_title $DHCPCOLOR
    echo -ne "\n ${MAIN_COLOR}[${LIGHTBLUE}1${MAIN_COLOR}]${NOCOLOR} Start DHCP service"
    echo -ne "\n ${MAIN_COLOR}[${LIGHTBLUE}2${MAIN_COLOR}]${NOCOLOR} Restart DHCP service"
    echo -ne "\n ${MAIN_COLOR}[${LIGHTBLUE}3${MAIN_COLOR}]${NOCOLOR} Stop DHCP service"
    echo -e "\n ${MAIN_COLOR}[${LIGHTBLUE}4${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

menu_dhcp() {
    menu_dhcp_man
    while true; do
        echo -ne "${MAIN_COLOR} Enter An Option${LIGHTBLUE}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        case $op in
            1)
                # DHCP start
                validate_start
                menu_dhcp_man
                ;;
            2)
                # DHCP restart
                validate_restart
                menu_dhcp_man
                ;;
            3)
                # DHCP stop
                validate_stop
                menu_dhcp_man
                ;;
            4)
                # Go back to main menu
                break
                ;;
            *)
                # Invalid option
                show_message $RED "Invalid option. Please enter a number between 1 and 4."
                ;;
        esac
    done
}

main() {
    menu_dhcp
}

main
