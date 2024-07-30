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

progress_bar() {
    local duration=$1
    local steps=10
    local interval=$((duration / steps))

    local color=$2
    for ((i = 0; i <= steps; i++)); do
        echo -ne "${BLUE} ["
        for ((j = 0; j < i; j++)); do echo -ne "${color}###"; done
        for ((j = i; j < steps; j++)); do echo -ne "${NOCOLOR}..."; done
        echo -ne "${BLUE}] ${color}$((i * 10))${BLUE}%\r"
        sleep $interval
    done
    echo -e "${NOCOLOR}"
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

read_interface_config() {
    interface_config_file=$1
    interface=$(grep -Po 'DHCPDARGS="\K[^"]+' "$interface_config_file")
    ip_prefix=$(nmcli con show "$interface" | grep ipv4.addresses | awk '{print $2}')
    dns=$(nmcli con show "$interface" | grep ipv4.dns | awk '{print $2}')
    echo $interface
    echo $ip_prefix
    echo $dns
}

write_interface_config() {
    interface_config_file=$1
    cat <<EOL | tee "$interface_config_file" > /dev/null
# DHCPDARGS is defined by the dhcpd startup script
DHCPDARGS=$interface;
EOL

    nmcli con mod "$interface" ipv4.addresses "$ip_prefix" ipv4.dns "$dns" ipv4.method manual
    nmcli con up "$interface"
    systemctl restart dhcpd
}

configure_interface() {
    echo -ne "Enter the interface to listen on (e.g., eth0): "
    read -r interface
    echo -ne "Enter the IP address and prefix (e.g., 192.168.1.1/24): "
    read -r ip_prefix
    echo -ne "Enter the DNS server (e.g., 8.8.8.8): "
    read -r dns

    write_interface_config "$interface_config_file"
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

configure_subnet() {
    while true; do
        echo -ne "Enter new subnet (e.g., 192.168.1.0): "
        read -r subnet
        if [ validate_input "$subnet" '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ]; then
            break
        else
            show_message "X" "Invalid subnet format." $RED
        fi
    done
}

configure_netmask() {
    while true; do
        echo -ne "Enter new netmask (e.g., 255.255.255.0): "
        read -r netmask
        if [ validate_input "$netmask" '^([0-9]{1,3}\.){3}[0-9]{1,3}$' ]; then
            break
        else
            show_message "X" "Invalid netmask format." $RED
        fi
    done
}

configure_range() {
    while true; do
        echo -ne "Enter new range (e.g., 192.168.1.100 192.168.1.200): "
        read -r range
        if validate_input "$range" '^([0-9]{1,3}\.){3}[0-9]{1,3} ([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            break
        else
            show_message "X" "Invalid range format." $RED
        fi
    done
}

configure_routers() {
    while true; do
        echo -ne "Enter new routers (e.g., 192.168.1.1): "
        read -r routers
        if validate_input "$routers" '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            break
        else
            show_message "X" "Invalid routers format." $RED
        fi
    done
}

configure_domain_name() {
    while true; do
        echo -ne "Enter new domain name (e.g., example.com): "
        read -r domain_name
        if validate_input "$domain_name" '^[a-zA-Z0-9.-]+$'; then
            break
        else
            show_message "X" "Invalid domain name format." $RED
        fi
    done
}

configure_domain_name_servers() {
    while true; do
        echo -ne "Enter new domain name servers (e.g., 8.8.8.8, 8.8.4.4): "
        read -r domain_name_servers
        if validate_input "$domain_name_servers" '^([0-9]{1,3}\.){3}[0-9]{1,3}(, ([0-9]{1,3}\.){3}[0-9]{1,3})*$'; then
            break
        else
            show_message "X" "Invalid domain name servers format." $RED
        fi
    done
}

configure_default_lease_time() {
    while true; do
        echo -ne "Enter new default lease time (in seconds, e.g., 600): "
        read -r default_lease_time
        if validate_input "$default_lease_time" '^[0-9]+$'; then
            break
        else
            show_message "X" "Invalid lease time format." $RED
        fi
    done
}

configure_max_lease_time() {
    while true; do
        echo -ne "Enter new max lease time (in seconds, e.g., 7200): "
        read -r max_lease_time
        if validate_input "$max_lease_time" '^[0-9]+$'; then
            break
        else
            show_message "X" "Invalid lease time format." $RED
        fi
    done
}

save_configuration() {
	clear
	show_title
    show_message "!" "Saving configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_config "$config_file"
    wait
    show_message "-" "Configuration saved successfully." $GREEN
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 4.5
}

show_dhcp_menu() {
    show_title
    echo ""
    echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Subnet: $subnet"
    echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Netmask: $netmask"
    echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Range: $range"
    echo -e " ${BLUE}[${DHCPCOLOR}4${BLUE}]${NOCOLOR} Routers: $routers"
    echo -e " ${BLUE}[${DHCPCOLOR}5${BLUE}]${NOCOLOR} Domain Name: $domain_name"
    echo -e " ${BLUE}[${DHCPCOLOR}6${BLUE}]${NOCOLOR} Domain Name Servers: $domain_name_servers"
    echo -e " ${BLUE}[${DHCPCOLOR}7${BLUE}]${NOCOLOR} Default Lease Time: $default_lease_time"
    echo -e " ${BLUE}[${DHCPCOLOR}8${BLUE}]${NOCOLOR} Max Lease Time: $max_lease_time"
    echo -e " ${BLUE}[${DHCPCOLOR}9${BLUE}]${NOCOLOR} Save Configuration"
    echo -e " ${BLUE}[${DHCPCOLOR}10${BLUE}]${NOCOLOR} Back to Main Menu"
    echo ""
}

dhcp_menu() {
    while true; do
        show_dhcp_menu
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) configure_subnet ;;
            2) configure_netmask ;;
            3) configure_range ;;
            4) configure_routers ;;
            5) configure_domain_name ;;
            6) configure_domain_name_servers ;;
            7) configure_default_lease_time ;;
            8) configure_max_lease_time ;;
            9) save_configuration ;;
            10) break ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
    clear
}

