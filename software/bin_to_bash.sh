#!/bin/bash

# Read from stdin line by line
while IFS= read -r binary || [[ -n "$binary" ]]; do
    # Remove whitespace
    binary=$(echo "$binary" | tr -d '[:space:]')

    # Validate each binary string
    if [[ ${#binary} -ne 32 || ! $binary =~ ^[01]+$ ]]; then
        echo "Invalid input: '$binary' — must be a 32-bit binary string"
        continue
    fi

    # Convert to hex
    hex=$(printf "%08X\n" "$((2#$binary))")
    #echo "$binary -> $hex" #debug mode
    echo "$hex"
done
