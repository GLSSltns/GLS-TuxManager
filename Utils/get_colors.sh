#!/bin/bash

# Check for 256 color support

color_count=$(tput colors)
export TERM=xterm-256color


if [ $color_count -eq 8 ]; then
    export MAIN_COLOR='\033[0;1;34;94m'
    export TUXCOLOR="$(tput setaf 3)"
    export HTTPCOLOR="$(tput setaf 5)"
    export DHCPCOLOR='\033[1;33m'
    export LIGHTBLUE="$(tput setaf 6)"
    export BLUE="$(tput setaf 4)"
    export RED="$(tput setaf 1)"
    export GREEN="$(tput setaf 2)"
    export YELLOW='\033[1;33m'
    export WHITE="$(tput setaf 7)"
    export NOCOLOR="$(tput sgr0)"
    
else
    export MAIN_COLOR="$(tput setaf 26)"
    export TUXCOLOR="$(tput setaf 172)"
    export HTTPCOLOR="$(tput setaf 162)"
    export DHCPCOLOR="$(tput setaf 221)"
    export LIGHTBLUE="$(tput setaf 39)"
    export BLUE="$(tput setaf 4)"
    export RED="$(tput setaf 160)"
    export GREEN="$(tput setaf 40)"
    export YELLOW="$(tput setaf 220)"
    export WHITE="$(tput setaf 255)"
    export NOCOLOR="$(tput sgr0)"
fi