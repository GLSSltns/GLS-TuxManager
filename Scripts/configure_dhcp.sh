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

DHCPCOLOR='\033[1;33m'

DEFAULT_DHCP_CONF="/etc/dhcp/dhcpd.conf"
DEFAULT_INTERFACE_CONF="/etc/sysconfig/dhcpd"

dhcp_conf_changed=0
interface_conf_changed=0
INTACTIVE=0

# Utils
source Utils/progress_bar.sh

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

show_message() {
    local c=$1
    local message=$2
    local color=$3
    echo -e " ${BLUE}[${color}${c}${BLUE}]${color} ${message}${NOCOLOR}"
}

validate_input() {
    local input=$1
    local regex=$2
    if [[ $input =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}

interface_state(){
    INTACTIVE=$(nmcli con show "$interface" | grep -q GENERAL.STATE && echo 1 || echo 0)
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
        echo -ne "Enter the subnet (e.g., 192.168.1.0): "
        read -r subnet
        if [ -z "$subnet" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$subnet" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid subnet format." $RED
        fi
    done
}

configure_netmask() {
    while [ true ]; do
        echo -ne "Enter the netmask (e.g., 255.255.255.0): "
        read -r netmask
        if [ -z "$netmask" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$netmask" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid netmask format." $RED
        fi
    done
}

configure_range() {
    while [ true ]; do
        echo -ne "Enter the range (e.g., 192.168.1.100 192.168.1.200): "
        read -r range
        if [ -z "$range" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$range" '^[0-9]{1,3}(\.[0-9]{1,3}){3} [0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid range format." $RED
        fi
    done
}

configure_routers() {
    while [ true ]; do
        echo -ne "Enter the routers (e.g., 192.168.1.1): "
        read -r routers
        if [ -z "$routers" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$routers" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid routers format." $RED
        fi
    done
}

configure_domain_name() {
    while [ true ]; do
        echo -ne "Enter the domain name (e.g., example.com): "
        read -r domain_name
        if [ -z "$domain_name" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$domain_name" '^[a-zA-Z0-9.-]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid domain name format." $RED
        fi
    done
}

configure_domain_name_servers() {
    while [ true ]; do
        echo -ne "Enter the domain name servers (e.g., 8.8.8.8, 8.8.4.4): "
        read -r domain_name_servers
        if [ -z "$domain_name_servers" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$domain_name_servers" '^[0-9]{1,3}(\.[0-9]{1,3}){3}(, [0-9]{1,3}(\.[0-9]{1,3}){3})*$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid domain name servers format." $RED
        fi
    done
}

configure_default_lease_time() {
    while [ true ]; do
        echo -ne "Enter the default lease time (in seconds): "
        read -r default_lease_time
        if [ -z "$default_lease_time" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$default_lease_time" '^[0-9]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid default lease time format." $RED
        fi
    done
}

configure_max_lease_time() {
    while [ true ]; do
        echo -ne "Enter the max lease time (in seconds): "
        read -r max_lease_time
        if [ -z "$max_lease_time" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$max_lease_time" '^[0-9]+$'; then
            dhcp_conf_changed=1
            break
        else
            show_message "X" "Invalid max lease time format." $RED
        fi
    done
}

save_configuration() {
    show_title
    show_message "!" "Saving DHCP configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_config "$DEFAULT_DHCP_CONF"
    read_config "$DEFAULT_DHCP_CONF"
    wait
    show_message "-" "DHCP configuration saved successfully." $GREEN
    dhcp_conf_changed=0
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 4.5
}

show_dhcp_menu() {
    show_title
    echo -e "\t\t\t\t\t ${DHCPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Subnet: \t\t\t\t [${DHCPCOLOR}$subnet${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Netmask: \t\t\t\t [${DHCPCOLOR}$netmask${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Range: \t\t\t\t [${DHCPCOLOR}$range${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}4${BLUE}]${NOCOLOR} Routers: \t\t\t\t [${DHCPCOLOR}$routers${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}5${BLUE}]${NOCOLOR} Domain Name: \t\t\t [${DHCPCOLOR}$domain_name${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}6${BLUE}]${NOCOLOR} Domain Name Servers: \t\t [${DHCPCOLOR}$domain_name_servers${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}7${BLUE}]${NOCOLOR} Default Lease Time: \t\t [${DHCPCOLOR}$default_lease_time${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}8${BLUE}]${NOCOLOR} Max Lease Time: \t\t\t [${DHCPCOLOR}$max_lease_time${NOCOLOR}]"
    echo ""
    echo -e " ${BLUE}[${DHCPCOLOR}9${BLUE}]${NOCOLOR} Save Configuration"
    echo -e " ${BLUE}[${DHCPCOLOR}10${BLUE}]${NOCOLOR} Back to Main Menu"
    echo ""
}

dhcp_menu() {
    while [ true ]; do
        show_dhcp_menu
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) configure_subnet ;;
                2) configure_netmask ;;
                3) configure_range ;;
                4) configure_routers ;;
                5) configure_domain_name ;;
                6) configure_domain_name_servers ;;
                7) configure_default_lease_time ;;
                8) configure_max_lease_time ;;
                9) 
                    clear
                    save_configuration ;;
                10) 
                    if [ $dhcp_conf_changed -eq 1 ]; then
                        show_message "!!" "You have unsaved changes." $YELLOW
                        echo -ne " Are you sure you want to QUIT? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
                        read -r confirm
                        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                            echo ""
                            sleep 1
                        else
                            echo ""
                            show_message "!" "Quitting without saving." $YELLOW
                            dhcp_conf_changed=0
                            read_config "$DEFAULT_DHCP_CONF"
                            echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
                            sleep 2
                            break
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
        echo -ne "Enter the interface to listen on (e.g., enp0s9): "
        read -r interface
        if [ -z "$interface" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$interface" '^[a-zA-Z0-9]+$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid interface format." $RED
        fi
    done
}

configure_ip_prefix() {
    while [ true ]; do
        echo -ne "Enter the IP address and prefix (e.g., 192.168.1.1/24): "
        read -r ip_prefix
        if [ -z "$ip_prefix" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$ip_prefix" '^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]+$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid IP address and prefix format." $RED
        fi
    done
}

configure_gateway() {
    while [ true ]; do
        echo -ne "Enter the gateway (e.g., 192.168.1.1): "
        read -r gateway
        if [ -z "$gateway" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$gateway" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid gateway format." $RED
        fi
    done
}

configure_dns() {
    while [ true ]; do
        echo -ne "Enter the DNS server (e.g., 8.8.8.8): "
        read -r dns
        if [ -z "$dns" ]; then
            show_message "!" "Cancelled..." $YELLOW
            sleep 2.5
            break
        elif validate_input "$dns" '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
            interface_conf_changed=1
            break
        else
            show_message "X" "Invalid DNS server format." $RED
        fi
    done
}

toggle_interface() {
    interface_state 

    if [ $INTACTIVE -eq 1 ]; then
        show_message "!" "Shutting down interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con down "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now down." $GREEN
        # INTACTIVE=0
        sleep 3
    elif [ $INTACTIVE -eq 0 ]; then
        show_message "!" "Starting up interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now up." $GREEN
        # INTACTIVE=1
        sleep 3
    else
        show_message "X" "Could not determine the state of $interface." $RED
        sleep 2
    fi
}

restart_interface() {
    interface_state

    if [ $INTACTIVE -eq 1 ]; then
        show_message "!" "Restarting interface $interface..." $YELLOW
        progress_bar 10 $YELLOW &
        nmcli con down "$interface" > /dev/null 2>&1
        sleep 2
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface has been restarted." $GREEN
        # INTACTIVE=1
        sleep 3
    elif [ $INTACTIVE -eq 0 ]; then
        show_message "!" "The Interface is currently down." $YELLOW
        sleep 2
        show_message "!" "Starting up interface $interface..." $YELLOW
        progress_bar 7 $YELLOW &
        nmcli con up "$interface" > /dev/null 2>&1
        wait
        show_message "!" "Interface $interface is now up." $GREEN
        # INTACTIVE=1
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
    show_message "!" "Saving interface configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_interface_config "$DEFAULT_INTERFACE_CONF"
    read_interface_config "$DEFAULT_INTERFACE_CONF"
    wait
    show_message "-" "Interface configuration saved successfully." $GREEN
    interface_conf_changed=0
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 4.5
}

show_interface_menu() {
    show_title
    echo -e "\t\t\t\t\t ${DHCPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Interface: \t\t\t [${DHCPCOLOR}$interface${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} IP and Prefix: \t\t\t [${DHCPCOLOR}$ip_prefix${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Gateway: \t\t\t\t [${DHCPCOLOR}$gateway${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}4${BLUE}]${NOCOLOR} DNS: \t\t\t\t [${DHCPCOLOR}$dns${NOCOLOR}]"
    echo -e " ${BLUE}[${DHCPCOLOR}5${BLUE}]${NOCOLOR} Save Configuration"
    echo ""
    if [ $INTACTIVE -eq 1 ]; then
        echo -e " ${BLUE}[${DHCPCOLOR}6${BLUE}]${NOCOLOR} Shut Down Interface"
    else
        echo -e " ${BLUE}[${DHCPCOLOR}6${BLUE}]${NOCOLOR} Start Up Interface"
    fi
    echo -e " ${BLUE}[${DHCPCOLOR}7${BLUE}]${NOCOLOR} Restart Interface"
    echo -e " ${BLUE}[${DHCPCOLOR}8${BLUE}]${NOCOLOR} Back to Main Menu"
    echo ""
}

interface_menu() {
    while [ true ]; do
        interface_state
        show_interface_menu
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) configure_interface ;;
                2) configure_ip_prefix ;;
                3) configure_gateway ;;
                4) configure_dns ;;
                5) 
                    clear
                    save_interface_configuration 
                    ;;
                6) 
                    toggle_interface 
                    ;;
                7) 
                    restart_interface 
                    ;;
                8)
                    if [ $interface_conf_changed -eq 1 ]; then
                        show_message "!!" "You have unsaved changes." $YELLOW
                        echo -ne " Are you sure you want to QUIT? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
                        read -r confirm
                        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                            echo ""
                            sleep 1
                        else
                            echo ""
                            show_message "!" "Quitting without saving." $YELLOW
                            interface_conf_changed=0
                            read_config "$DEFAULT_INTERFACE_CONF"
                            echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
                            sleep 2
                            break
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
        echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Configure DHCP"
        echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Configure Interface"
        echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Exit"
        echo ""
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
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
