#!/bin/bash

# UTILS: Source utility scripts for additional functionality
source Utils/progress_bar.sh
source Utils/show_message.sh

# FLAGS
is_dhcp_installed=0 # Track DHCP installation status
is_connection=0 # Internet connection

# Function to check if DHCP is installed
is_installed() {
    is_dhcp_installed=$(yum list installed | grep -q dhcp-server && echo 1 || echo 0)
}

# Function to check internet connection
check_connection() {
    is_connection=$(ping -q -w 1 -c 1 8.8.8.8 > /dev/null && echo 1 || echo 0)
}

show_title() {
    clear
    bash Utils/show_title.sh $DHCPCOLOR
}

# Function to install the DHCP package
install_pkg() {
    check_connection
    if [ $is_connection -eq 0 ]; then
        show_message "X" "No internet connection. Cannot install DHCP Service.\n" $RED
        return
    fi

    if [ $is_dhcp_installed -eq 1 ]; then
        show_message "!" "DHCP Service Is Already Installed.\n" $YELLOW
    else
        show_title  # Display title before installing
        echo ""
        show_message "!" 'Downloading DHCP Package (dhcp-server)...' $YELLOW
        sleep 1
        progress_bar 10 $YELLOW &  # Show progress bar
        yum install -y dhcp-server > /dev/null 2>&1  # Install package silently
        wait  # Wait for progress bar to finish
        sleep 1
        show_message "-" "DHCP Service Installed Successfully." $GREEN
        echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
        echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
        read -r -n 1 -s
        show_title
        show_menu
    fi
}

# Function to remove the DHCP package
remove_pkg() {
    if [ $is_dhcp_installed -eq 1 ]; then
        show_title
        echo ""
        show_message "!?" "The DHCP Service Package (dhcp-server) Will Be REMOVED!!" $RED
        echo -ne " Is It Okay? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then  # Confirm removal
            echo ""
            sleep 2
            show_message "!" "Removing DHCP Service Package..." $YELLOW
            progress_bar 10 $YELLOW &  # Show progress bar
            yum remove -y dhcp-server > /dev/null 2>&1  # Remove package silently
            wait  # Wait for progress bar to finish
            show_message "-" "DHCP Service Package Removed Successfully." $GREEN
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            sleep 4.5
        else
            sleep 1
            show_message "!" "Removal canceled." $YELLOW
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
            read -r -n 1 -s
        fi
        
        show_title
        show_menu
    else
        show_message "X" "DHCP Service Is Not Installed, Cannot Remove.\n" $RED
    fi
}

# Function to update the DHCP package
update_pkg() {
    check_connection
    if [ $is_connection -eq 0 ]; then
        show_message "X" "No internet connection. Cannot update DHCP Service.\n" $RED
        return
    fi

    if [ $is_dhcp_installed -eq 1 ]; then
        # Check if an update is available for the DHCP server package
        local is_update_needed=$(yum check-update dhcp-server | grep -q 'dhcp-server' && echo 1 || echo 0)
        if [ $is_update_needed -eq 1 ]; then
            show_title
            echo ""
            show_message "!" "Updating DHCP Service Package (dhcp-server)..." $YELLOW
            progress_bar 10 $YELLOW &  # Show progress bar
            yum update -y dhcp-server > /dev/null 2>&1  # Update package silently
            wait  # Wait for progress bar to finish
            show_message "-" "DHCP Service Package Updated Successfully." $GREEN
            echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
            echo -ne " ${MAIN_COLOR}Press [${DHCPCOLOR}ANY KEY${MAIN_COLOR}] to continue..."
            read -r -n 1 -s
            show_title
            show_menu
        else
            show_message "!" "DHCP Service Is Already Up To Date..\n" $YELLOW
        fi
    else
        show_message "X" "DHCP Service Is Not Installed, Cannot Update.\n" $RED
    fi
}

# Function to display the main menu options
show_menu() {
    echo ""
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}1${MAIN_COLOR}]${NOCOLOR} Install DHCP"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}2${MAIN_COLOR}]${NOCOLOR} Remove DHCP"
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}3${MAIN_COLOR}]${NOCOLOR} Update DHCP"
    echo ""
    echo -e " ${MAIN_COLOR}[${DHCPCOLOR}4${MAIN_COLOR}]${NOCOLOR} Exit DHCP Installation"
    echo ""
}

# Function to handle user input and navigate the menu
menu() {
    show_title  # Display the title
    show_menu  # Display the menu options
    while true; do
        echo -ne " ${MAIN_COLOR}Enter An Option ${DHCPCOLOR}\$${MAIN_COLOR}>:${NOCOLOR} "
        read -r op  # Read user input
        case $op in
            1)
                is_installed  # Check if DHCP is installed
                install_pkg  # Install the DHCP package
                ;;
            2)
                is_installed  # Check if DHCP is installed
                remove_pkg  # Remove the DHCP package
                ;;
            3)
                is_installed  # Check if DHCP is installed
                update_pkg  # Update the DHCP package
                ;;
            4)
                break  # Exit the menu loop
                ;;
            *)
                echo -e " ${MAIN_COLOR}[${RED}X${MAIN_COLOR}]${RED} Invalid Option\n"  # Handle invalid input
                ;;
        esac
    done
    clear 
}

# Main function to start the script
main() {
    menu  # Start the menu function
}

main  # Call the main function
