#!/bin/bash

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
