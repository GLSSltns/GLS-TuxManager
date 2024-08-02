#!/bin/bash

# COLORS: Define color codes for terminal output
MAIN_COLOR='\033[0;1;34;94m'
DHCPCOLOR='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;0;32;92m'
BLUE='\033[0;1;34;94m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

# UTILS: Source utility scripts for additional functionality
source Utils/progress_bar.sh
source Utils/show_message.sh
source Utils/validate_input_regex.sh

DEFAULT_DHCP_CONF="/etc/dhcp/dhcpd.conf"
DEFAULT_INTERFACE_CONF="/etc/sysconfig/dhcpd"

#FLAGS
dhcp_conf_changed=0
interface_conf_changed=0
is_interface_active=0

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

interface_state(){
    is_interface_active=$(nmcli con show "$interface" | grep -q GENERAL.STATE && echo 1 || echo 0)
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

write_config() {
    config_file=$1
    cat <<EOL | tee "$config_file" > /dev/null
subnet $subnet netmask $netmask {
    range $range;
    option routers $routers;
    option subnet-mask $netmask;
    option domain-name-servers $domain_name_servers;
    option domain-name "$domain_name";
    default-lease-time $default_lease_time;
    max-lease-time $max_lease_time;
}
EOL
}


configure_subnet() {
    while [ true ]; do
        echo -ne " Enter the subnet (${DHCPCOLOR}e.g., 192.168.1.0${NOCOLOR}): "
        read -r subnet
        if [ -z "$subnet" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$subnet" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid subnet format." $RED
        fi
    done
}

configure_netmask() {
    while [ true ]; do
        echo -ne " Enter the netmask (${DHCPCOLOR}e.g., 255.255.255.0${NOCOLOR}): "
        read -r netmask
        if [ -z "$netmask" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$netmask" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid netmask format." $RED
        fi
    done
}

configure_range() {
    while [ true ]; do
        echo -ne " Enter the range (${DHCPCOLOR}e.g., 192.168.1.100 192.168.1.200${NOCOLOR}): "
        read -r range
        if [ -z "$range" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$range" '^[0-9]{1,3}(\.[0-9]{1,3}){3} [0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid range format." $RED
        fi
    done
}

configure_routers() {
    while [ true ]; do
        echo -ne " Enter the routers (${DHCPCOLOR}e.g., 192.168.1.1${NOCOLOR}): "
        read -r routers
        if [ -z "$routers" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$routers" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid routers format." $RED
        fi
    done
}

configure_domain_name() {
    while [ true ]; do
        echo -ne " Enter the domain name (${DHCPCOLOR}e.g., example.com${NOCOLOR}): "
        read -r domain_name
        if [ -z "$domain_name" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$domain_name" '^[a-zA-Z0-9.-]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid domain name format." $RED
        fi
    done
}

configure_domain_name_servers() {
    while [ true ]; do
        echo -ne " Enter the domain name servers (${DHCPCOLOR}e.g., 8.8.8.8, 8.8.4.4${NOCOLOR}): "
        read -r domain_name_servers
        if [ -z "$domain_name_servers" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$domain_name_servers" '^[0-9]{1,3}(\.[0-9]{1,3}){3}(, [0-9]{1,3}(\.[0-9]{1,3}){3})*$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid domain name servers format." $RED
        fi
    done
}

configure_default_lease_time() {
    while [ true ]; do
        echo -ne " Enter the default lease time (${DHCPCOLOR}in seconds${NOCOLOR}): "
        read -r default_lease_time
        if [ -z "$default_lease_time" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$default_lease_time" '^[0-9]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid default lease time format." $RED
        fi
    done
}

configure_max_lease_time() {
    while [ true ]; do
        echo -ne " Enter the max lease time (${DHCPCOLOR}in seconds${NOCOLOR}): "
        read -r max_lease_time
        if [ -z "$max_lease_time" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$max_lease_time" '^[0-9]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid max lease time format." $RED
        fi
    done
}

save_configuration() {
    show_title
    echo ""
    show_message "!" "Saving DHCP configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_config "$DEFAULT_DHCP_CONF"
    read_config "$DEFAULT_DHCP_CONF"
    sleep 1
    wait
    show_message "-" "DHCP configuration saved successfully." $GREEN
    dhcp_conf_changed=0
    echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 3
}

show_dhcp_menu() {
    show_title
    echo -e "\t\t\t\t\t ${DHCPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Subnet: \t\t\t\t [${DHCPCOLOR}$subnet${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Netmask: \t\t\t\t [${DHCPCOLOR}$netmask${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Range: \t\t\t\t [${DHCPCOLOR}$range${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Routers: \t\t\t\t [${DHCPCOLOR}$routers${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Domain Name: \t\t\t [${DHCPCOLOR}$domain_name${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}6${MAIN_COLOR}]${NOCOLOR} Domain Name Servers: \t\t [${DHCPCOLOR}$domain_name_servers${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}7${MAIN_COLOR}]${NOCOLOR} Default Lease Time: \t\t [${DHCPCOLOR}$default_lease_time${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}8${MAIN_COLOR}]${NOCOLOR} Max Lease Time: \t\t\t [${DHCPCOLOR}$max_lease_time${NOCOLOR}]"
    echo ""
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}9${MAIN_COLOR}]${NOCOLOR} Save Configuration"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}10${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

dhcp_menu() {
    clear    
    show_dhcp_menu
    while [ true ]; do
        echo -ne " ${MAIN_COLOR}Enter an option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) 
                    configure_subnet
                    show_dhcp_menu
                    ;;
                2) 
                    configure_netmask
                    show_dhcp_menu
                    ;;
                3) 
                    configure_range
                    show_dhcp_menu
                    ;;
                4) 
                    configure_routers
                    show_dhcp_menu
                    ;;
                5) 
                    configure_domain_name
                    show_dhcp_menu
                    ;;
                6) 
                    configure_domain_name_servers
                    show_dhcp_menu
                    ;;
                7) 
                    configure_default_lease_time
                    show_dhcp_menu
                    ;;
                8) 
                    configure_max_lease_time
                    show_dhcp_menu
                    ;;
                9) 
                    clear
                    save_configuration 
                    show_dhcp_menu
                    ;;
                10) 
                    if [ $dhcp_conf_changed -eq 1 ]; then
                        show_message "!!" "You have unsaved changes." $YELLOW
                        echo -ne " Are you sure you want to QUIT? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
                        read -r confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            echo ""
                            show_message "!" "Quitting without saving." $YELLOW
                            dhcp_conf_changed=0
                            read_config "$DEFAULT_DHCP_CONF"
                            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
                            sleep 2
                            break
                        else
                            echo ""
                            sleep 1
                        fi
                    else
                        break
                    fi
                    ;;
                *) show_message "X" "Invalid option." $RED ;;
            esac
        fi
    done
    clear
}

