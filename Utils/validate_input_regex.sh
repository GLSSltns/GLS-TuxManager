#!/bin/bash

validate_input_regex() {
    local input=$1
    local regex=$2
    if [[ $input =~ $regex ]]; then
        return 0
    else
        return 1
    fi
}