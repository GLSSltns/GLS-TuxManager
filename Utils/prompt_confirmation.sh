#!/bin/bash

prompt_confirmation() {
    prompt_message=$1
    while true; do
        echo ""
        echo -ne "${WHITE} $prompt_message [${GREEN}Y${WHITE}/${RED}n${NOCOLOR}]: "
        read -r yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) show_message "X" "Prease answer yes (Y) or no (n)." $RED ;;
        esac
    done
}