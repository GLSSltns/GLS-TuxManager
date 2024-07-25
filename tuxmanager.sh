#!/bin/bash


# COLORS
BLUE='\033[0;1;34;94m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[1;31m'

NOCOLOR='\033[0m'

showtitle()
{
	clear
	cat title.txt
	echo -e "\n${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
	echo -n -e "${BLUE}GitHub: ${ORANGE}https://github.com/GsusLnd/TuxManager${NOCOLOR}"
	echo -e "\t\t\t      ${BLUE}Version: ${ORANGE}1.0${NOCOLOR}"
	echo -e "${BLUE}----------------------------------------------------------------------------------${NOCOLOR}"
}

showmenu(){
	echo -e "${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Services Install\t\t\t${BLUE}[${ORANGE}5${BLUE}]${NOCOLOR} Info"
	echo -e "${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Services Configuration\t\t${BLUE}[${RED}6${NOCOLOR}${BLUE}]${NOCOLOR} Quit"
	echo -e "${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Services Management"
	echo -e "${BLUE}[${ORANGE}4${BLUE}]${NOCOLOR} Services Status"
	echo ""
}


mainf()
{
	showtitle
	showmenu
}

mainf