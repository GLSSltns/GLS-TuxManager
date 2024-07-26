#!/bin/bash


# COLORS
BLUE='\033[0;1;34;94m'
PURPLE='\033[0;1;35;95m'
ORANGE='\033[0;1;33;93m'
RED='\033[1;31m'
GREEN='\033[0;1;32;92m'

NOCOLOR='\033[0m'

showtitle()
{
	clear
	bash Utils/show_title.sh $ORANGE
}

showmenu()
{
	echo -e " \n ${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Services Install\t\t\t${BLUE}[${ORANGE}5${BLUE}]${NOCOLOR} Info"
	echo -e " ${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Services Configuration\t\t${BLUE}[${ORANGE}6${NOCOLOR}${BLUE}]${NOCOLOR} Quit"
	echo -e " ${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Services Management"
	echo -e " ${BLUE}[${ORANGE}4${BLUE}]${NOCOLOR} Services Status"
	echo ""
}

showinfo()
{
	showtitle
	echo -e "${ORANGE}"
	echo -e '  / ` /  /_`__ /_` _  /   _/_ . _  _   _'
	echo -n -e ' /_; /_,._/   ._/ /_// /_//  / /_// /_\ ' 
	echo -e "${BLUE} <\\"
	echo -e "${BLUE} <_______________________________________[]${ORANGE}#######${BLUE}]"
	echo -e '                                         </'
	echo -e " ${BLUE}AUTHORS:"
	echo -e " ${BLUE}@ Gael Landa ${NOCOLOR}\t\thttps://github.com/GsusLnd"
	echo -e " ${BLUE}@ Leonardo Aceves ${NOCOLOR}\thttps://github.com/L30AM"
	echo -e " ${BLUE}@ Sergio Méndez ${NOCOLOR}\thttps://github.com/sergiomndz15"
	echo -e " ${BLUE}@ Alexandra Gonzáles ${NOCOLOR}\thttps://github.com/AlexMangle"
	echo -e -n " \n ${BLUE}[${ORANGE}ENTER${BLUE}]${NOCOLOR} Go To Menu"
	read -s
	echo "" 
}

menuinstall()
{
	for ((;;))
	do
		clear
		showtitle
		echo ""
		echo -e " ${BLUE}[${ORANGE}1${BLUE}]${NOCOLOR} Install DHCP Service"
		echo -e " ${BLUE}[${ORANGE}2${BLUE}]${NOCOLOR} Install WEB Service"
		echo -e " ${BLUE}[${ORANGE}3${BLUE}]${NOCOLOR} Go To Menu"
		echo ""
		read -rp "Option" op
		case $op in
			1)bash Scripts/install_dhcp.sh;;
			2)bash Scripts/install_web.sh;;
			3)
				break
			;;
			*)echo -e "\nOpción no válida";;
		esac
	done
}


mainf()
{
	for ((;;))
	do
		showtitle
		showmenu
		read -p "Option: " op
		case $op in 
			1)menuinstall;;
			2)echo "Configuration";;
			3)echo "Management";;
			4)echo "Status";;
			5)
				showinfo
				clear
			;;
			6)
				break
			;;
			*)echo -e "\nOpción no válida";;
		esac
	done
}

mainf