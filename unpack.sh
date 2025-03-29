#!/bin/bash
# Function to handle archives and unpack them if necessary


handle_archive() {
    local file="$1"
    local temp_dir="$2"

    base_name=$(basename "$file")  # Get filename with extension
    file_name="${base_name%.*}"    # Remove only last extension (keeps base name)

    # Create a unique extraction path based on both base name and file extension
    extract_dir="$temp_dir/${file_name}_extracted_${base_name##*.}"
    mkdir -p "$extract_dir"

    echo "Extracting $file into $extract_dir..."

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
        *)
            echo "Unsupported archive type: $file"
            return 1
            ;;
    esac

    # Immediately scan the extracted directory for more archives
    dfs "$extract_dir"
}


# DFS function to explore directories
dfs() {
    local dir="$1"
    
    echo "Scanning directory: $dir"

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
            esac
        fi
    done
}

# Start DFS from the current directory
start_dir=$(pwd)  # Get the current directory
dfs "$start_dir"










# #!/bin/bash
# # Function to handle archives and unpack them if necessary
# handle_archive() {
#     local file="$1"
#     local temp_dir="$2"
#     #echo "Unpacking $file..."
#     case "$file" in
#         *.tar.gz|*.tgz)
#             tar -xzf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
#             ;;
#         *.tar.bz2|*.tbz)
#             tar -xjf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
#             ;;
#         *.tar)
#             tar -xf "$file" -C "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
#             ;;
#         *.zip)
#             unzip "$file" -d "$temp_dir" || { echo "Failed to unpack $file"; return 1; }
#             ;;
#         *)
#             #echo "Unsupported archive type: $file"
#             return -1
#             ;;
#     esac
# }
# # DFS function to explore directories
# dfs() {
#     local dir="$1"
    
#     # Loop through all files and directories in the current directory
#     for file in "$dir"/*; do
#         if [ -d "$file" ]; then
#             # If it's a directory, recursively call dfs
#             dfs "$file"
#         elif [ -f "$file" ]; then
#             # Check if it's an archive, and unpack it
#             case "$file" in
#                 *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tar|*.zip)
#                     handle_archive "$file" "$dir"
#                     base_path=${file##*/}	
#                     file_name1=${base_path%.*.*}
#                     # After unpacking, call dfs again on the extracted directory
#                     echo $dir
#                     if [ -d "$dir"/"$file_name1" ]; then
#                         dfs "$dir"/"$file_name1"
#                     fi
#                     ;;
#             esac
#         fi
#     done
# }
# # Start DFS from the current directory
# start_dir=$(pwd)  # Get the current directory
# dfs "$start_dir"

