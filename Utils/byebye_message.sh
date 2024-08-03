#!/bin/bash

TUXCOLOR="$(tput setaf 172)"
RED="$(tput setaf 160)"

stty -echoctl # hide ^C
trap 'byebye_message' SIGINT

byebye_message() {
	echo -ne "\r"
    show_message "!" "Execution was stopped by the user (^C)!" $RED
    tput sgr0
    stty echo
    stty -igncr
    exit
}



