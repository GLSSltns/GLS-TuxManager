#!/bin/bash

source Utils/show_message.sh
source Utils/progress_bar.sh
source Utils/spinner.sh
source Utils/prompt_confirmation.sh

is_started=0

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

is_dhcp_started(){
    is_started=$(systemctl is-active dhcpd | grep -Po "^active" | grep -q ac && echo 1 || echo 0)
}

show_error_details() {
    error_log=$(journalctl -xeu dhcpd.service | tac)
    error_start=$(echo "$error_log" | grep -n "Wrote 0 leases to leases file\." | head -n 1 | cut -d: -f1)
    log_line=$(echo "$error_log" | grep "Wrote 0 leases to leases file\." | head -n 1)

    IFS=' ' read -r mont day time _ pid_part _ <<< "$log_line"

    if [ -n "$error_start" ]; then
        error_log=$(echo "$error_log" | head -n +$((error_start-1)) | tac)
    fi
    pid="$(echo "$pid_part" | grep -oP 'dhcpd\[\K[0-9]+(?=\])')"

    clear
    show_title
    echo ""
    show_message "X" "Failed to manage DHCP. Check details below." $RED

    echo ""
    echo -e " ${MAIN_COLOR}Date: ${NOCOLOR}$day $mont, $time"
    echo -e " ${MAIN_COLOR}PID: ${NOCOLOR}${pid}"
    echo -e " ${MAIN_COLOR}Details: ${NOCOLOR}\n"

    while IFS= read -r line; do
        out_line=$(echo "$line" | grep -oP '\]\s*\K.*')
        if [[ "$out_line" =~ [[:alnum:]] ]]; then
            echo -e " ${NOCOLOR}$out_line"
        fi
    done <<< "$error_log"

    echo "" 
    show_message "!" "Recommendation: Check if the interface is currently up." $BLUE
    show_message "!" "Recommendation: Check if the interface configuration." $BLUE
    show_message "!" "Recommendation: Check the DHCP configuration (subnet, routers, default_lease_time, etc.)." $BLUE
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

validate_start(){
    clear
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking for DHCP status...   " $YELLOW)"
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
                show_message "X" "Failed to start DHCP." $RED
                sleep 1
                show_error_details 
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
    clear
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking for DHCP status...   " $YELLOW)"
    show_message "!" "Done...\n" $GREEN
    sleep 3
    clear
    show_title
    is_dhcp_started
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "DHCP service is not running. Would you like to start it instead?" $YELLOW
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
        read -r -n 1 -s
        validate_start
    else
        if prompt_confirmation "Are you sure you want to restart the DHCP service?"; then
            echo ""
            show_message "!" "Restarting DHCP service..." $YELLOW
            systemctl restart dhcpd > /dev/null 2>&1
            progress_bar 5 $YELLOW
            is_dhcp_started
            sleep 2
            if [ $is_started -eq 1 ]; then
                show_message "-" "DHCP service restarted successfully." $GREEN
            else
                show_message "X" "Failed to resstart DHCP." $RED
                sleep 1
                show_error_details 
            fi
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
            read -r -n 1 -s
        else
            show_message "!" "DHCP service restart aborted." $YELLOW
            sleep 3
        fi
    fi
}

validate_stop(){
    clear
    show_title
    echo ""
    spinner 3 "$(show_message "!" "Checking for DHCP status...   " $YELLOW)"
    show_message "!" "Done...\n" $GREEN
    sleep 3
    clear
    show_title
    is_dhcp_started
    if [ $is_started -eq 0 ]; then
        echo ""
        show_message "!" "DHCP service is already stopped." $YELLOW
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
        read -r -n 1 -s
    else
        if prompt_confirmation "Are you sure you want to stop the DHCP service?"; then
            echo ""
            show_message "!" "Stopping DHCP service..." $YELLOW
            systemctl stop dhcpd > /dev/null 2>&1
            progress_bar 5 $YELLOW
            is_dhcp_started
            sleep 2
            if [ $is_started -eq 0 ]; then
                show_message "-" "DHCP service stopped successfully." $GREEN
            else
                show_message "X" "Failed to stop DHCP." $RED
                sleep 1
                show_error_details 
            fi
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
            read -r -n 1 -s
        else
            show_message "!" "DHCP service stop aborted." $YELLOW
            sleep 3
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
                show_message "X" "Invalid option." $RED 
                ;;
        esac
    done
}

main() {
    menu_dhcp
}

main
