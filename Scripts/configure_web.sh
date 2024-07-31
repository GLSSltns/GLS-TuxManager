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
HTTPCOLOR='\033[1;32m'

DEFAULT_HTTPD_DIR="/var/www/html"
TEMPLATES_DIR="templates"
HTML_EXT=".html"

httpd_conf_changed=0

# Utils
source Utils/progress_bar.sh

show_title() {
    clear
    bash Utils/show_title.sh $HTTPCOLOR
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

create_directory() {
    echo -ne "Enter the directory name to create: "
    read -r dir_name
    mkdir -p "$DEFAULT_HTTPD_DIR/$dir_name"
    show_message "!" "Directory '$dir_name' created successfully." $GREEN
    sleep 2
}

add_html_template() {
    echo -ne "Enter the name of the HTML template to add: "
    read -r template_name
    touch "$DEFAULT_HTTPD_DIR/$TEMPLATES_DIR/$template_name$HTML_EXT"
    echo "<html><head><title>$template_name</title></head><body><h1>$template_name</h1></body></html>" > "$DEFAULT_HTTPD_DIR/$TEMPLATES_DIR/$template_name$HTML_EXT"
    show_message "!" "Template '$template_name$HTML_EXT' added successfully." $GREEN
    sleep 2
}

edit_html_template() {
    echo -ne "Enter the name of the HTML template to edit: "
    read -r template_name
    nano "$DEFAULT_HTTPD_DIR/$TEMPLATES_DIR/$template_name$HTML_EXT"
}

list_html_templates() {
    echo -e "\n${GREEN}Available HTML Templates:${NOCOLOR}"
    ls -1 "$DEFAULT_HTTPD_DIR/$TEMPLATES_DIR"/*.html
    echo ""
    echo -ne "Press enter to continue..."
    read -r
}

save_configuration() {
    show_title
    show_message "!" "Saving HTTPD configuration..." $YELLOW
    progress_bar 5 $YELLOW &
    wait
    show_message "-" "HTTPD configuration saved successfully." $GREEN
    httpd_conf_changed=0
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
    sleep 4.5
}

show_httpd_menu() {
    show_title
    echo -e " ${BLUE}[${HTTPCOLOR}1${BLUE}]${NOCOLOR} Create Directory"
    echo -e " ${BLUE}[${HTTPCOLOR}2${BLUE}]${NOCOLOR} Add HTML Template"
    echo -e " ${BLUE}[${HTTPCOLOR}3${BLUE}]${NOCOLOR} Edit HTML Template"
    echo -e " ${BLUE}[${HTTPCOLOR}4${BLUE}]${NOCOLOR} List HTML Templates"
    echo -e " ${BLUE}[${HTTPCOLOR}5${BLUE}]${NOCOLOR} Save Configuration"
    echo -e " ${BLUE}[${HTTPCOLOR}6${BLUE}]${NOCOLOR} Back to Main Menu"
    echo ""
}

httpd_menu() {
    while [ true ]; do
        show_httpd_menu
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) create_directory ;;
            2) add_html_template ;;
            3) edit_html_template ;;
            4) list_html_templates ;;
            5) 
                clear
                save_configuration ;;
            6) 
                if [ $httpd_conf_changed -eq 1 ]; then
                    show_message "!!" "You have unsaved changes." $YELLOW
                    echo -ne " Are you sure you want to QUIT? (${GREEN}Y${NOCOLOR}/${RED}n${NOCOLOR}): "
                    read -r confirm
                    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
                        echo ""
                        sleep 1
                    else
                        echo ""
                        show_message "!" "Quitting without saving." $YELLOW
                        httpd_conf_changed=0
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
    done
    clear
}

main_menu() {
    while [ true ]; do
        show_title
        echo ""
        echo -e " ${BLUE}[${HTTPCOLOR}1${BLUE}]${NOCOLOR} Configure HTTPD"
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        case $op in
            1) httpd_menu ;;
            2) break ;;
            *) show_message "X" "Invalid option." $RED ;;
        esac
    done
}

# Create templates directory if it doesn't exist
mkdir -p "$DEFAULT_HTTPD_DIR/$TEMPLATES_DIR"
main_menu