select_dhcp_config_file() {
    echo -ne "Enter the path to the new DHCP configuration file: "
    read -r config_file
    read_config "$config_file"
}

show_main_menu() {
    show_title
    echo ""
    echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Configure Listening Interface"
    echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Configure DHCP Configuration"
    echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Exit"
    echo ""
}

main_menu() {
    while true; do
        show_main_menu
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) configure_interface_menu ;;
            2) configure_dhcp_conf ;;
            3) exit 0 ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
}

configure_interface_menu() {
    while true; do
        show_title
        echo ""
        echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Select Interface Configuration File"
        echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Configure Interface"
        echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Save Configuration"
        echo -e " ${BLUE}[${DHCPCOLOR}4${BLUE}]${NOCOLOR} Back to Main Menu"
        echo ""
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) select_interface_config_file ;;
            2) configure_interface ;;
            3) save_interface_configuration ;;
            4) break ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
    clear
}

select_interface_config_file() {
    echo -ne "Enter the path to the new interface configuration file: "
    read -r interface_config_file
    read_interface_config "$interface_config_file"
}

save_interface_configuration() {
    show_message "!" "Saving interface configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    write_interface_config "$interface_config_file"
    wait
    show_message "-" "Interface configuration saved successfully." $GREEN
}

configure_dhcp_conf() {
    while true; do
        show_title
        echo ""
        echo -e " ${BLUE}[${DHCPCOLOR}1${BLUE}]${NOCOLOR} Use Default DHCP Configuration File ($DEFAULT_DHCP_CONF)"
        echo -e " ${BLUE}[${DHCPCOLOR}2${BLUE}]${NOCOLOR} Select A Diferent DHCP Configuration File"
        echo -e " ${BLUE}[${DHCPCOLOR}3${BLUE}]${NOCOLOR} Back to Main Menu"
        echo ""
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) config_file=$DEFAULT_DHCP_CONF; read_config "$config_file"; dhcp_menu ;;
            2) select_dhcp_config_file ;;
            3) break ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
    clear
}

main() {
    main_menu
}

# main

read_interface_config DEFAULT_INTERFACE_CONF 