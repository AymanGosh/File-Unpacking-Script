#!/bin/bash
# Default values
recursive=false
verbose=false
decompressed_counter=0 
failure_counter=0 

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


extract_file() {
    
    local entry="$1"
    local -n queue_ref="$2"  # Use a reference to the queue passed from the main function
    case "$entry" in
        *.tar.gz|*.tgz)
            new_dir="${entry%.*}"  # Remove .tar.gz
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue_ref+=("$new_dir")
            ;;
        *.tar.bz2)
            new_dir="${entry%.*}"
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            tar -xjf "$entry" -C "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue_ref+=("$new_dir")
            ;;
        *.bz2)
            bunzip2 -f "$entry" > /dev/null 2>&1
            ;;
        *.gz)
            if [[ "$(file "$entry")" == *"tar archive"* ]]; then
                rm -rf "$new_dir"
                new_dir="${entry%.*}"
                mkdir -p "$new_dir"
                tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1 && rm "$entry"
                [[ "$recursive" == true ]] && queue_ref+=("$new_dir")
            else
                gunzip -f "$entry" > /dev/null 2>&1
            fi
            ;;
        *.zip)
            new_dir="${entry%.*}"
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            unzip -o "$entry" -d "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue_ref+=("$new_dir")
            ;;
        *)
            (( failure_counter++ ))
            return
            ;;
    esac
    (( decompressed_counter++ ))
}


extract_and_queue() {
    local queue="$1"


    while [[ ${#queue[@]} -gt 0 ]]; do
        current_dir="${queue[0]}"
        queue=("${queue[@]:1}")  # Remove first element

        # Loop through files in the directory
        for entry in "$current_dir"/*; do
            [[ -e "$entry" ]] || continue  # Skip if no files exist

            # Check if it's a directory and add it to the queue
            if [[ -d "$entry" ]]; then
                [[ "$recursive" == true ]] && queue+=("$entry")
                continue  # Skip extraction, process next entry
            fi
            
            extract_file "$entry" queue
            
        done
    done
}




extract_and_queue "$(pwd)"

# queue=()
# extract_file "$(pwd)"/develeap-bash.zip queue

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
echo "Decompressed $decompressed_counter archive(s)"


exit $failure_counter