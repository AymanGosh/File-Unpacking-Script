#!/bin/bash

# Default values
recursive=false
verbose=false

# Parse options
while getopts "rv" opt; do
    case "$opt" in
        r) recursive=true ;;
        v) verbose=true ;;
        ?) echo "Usage: $0 [-r] [-v] file [files...]"
           exit 1 ;;
    esac
done

# Remove parsed options from arguments
shift $((OPTIND - 1))

# Ensure at least one file is provided
if [ $# -lt 1 ]; then
    echo "Error: At least one file must be specified."
    echo "Usage: $0 [-r] [-v] file [files...]"
    exit 1
fi


handle_archive() {
    local file="$1"
    local temp_dir="$2"

    base_name=$(basename "$file")  # Get filename with extension
    file_name="${base_name%.*}"    # Remove only last extension (keeps base name)

    # Create a unique extraction path based on both base name and file extension
    extract_dir="$temp_dir/${file_name}_extracted_${base_name##*.}"
    mkdir -p "$extract_dir"

    if [ "$verbose" = true ]; then
        echo "Unpacking" $file_name
    fi
    



    case "$file" in
        *.tar.gz|*.tgz)
            tar -xzf "$file" -C "$extract_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.tar.bz2|*.tbz)
            tar -xjf "$file" -C "$extract_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.tar)
            tar -xf "$file" -C "$extract_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.zip)
            unzip -q "$file" -d "$extract_dir" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.gz)
            gunzip -c "$file" > "$extract_dir/${base_name%.*}" || { echo "Failed to unpack $file"; return 1; }
            ;;
        *.bz2)
            bunzip2 -c "$file" > "$extract_dir/${base_name%.*}" || { echo "Failed to unpack $file"; return 1; }
            ;;
    esac

    # Immediately scan the extracted directory for more archives
 
    if [ "$recursive" = true ]; then
         dfs "$extract_dir"
    fi
   
}


# DFS function to explore directories
dfs() {
    local dir="$1"
    
    # if -v
    #echo "Scanning directory: $dir"

    # Loop through all files and directories in the current directory
    for file in "$dir"/*; do
        if [ -d "$file" ]; then
            # If it's a directory, recursively scan it
            dfs "$file"
        elif [ -f "$file" ]; then
            # If it's an archive, unpack it
            case "$file" in
                *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tar|*.zip|*.gz|*.bz2|*.Z)
                    
                    handle_archive "$file" "$dir"
                    ;;
                *)
                    #echo "Unsupported archive type: $file"
                    if [ "$verbose" = true ]; then
                        base_name=$(basename "$file")  # Get filename with extension
                        file_name="${base_name%.*}"    # Remove only last extension (keeps base name)
                        echo "Ignoring " $file_name
                    fi
                    ;;
                    
            esac
        fi
    done
}

for file in "$@"; do
    if [ -f "$file" ]; then
        # Extract the archive
        case "$file" in
            *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tar|*.zip|*.gz|*.bz2|*.Z)
                handle_archive "$file" "$(pwd)"
                ;;
            *)
                #echo "Unsupported archive type: $file"
                if [ "$verbose" = true ]; then
                    base_name=$(basename "$file")  # Get filename with extension
                    file_name="${base_name%.*}"    # Remove only last extension (keeps base name)
                    echo "Ignoring " $file_name
                fi
                ;;
        esac
    #else
        #echo "File not found: $file"
    fi
done


