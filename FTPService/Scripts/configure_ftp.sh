#!/bin/bash

# Utility functions for styling and progress display
source Utils/styling.sh
source Utils/progress.sh

readonly FTP_CONFIG="/etc/vsftpd/vsftpd.conf"

show_title() {
    clear
    echo -e "${MAIN_COLOR}VSFTPD CONFIGURATION MENU${NOCOLOR}"
    echo ""
}

show_vsftpd_menu() {
    show_title
    echo -e "\t\t\t\t\t ${DHCPCOLOR}CURRENT CONFIG:${NOCOLOR}"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Anonymous Enable \t\t [${DHCPCOLOR}$(grep -E '^anonymous_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} FTPD Banner \t\t\t [${DHCPCOLOR}$(grep -E '^ftpd_banner=' $FTP_CONFIG | cut -d= -f2-)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Chroot Local User \t\t [${DHCPCOLOR}$(grep -E '^chroot_local_user=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Chroot List Enable \t\t [${DHCPCOLOR}$(grep -E '^chroot_list_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}5${MAIN_COLOR}]${NOCOLOR} Allow Writeable Chroot \t\t [${DHCPCOLOR}$(grep -E '^allow_writeable_chroot=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}6${MAIN_COLOR}]${NOCOLOR} Chroot List File \t\t [${DHCPCOLOR}$(grep -E '^chroot_list_file=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}7${MAIN_COLOR}]${NOCOLOR} LS Recurse Enable \t\t [${DHCPCOLOR}$(grep -E '^ls_recurse_enable=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}8${MAIN_COLOR}]${NOCOLOR} Listen \t\t\t [${DHCPCOLOR}$(grep -E '^listen=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}9${MAIN_COLOR}]${NOCOLOR} Listen IPv6 \t\t\t [${DHCPCOLOR}$(grep -E '^listen_ipv6=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}10${MAIN_COLOR}]${NOCOLOR} Use Localtime \t\t\t [${DHCPCOLOR}$(grep -E '^use_localtime=' $FTP_CONFIG | cut -d= -f2)${NOCOLOR}]"
    echo ""
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}11${MAIN_COLOR}]${NOCOLOR} Save Configuration"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}12${MAIN_COLOR}]${NOCOLOR} Go Back"
    echo ""
}

handle_vsftpd_option() {
    local option=$1
    local value

    case $option in
        1)  # Anonymous Enable
            value=$(grep -E '^anonymous_enable=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' $FTP_CONFIG
                show_message "!" "Anonymous Enable has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^anonymous_enable=NO/anonymous_enable=YES/' $FTP_CONFIG
                show_message "!" "Anonymous Enable has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        2)  # FTPD Banner
            echo "Enter new FTPD Banner:"
            read new_banner
            sed -i "s/^ftpd_banner=.*/ftpd_banner=$new_banner/" $FTP_CONFIG
            show_message "!" "FTPD Banner has been updated." $YELLOW $MAIN_COLOR
            ;;
        3)  # Chroot Local User
            value=$(grep -E '^chroot_local_user=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^chroot_local_user=YES/chroot_local_user=NO/' $FTP_CONFIG
                show_message "!" "Chroot Local User has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^chroot_local_user=NO/chroot_local_user=YES/' $FTP_CONFIG
                show_message "!" "Chroot Local User has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        4)  # Chroot List Enable
            value=$(grep -E '^chroot_list_enable=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^chroot_list_enable=YES/chroot_list_enable=NO/' $FTP_CONFIG
                show_message "!" "Chroot List Enable has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^chroot_list_enable=NO/chroot_list_enable=YES/' $FTP_CONFIG
                show_message "!" "Chroot List Enable has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        5)  # Allow Writeable Chroot
            value=$(grep -E '^allow_writeable_chroot=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^allow_writeable_chroot=YES/allow_writeable_chroot=NO/' $FTP_CONFIG
                show_message "!" "Allow Writeable Chroot has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^allow_writeable_chroot=NO/allow_writeable_chroot=YES/' $FTP_CONFIG
                show_message "!" "Allow Writeable Chroot has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        6)  # Chroot List File
            echo "Enter new Chroot List File path:"
            read new_chroot_list_file
            sed -i "s|^chroot_list_file=.*|chroot_list_file=$new_chroot_list_file|" $FTP_CONFIG
            show_message "!" "Chroot List File path has been updated." $YELLOW $MAIN_COLOR
            ;;
        7)  # LS Recurse Enable
            value=$(grep -E '^ls_recurse_enable=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^ls_recurse_enable=YES/ls_recurse_enable=NO/' $FTP_CONFIG
                show_message "!" "LS Recurse Enable has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^ls_recurse_enable=NO/ls_recurse_enable=YES/' $FTP_CONFIG
                show_message "!" "LS Recurse Enable has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        8)  # Listen
            value=$(grep -E '^listen=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^listen=YES/listen=NO/' $FTP_CONFIG
                show_message "!" "Listen has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^listen=NO/listen=YES/' $FTP_CONFIG
                show_message "!" "Listen has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        9)  # Listen IPv6
            value=$(grep -E '^listen_ipv6=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^listen_ipv6=YES/listen_ipv6=NO/' $FTP_CONFIG
                show_message "!" "Listen IPv6 has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^listen_ipv6=NO/listen_ipv6=YES/' $FTP_CONFIG
                show_message "!" "Listen IPv6 has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        10)  # Use Localtime
            value=$(grep -E '^use_localtime=' $FTP_CONFIG | cut -d= -f2)
            if [ "$value" == "YES" ]; then
                sed -i 's/^use_localtime=YES/use_localtime=NO/' $FTP_CONFIG
                show_message "!" "Use Localtime has been set to NO." $YELLOW $MAIN_COLOR
            else
                sed -i 's/^use_localtime=NO/use_localtime=YES/' $FTP_CONFIG
                show_message "!" "Use Localtime has been set to YES." $YELLOW $MAIN_COLOR
            fi
            ;;
        11)  # Save Configuration
            show_message "!" "Configuration saved." $GREEN $MAIN_COLOR
            ;;
        12)  # Go Back
            return
            ;;
        *)  # Invalid option
            show_message "!" "Invalid option." $RED $MAIN_COLOR
            ;;
    esac
}

# Main menu loop
while true; do
    show_vsftpd_menu
    echo "Select an option:"
    read option
    if [ "$option" -ge 1 ] && [ "$option" -le 12 ]; then
        handle_vsftpd_option $option
    else
        show_message "!" "Invalid option, please select between 1 and 12." $RED $MAIN_COLOR
    fi
done
