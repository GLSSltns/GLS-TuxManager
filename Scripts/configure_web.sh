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
HTTPCOLOR='\033[1;33m'

HTTPD_ROOT="/var/www/html"
config_changed=0

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
    while true; do
        echo -ne "\n Enter the name of the directory to create: "
        read -r dir_name
        if [ -z "$dir_name" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2.5
            break
        else
            if validate_input "$dir_name" '^[a-zA-Z0-9_-]+$'; then
                mkdir -p "$HTTPD_ROOT/$dir_name"
                show_message "+" "Directory '$dir_name' created successfully." $GREEN
                sleep 2.5
                config_changed=1
                clear
                break
            else
                show_message "X" "Invalid directory name." $RED
                sleep 2.5
            fi
        fi
    done
}

add_file() {
    while true; do
        echo -ne "\n Enter the directory to add the file in (${HTTPCOLOR}relative to $HTTPD_ROOT, or leave empty for root${NOCOLOR}): "
        read -r dir_name
        local target_dir="$HTTPD_ROOT/$dir_name"
        if [[ -z "$dir_name" || -d "$target_dir" ]]; then
            echo -ne "\n Enter the name of the file to create (${HTTPCOLOR}e.g., index.html, style.css${NOCOLOR}): "
            read -r file_name
            if [ -z "$file_name" ]; then
            	show_message "!" "Cancelled..." $YELLOW
            	sleep 2.5
            	break
            elif validate_input "$file_name" '^[a-zA-Z0-9_-]+\.[a-zA-Z0-9]+$'; then
                touch "$target_dir/$file_name"
                show_message "+" "File '$file_name' created successfully in '$target_dir'." $GREEN
                sleep 2.5
                config_changed=1
                clear
                break
            else
                show_message "X" "Invalid file name." $RED
                sleep 2.5
            fi
        else
            show_message "X" "Directory '$dir_name' does not exist." $RED
            sleep 2.5
        fi
    done
}

edit_file() {
    while true; do
        echo -ne "\n Enter the name of the file to edit (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2.5
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            nano "$target_file"
            show_message "+" "File '$file_name' edited successfully." $GREEN
            sleep 2.5
            config_changed=1
            clear
            break
        else
            show_message "X" "File '$file_name' does not exist." $RED
            sleep 2.5
        fi
    done
}

view_file_content() {
    while true; do
        echo -ne "\n Enter the name of the file to view (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2.5
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            echo -e "\n${YELLOW}Content of '$file_name':${NOCOLOR}"
            cat "$target_file"
            echo -ne "\n Press ${BLUE}[${HTTPCOLOR}ENTER${BLUE}]${NOCOLOR} To Continue..."
            read -r 
            break
        else
            show_message "X" "File '$file_name' does not exist." $RED
            sleep 2.5
        fi
    done
}

