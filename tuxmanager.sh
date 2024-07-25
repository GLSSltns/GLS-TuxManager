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
	echo -e "[1] Services Install\t\t\t[5] Info"
	echo -e "[2] Services Configuration\t\t[${RED}6${NOCOLOR}] Quit"
	echo -e "[3] Services Management"
	echo -e "[4] Services Status"
	echo ""
}


mainf()
{
	showtitle
	showmenu
}

mainf