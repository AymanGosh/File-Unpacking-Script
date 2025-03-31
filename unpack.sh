#!/bin/bash
# Default values
recursive=false
verbose=false
counter=0 
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



extract_and_queue() {
    local dir="$1"
    local queue=("$dir")

    while [[ ${#queue[@]} -gt 0 ]]; do
        current_dir="${queue[0]}"
        queue=("${queue[@]:1}")  # Remove first element

        echo "Processing directory: $current_dir"

        # Loop through files in the directory
        for entry in "$current_dir"/*; do
            [[ -e "$entry" ]] || continue  # Skip if no files exist

            # Check if it's a directory and add it to the queue
            if [[ -d "$entry" ]]; then
                echo "Found directory: $entry"
                queue+=("$entry")
                continue  # Skip extraction, process next entry
            fi

            case "$entry" in
                *.tar.gz|*.tgz)
                    echo "Extracting: $entry"
                    new_dir="${entry%.*}"  # Remove .tar.gz
                    rm -rf "$new_dir"
                    mkdir -p "$new_dir"
                    tar -xzf "$entry" -C "$new_dir" && rm "$entry"
                    queue+=("$new_dir")  # Add to queue
                    ;;
                *.tar.bz2)
                    echo "Extracting: $entry"
                    new_dir="${entry%.*}"
                    rm -rf "$new_dir"
                    mkdir -p "$new_dir"
                    tar -xjf "$entry" -C "$new_dir" && rm "$entry"
                    queue+=("$new_dir")
                    ;;
                *.bz2)
                    echo "Extracting: $entry"
                    bunzip2 -f "$entry"
                    ;;
                *.gz)
                    if [[ "$(file "$entry")" == *"tar archive"* ]]; then
                        echo "Extracting: $entry"
                        rm -rf "$new_dir"
                        new_dir="${entry%.*}"
                        mkdir -p "$new_dir"
                        tar -xzf "$entry" -C "$new_dir" && rm "$entry"
                        queue+=("$new_dir")
                    else
                        gunzip -f "$entry"
                    fi
                    ;;
                *.zip)
                    echo "Extracting: $entry"
                    new_dir="${entry%.*}"
                    rm -rf "$new_dir"
                    mkdir -p "$new_dir"
                    unzip -o "$entry" -d "$new_dir" && rm "$entry"
                    queue+=("$new_dir")
                    ;;
            esac
        done
    done
}




# Call the function with an optional directory argument
extract_and_queue "$(pwd)"

# for file in "$@"; do
#     if [ -f "$file" ]; then
#         # Extract the archive
#         case "$file" in
#             *.tar.gz|*.tgz|*.tar.bz2|*.tbz|*.tar|*.zip|*.gz|*.bz2|*.Z)
#                 handle_archive "$file" "$(pwd)"
#                 ;;
#             *)
#                 if [ "$verbose" = true ]; then
#                     base_name=$(basename "$file")  # Get filename with extension
#                     file_name="${base_name%.*}"    # Remove only last extension (keeps base name)
#                     echo "Ignoring " $file_name
#                 fi
#                 ;;
#         esac
#     fi
# done
echo "Decompressed $counter archive(s)"