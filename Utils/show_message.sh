#!/bin/bash

# Function to display a formatted message
show_message() {
    local c=$1  # Indicator symbol (e.g., !, -, X)
    local message=$2  # The message to display
    local color=$3  # The color for the indicator and message

    # Display the message with formatting and color
    echo -e " ${MAIN_COLOR}[${color}${c}${MAIN_COLOR}]${color} ${message}${NOCOLOR}"
}
