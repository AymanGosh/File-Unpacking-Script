#!/bin/bash
# Function to handle archives and unpack them if necessary
handle_archive() {
    local file="$1"
    local temp_dir="$2"
    echo "Unpacking $file..."
    case "$file" in
        *.tar.gz|*.tgz)
            tar -xzf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.tar.bz2|*.tbz)
            tar -xjf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.tar)
            tar -xf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.zip)
            unzip "$file" -d "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *)
            #echo "Unsupported archive type: $file"
            return 1
            ;;
    esac
}
# DFS function to explore directories
dfs() {
    local dir="$1"
    # Loop through all files and directories in the current directory
    for file in "$dir"/*; do
        if [ -d "$file" ]; then
            # If it's a directory, recursively call dfs
            dfs "$file"
        elif [ -f "$file" ]; then
            # Check if it's an archive, and unpack it
            case "$file" in
                *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tar|*.zip)
                    # Create a temporary directory to unpack the archive into
                    handle_archive "$file" "$dir"
                    base_path=${file##*/}	
                    file_name1=${base_path%.*.*}
                    # After unpacking, call dfs again on the extracted directory
                    if [ -d "$dir"/"$file_name1" ]; then
                        echo "Entering extracted directory: $file"
                        dfs "$dir"/"$file_name1"
                    fi
                    ;;
            esac
        fi
    done
}
# Start DFS from the current directory
start_dir=$(pwd)  # Get the current directory
dfs "$start_dir"

# To-Do:
# 1. Implement filtering using command-line arguments
#    1.1. Support filtering with/without the "v" option
#    1.2. Support filtering with/without the "r" option
# 2. Add support for handling files via command-line arguments