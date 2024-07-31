#!/bin/bash

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