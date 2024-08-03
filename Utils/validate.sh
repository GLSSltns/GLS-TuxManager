#!/bin/bash

# Define a constant for no color (resets the terminal color)
NOCOLOR='\033[0m'
RED='\033[38;5;88m'
GREEN='\033[38;5;78m'
WHITE='\033[38;5;158m'

# Function to validate input against a regular expression
validate_input_regex() {
    local input=$1  # Input string to be validated
    local regex=$2  # Regular expression pattern for validation

    # Check if the input matches the regex pattern
    if [[ $input =~ $regex ]]; then
        return 0  # Return 0 (success) if the input matches the pattern
    else
        return 1  # Return 1 (failure) if the input does not match the pattern
    fi
}

# Function to prompt the user for confirmation
prompt_confirmation() {
    local prompt_message=$1  # Message to display to the user
    local main_color="$WHITE"      # Color for the main part of the message
    local yes_color="$GREEN"      # Color for the 'Y' (yes) option
    local no_color="$RED"        # Color for the 'n' (no) option

    while true; do
        echo ""  # Print an empty line for spacing
        # Prompt the user with the message, colorizing 'Y' and 'n' accordingly
        echo -ne "${main_color} $prompt_message [${yes_color}Y${main_color}/${no_color}n${NOCOLOR}]: "
        read -r yn  # Read the user's input
        case $yn in
            [Yy]*) return 0 ;;  # Return 0 (success) if the user inputs 'Y' or 'y'
            [Nn]*) return 1 ;;  # Return 1 (failure) if the user inputs 'N' or 'n'
            *) show_message "X" "Please answer yes (Y) or no (n)." $RED ;;  # Ask again if the input is invalid
        esac
    done
}
