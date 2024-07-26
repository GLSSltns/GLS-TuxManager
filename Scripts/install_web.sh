#!/bin/bash

# COLORS
BLUE='\033[0;1;34;94m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[1;31m'
GREEN='\033[0;1;32;92m'
GREEN2='\033[0;32m'
PINK='\033[1;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'


NOCOLOR='\033[0m'

showtitle()
{
	bash Utils/show_title.sh $PINK
}

progressbar()
{
	echo "progressbar"
}

isinstalled()
{
	echo "isinstalled"
}

updatepkg()
{
	echo "updatepkg"
}

showmenu()
{
	clear
	showtitle
	echo ""
	echo -e " ${BLUE}[${PINK}1${BLUE}]${NOCOLOR} Install WEB"
	echo -e " ${BLUE}[${PINK}2${BLUE}]${NOCOLOR} Uninstall WEB"
	echo -e " ${BLUE}[${PINK}3${BLUE}]${NOCOLOR} Update WEB"
	echo -e " ${BLUE}[${PINK}4${BLUE}]${NOCOLOR} Go To Menu"
	echo ""
	for ((;;))
	do
		echo -e -n " ${BLUE}Enter An Option ${PINK}\$${BLUE}>:${NOCOLOR} "
		read -r op
		case $op in
			1)echo "Installing";;
			2)echo "Uninstalling";;
			3)echo "Updating";;
			4)
				break
			;;
			*) 
				echo -e " ${BLUE}[${RED}X${BLUE}]${RED} Invalid Option\n"
			;;
		esac
	done
	clear 
}
mainf()
{
	showmenu
}

mainf
