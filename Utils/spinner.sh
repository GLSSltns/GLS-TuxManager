#!/bin/bash

spinner() {
  	local pid=$1
  	local msg="$2"
  
  	spin[0]="-"
  	spin[1]="\\"
  	spin[2]="|"
  	spin[3]="/"
  
 	 echo -n "[${msg}] ${spin[0]}"
  	while kill -0 $pid 2>/dev/null; do
    	for i in "${spin[@]}"; do
    	  echo -ne "\b$i"
    	  sleep 0.1
    	done
  	done
  	echo -ne "\b" # Clean up after spinner finishes 
  	echo "[${msg}] Done."
}