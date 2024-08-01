#!/bin/bash

show_message()
{
    local c=$1
    local message=$2
    local color=$3

    echo -e " ${BLUE}[${color}${c}${BLUE}]${color} ${message}${NOCOLOR}"
}