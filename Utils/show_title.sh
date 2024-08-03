#!/bin/bash

# COLORS

COLOR="$1"

show_title() {
    echo -e -n "${MAIN_COLOR}"
    echo -e '________                ______  ___                                '               
    echo -e '___  __/____  ______  _____   |/  /______ ________ ______ ________ ______ ________'
    echo -e -n '__  /   _  / / /__  |/_/__  /|_/ / _  __ `/__  __ \_  __ `/__  __ `/_  _ \__  ___/ ' ; echo -e "${COLOR}(o<${MAIN_COLOR}"
    echo -e -n '_  /    / /_/ / __>  <  _  /  / /  / /_/ / _  / / // /_/ / _  /_/ / /  __/_  /     ' ; echo -e "${COLOR}//\\ ${MAIN_COLOR}"
    echo -e -n '/_/     \__,_/  /_/|_|  /_/  /_/   \__,_/  /_/ /_/ \__,_/  _\__, /  \___/ /_/      ' ; echo -e "${COLOR}V_/_${MAIN_COLOR}"
    echo -e '                                                           /____/ '
    echo -e "\n${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
}

show_banner() {
    echo -e -n "${MAIN_COLOR}GitHub: ${COLOR}https://github.com/GsusLnd/TuxManager${NOCOLOR}"
    echo -e "\t\t\t      ${MAIN_COLOR}Version: ${COLOR}1.0${NOCOLOR}"
    echo -e "${MAIN_COLOR}----------------------------------------------------------------------------------${NOCOLOR}"
}

# Main function
main() {
    show_title
    show_banner
}

# Execute main function
main
