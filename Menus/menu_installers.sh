#!/bin/bash
#Authors:
#       Gael Jesús Landa Mohedano
#       Leonardo Aceves Martínez
#       Sergio Gerardo Méndez Guzmán
#       Jocelyn Alexandra González Serrano
#Version: 1.0
#Title: Install Services


# Flag archivo
ffile=0

menu()
{
        clear
        echo -e "\t\t{green}$Installers${nocolor}\n"
        echo -e "\t\tOption\tTarea"
        echo -e "\t\t-------------------------"
        echo -e "\t\t[${blue}1${nocolor}]:\tInstall DHCP"
        echo -e "\t\t[${blue}2${nocolor}]:\tInstall Server WEB"
        echo -e "\t\t[${blue}5${nocolor}]:\tMENU"
        echo -n -e "\t"

        read -rp "Option: " op
}
