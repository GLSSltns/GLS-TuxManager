#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
NOCOLOR='\033[0m'
COLOR=${1:-$NOCOLOR}

show_title() {
    echo -e -n "${BLUE}"
    echo -e '________                ______  ___                                '               
    echo -e '___  __/____  ______  _____   |/  /______ ________ ______ ________ ______ ________'
    echo -e -n '__  /   _  / / /__  |/_/__  /|_/ / _  __ `/__  __ \_  __ `/__  __ `/_  _ \__  ___/ ' ; echo -e "${COLOR}(o<${BLUE}"
    echo -e -n '_  /    / /_/ / __>  <  _  /  / /  / /_/ / _  / / // /_/ / _  /_/ / /  __/_  /     ' ; echo -e "${COLOR}//\\ ${BLUE}"
    echo -e -n '/_/     \__,_/  /_/|_|  /_/  /_/   \__,_/  /_/ /_/ \__,_/  _\__, /  \___/ /_/      ' ; echo -e "${COLOR}V_/_${BLUE}"
    echo -e '                                                           /____/ '
    echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
}

show_banner() {
    echo -e -n "${BLUE}GitHub: ${COLOR}https://github.com/GsusLnd/TuxManager${NOCOLOR}"
    echo -e "\t\t\t      ${BLUE}Version: ${COLOR}1.0${NOCOLOR}"
    echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
}

# Main function
main() {
    show_title
    show_banner
}

# Execute main function
main
