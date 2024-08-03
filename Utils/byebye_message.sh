#!/bin/bash

TUXCOLOR="$(tput setaf 172)"
RED="$(tput setaf 160)"

stty -echoctl # hide ^C
trap 'byebye_execution' SIGINT

byebye_execution() {
	echo -ne "\r"
    show_message "!" "Execution was stopped by the user (^C)!" $RED
    tput sgr0
    stty echo
    stty -igncr
    exit
}

