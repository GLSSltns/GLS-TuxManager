#!/bin/bash

pid=$! # Process Id of the previous running command

spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"

spinner() {
  echo -n "[$msg] ${spin[0]}"
  while [ kill -0 $pid ]
  do
    for i in "${spin[@]}"
    do
          echo -ne "\b$i"
          sleep 0.1
    done
  done
  
}