configure_interface() {
    while [ true ]; do
        echo -ne " Enter the interface to listen on (${DHCPCOLOR}e.g., enp0s9${NOCOLOR}): "
        read -r interface
        if [ -z "$interface" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$interface" '^[a-zA-Z0-9]+$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid interface format." $RED
        fi
    done
}

configure_ip_prefix() {
    while [ true ]; do
        echo -ne " Enter the IP address and prefix (${DHCPCOLOR}e.g., 192.168.1.1/24${NOCOLOR}): "
        read -r ip_prefix
        if [ -z "$ip_prefix" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$ip_prefix" '^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]+$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid IP address and prefix format." $RED
        fi
    done
}

configure_gateway() {
    while [ true ]; do
        echo -ne " Enter the gateway (${DHCPCOLOR}e.g., 192.168.1.1${NOCOLOR}): "
        read -r gateway
        if [ -z "$gateway" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$gateway" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid gateway format." $RED
        fi
    done
}

configure_dns() {
    while [ true ]; do
        echo -ne " Enter the DNS server (${DHCPCOLOR}e.g., 8.8.8.8${NOCOLOR}): "
        read -r dns
        if [ -z "$dns" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input_regex "$dns" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid DNS server format." $RED
        fi
    done
}

toggle_interface() {
    interface_state 

    if [ $is_interface_active -eq 1 ]; then
        show_title
        echo ""
        show_message "!" "Shutting down interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con down "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now down." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        # is_interface_active=0
        sleep 3
    elif [ $is_interface_active -eq 0 ]; then
        show_title
        echo ""
        show_message "!" "Starting up interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now up." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}" 
        sleep 3
    else
        show_message "X" "Could not determine the state of $interface." $RED
        sleep 2
    fi
}

restart_interface() {
    interface_state

    if [ $is_interface_active -eq 1 ]; then
        show_title
        echo ""
        show_message "!" "Restarting interface $interface..." $YELLOW
        progress_bar 10 $YELLOW &
        nmcli con down "$interface" > /dev/null 2>&1
        sleep 2
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface has been restarted." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}" 
        sleep 3
    elif [ $is_interface_active -eq 0 ]; then
        show_title
        echo ""
        show_message "!" "The Interface is currently down." $YELLOW
        sleep 2
        echo ""
        show_message "!" "Starting up interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now up." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        sleep 3
    else
        show_message "X" "Could not determine the state of $interface." $RED
        sleep 2
    fi
}

read_interface_config() {
    interface_config_file=$1
    interface=$(grep -Po 'DHCPDARGS=\K[^;]*' "$interface_config_file")
    ip_prefix=$(nmcli con show "$interface" | grep ipv4.addresses | awk '{print $2}')
    gateway=$(nmcli con show "$interface" | grep ipv4.gateway | awk '{print $2}')  
    dns=$(nmcli con show "$interface" | grep ipv4.dns: | awk '{print $2}')
}

write_interface_config() {
    interface_config_file=$1
    cat <<EOL | tee "$interface_config_file" > /dev/null
# DHCPDARGS is defined by the dhcpd startup script
DHCPDARGS=$interface
EOL

    nmcli con mod "$interface" ipv4.addresses "$ip_prefix" ipv4.dns "$dns" ipv4.gateway "$gateway" ipv4.method manual
}
    
save_interface_configuration() {
    clear
    show_title
    echo ""
    show_message "!" "Saving interface configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_interface_config "$DEFAULT_INTERFACE_CONF"
    read_interface_config "$DEFAULT_INTERFACE_CONF"
    sleep 1
    wait
    show_message "-" "Interface configuration saved successfully." $GREEN
    interface_conf_changed=0
    echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 3
}

show_interface_menu() {
    show_title
    interface_state
    echo -e "\t\t\t\t\t ${DHCPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Interface: \t\t\t [${DHCPCOLOR}$interface${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} IP and Prefix: \t\t\t [${DHCPCOLOR}$ip_prefix${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Gateway: \t\t\t\t [${DHCPCOLOR}$gateway${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}4${MAIN_COLOR}]${NOCOLOR} DNS: \t\t\t\t [${DHCPCOLOR}$dns${NOCOLOR}]"
    if [ $is_interface_active -eq 1 ]; then
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Shut Down Interface"
    else
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Start Up Interface"
    fi
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}6${MAIN_COLOR}]${NOCOLOR} Restart Interface"
    echo ""
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}7${MAIN_COLOR}]${NOCOLOR} Save Configuration"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}8${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

