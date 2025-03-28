#!/bin/bash

# DFS function to explore directories
dfs() {
    local dir="$1"

    # Loop through all files and directories in the current directory
    for file in "$dir"/*; do
        # Check if it is a directory
        if [ -d "$file" ]; then
            echo "Directory: $file"
            # Recursively call dfs on the subdirectory
            dfs "$file"
        elif [ -f "$file" ]; then
            # If it's a file, just print it
            echo "File: $file"
        fi
    done
}

# Start DFS from the current directory
start_dir=$(pwd)  # Get the current directory
dfs "$start_dir"
