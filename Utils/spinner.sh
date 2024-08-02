#!/bin/bash

spinner() {
  	local duration="$1"
  	local msg="$2"

 	spin[0]="-"
  	spin[1]="\\"
  	spin[2]="|"
  	spin[3]="/"

 	echo -e "${msg} ${spin[0]}"
  	local start_time=$(date +%s)
  	while (( $(date +%s) - start_time < duration )); do
  	  	for i in "${spin[@]}"; do
  	    	echo -ne "\b\b\b[$i]"
  	    	sleep 0.1
  	  	done
  	done
  	echo -ne "\r" # Clean up after spinner finishes
  	echo -e "${msg}      "
}