interface_menu() {
    show_interface_menu
    while [ true ]; do
        interface_state
        echo -ne " ${MAIN_COLOR}Enter an option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) 
                    configure_interface
                    show_interface_menu
                    ;;
                2) 
                    configure_ip_prefix
                    show_interface_menu
                    ;;
                3) 
                    configure_gateway
                    show_interface_menu
                    ;;
                4) 
                    configure_dns
                    show_interface_menu
                    ;;
                5) 
                    toggle_interface
                    show_interface_menu 
                    ;;
                6) 
                    restart_interface
                    show_interface_menu
                    ;;
                7) 
                    clear
                    save_interface_configuration
                    show_interface_menu
                    ;;
                8)
                    if [ $interface_conf_changed -eq 1 ]; then
                        show_message "!!" "You have unsaved changes." $YELLOW
                        echo -ne " Are you sure you want to QUIT? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
                        read -r confirm
                        if [[ "$confirm" =~ ^[Yy]$ ]]; then
                            echo ""
                            show_message "!" "Quitting without saving." $YELLOW
                            interface_conf_changed=0
                            read_config "$DEFAULT_INTERFACE_CONF"
                            echo -e "${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
                            sleep 2
                            break
                        else
                            show_interface_menu
                            sleep 1
                        fi
                    else
                        break
                    fi
                    ;;
                *) show_message "X" "Invalid option." $RED ;;
            esac
        fi 
    done
    clear
}

main_menu() {
    while [ true ]; do
        show_title
        echo ""
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Configure DHCP"
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Configure Interface"
        echo ""
        echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Exit DHCP configuration"
        echo ""
        echo -ne " ${MAIN_COLOR}Enter an option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) dhcp_menu ;;
                2) interface_menu ;;
                3) break ;;
                *) show_message "X" "Invalid option." $RED ;;
            esac
        fi    
    done
}

read_config "$DEFAULT_DHCP_CONF"
read_interface_config "$DEFAULT_INTERFACE_CONF"
main_menu
