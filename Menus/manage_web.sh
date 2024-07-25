#!/bin/bash
#Authors:
#       Gael Jesús Landa Mohedano
#       Leonardo Aceves Martínez
#       Sergio Gerardo Méndez Guzmán
#       Jocelyn Alexandra González Serrano
#Version: 1.0
#Title: Manage WEB


# Flag archivo
ffile=0

menu()
{
        clear
        echo -e "\t\t{green}$Manage WEB$${nocolor}\n"
        echo -e "\t\tOption\tTarea"
        echo -e "\t\t-------------------------"
		echo -e "\t\t[${blue}1${nocolor}]:\tStart"
		echo -e "\t\t[${blue}2${nocolor}]:\tStop"
		echo -e "\t\t[${blue}2${nocolor}]:\tRestart"
        echo -e "\t\t[${blue}5${nocolor}]:\tMENU"
        echo -n -e "\t"

        read -rp "Option: " op
}
