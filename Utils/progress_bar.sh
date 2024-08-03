#!/bin/bash

# Function to display a progress bar
progress_bar() {
    local duration=$1  # Total duration 
    local steps=10  # Number of steps 
    local interval=$((duration / steps))  # Time interval between steps

    local color=$2  # Color for the progress bar

    for ((i = 0; i <= steps; i++)); do
        echo -ne "${MAIN_COLOR} ["  # Start 
        for ((j = 0; j < i; j++)); do echo -ne "${color}###"; done  # Filled portion
        for ((j = i; j < steps; j++)); do echo -ne "${NOCOLOR}..."; done  # Unfilled portion
        echo -ne "${MAIN_COLOR}] ${color}$((i * 10))${MAIN_COLOR}%\r"  # Display percentage
        sleep $interval  # Wait for the interval duration
    done
    echo -e "${NOCOLOR}"  # Reset color and move to a new line
}