remove_file() {
    while true; do
        echo -ne "\n Enter the name of the file to remove (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r file_name
        if [ -z "$file_name" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2
            break
        fi
        local target_file="$HTTPD_ROOT/$file_name"
        if [[ -f "$target_file" ]]; then
            echo -ne "Are you sure you want to delete '$file_name'? (y/n${NOCOLOR}): "
            read -r confirmation
            if [[ "$confirmation" =~ ^[Yy]$ ]]; then
                rm "$target_file"
                show_message "-" "File '$file_name' deleted successfully." $GREEN
                sleep 2.5
                sleep 3
                config_changed=1
                clear
                break
            else
                show_message "X" "File deletion cancelled." $RED
                sleep 2.5
                break
            fi
        else
            show_message "X" "File '$file_name' does not exist." $RED
            sleep 2.5
        fi
    done
}

remove_directory() {
    while true; do
        echo -ne "\n Enter the name of the directory to remove (${HTTPCOLOR}relative to $HTTPD_ROOT${NOCOLOR}): "
        read -r dir_name
        if [ -z "$dir_name" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2
            break
        fi
        local target_dir="$HTTPD_ROOT/$dir_name"
        if [[ -d "$target_dir" ]]; then
            echo -ne "Are you sure you want to delete directory '$dir_name' and all its contents? (y/n${NOCOLOR}): "
            read -r confirmation
            if [[ "$confirmation" =~ ^[Yy]$ ]]; then
                rm -r "$target_dir"
                show_message "-" "Directory '$dir_name' deleted successfully." $GREEN
                sleep 2.5
                config_changed=1
                clear
                break
            else
                show_message "X" "Directory deletion cancelled." $RED
                sleep 2.5
                break
            fi
        else
            show_message "X" "Directory '$dir_name' does not exist." $RED
            sleep 2.5
        fi
    done
}

upload_file() {
    while true; do
        echo -ne "\n Enter the path of the file to upload (${HTTPCOLOR}e.g., /path/to/local/file.html${NOCOLOR}): "
        read -r local_file_path
        if [ -z "$local_file_path" ]; then
        	show_message "!" "Cancelled..." $YELLOW
        	sleep 2
        	break
        elif [[ -f "$local_file_path" ]]; then
            echo -ne "\n Enter the target directory in HTTPD root (${HTTPCOLOR}relative to $HTTPD_ROOT, or leave empty for root${NOCOLOR}): "
            read -r dir_name
            local target_dir="$HTTPD_ROOT/$dir_name"
            if [[ -z "$dir_name" || -d "$target_dir" ]]; then
                cp "$local_file_path" "$target_dir/"
                show_message "+" "File '$(basename "$local_file_path")' uploaded successfully to '$target_dir'." $GREEN
                sleep 2.5
                config_changed=1
                clear
                break
            else
                show_message "X" "Directory '$dir_name' does not exist." $RED
                sleep 2.5
            fi
        else
            show_message "X" "Local file '$local_file_path' does not exist." $RED
            sleep 2.5
        fi
    done
}

list_files() {
    echo -e "\n${YELLOW}Listing files in $HTTPD_ROOT:${NOCOLOR}"
    display_tree_structure "$HTTPD_ROOT" ""
    echo -ne "\n Press ${BLUE}[${HTTPCOLOR}ENTER${BLUE}]${NOCOLOR} To Continue..."
    read -r
}

display_tree_structure() {
    local dir_path=$1
    local indent="$2"

    for file in "$dir_path"/*; do
        if [[ -d "$file" ]]; then
            echo -e "${indent}${BLUE}+-- ${NOCOLOR}$(basename "$file")/"
            display_tree_structure "$file" "$indent    |"
        elif [[ -f "$file" ]]; then
            echo -e "${indent}${GREEN}+-- ${NOCOLOR}$(basename "$file")"
        fi
    done
}

show_httpd_menu() {
    show_title
    echo -e "\t\t\t\t\t ${HTTPCOLOR}HTTPD CONFIGURATION:${NOCOLOR}"
    echo -e " ${BLUE}[${HTTPCOLOR}1${BLUE}]${NOCOLOR} List Files"
    echo -e " ${BLUE}[${HTTPCOLOR}2${BLUE}]${NOCOLOR} Create Directory"
    echo -e " ${BLUE}[${HTTPCOLOR}3${BLUE}]${NOCOLOR} Remove Directory"
    echo -e " ${BLUE}[${HTTPCOLOR}4${BLUE}]${NOCOLOR} Add File"
    echo -e " ${BLUE}[${HTTPCOLOR}5${BLUE}]${NOCOLOR} Upload File"
    echo -e " ${BLUE}[${HTTPCOLOR}6${BLUE}]${NOCOLOR} Edit File"
    echo -e " ${BLUE}[${HTTPCOLOR}7${BLUE}]${NOCOLOR} Remove File"
    echo -e " ${BLUE}[${HTTPCOLOR}8${BLUE}]${NOCOLOR} View File Content"
    echo -e " ${BLUE}[${HTTPCOLOR}9${BLUE}]${NOCOLOR} Exit"
    echo ""
}
httpd_menu() {
    clear
    show_httpd_menu
    while true; do
        echo -ne " ${BLUE}Enter an option ${YELLOW}\$${BLUE}>:${NOCOLOR} "
        read -r op
        if [ -z "$op" ]; then
            echo "" > /dev/null
        else
            case $op in
                1) 
                    list_files 
                    show_httpd_menu
                    ;;
                2) 
                    create_directory 
                    show_httpd_menu
                    ;;
                3) 
                    remove_directory 
                    show_httpd_menu
                    ;;
                4) 
                    add_file 
                    show_httpd_menu
                    ;;
                5) 
                    upload_file 
                    show_httpd_menu
                    ;;
                6) 
                    edit_file 
                    show_httpd_menu
                    ;;
                7) 
                    remove_file 
                    show_httpd_menu
                    ;;
                8) 
                    view_file_content 
                    show_httpd_menu
                    ;;
                9) break ;;
                *) show_message "X" "Invalid option." $RED
                sleep 2.5 ; echo "" ;;
            esac
        fi
    done
    clear
}

httpd_menu
