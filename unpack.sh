#!/bin/bash
# Default values
recursive=false
verbose=false
decompressed_counter=0 
failure_counter=0 
queue=()

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
    case "$entry" in
        *.tar.gz|*.tgz)
            new_dir="${entry%.*}"  # Remove .tar.gz
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue+=("$new_dir")
            ;;
        *.tar.bz2)
            new_dir="${entry%.*}"
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            tar -xjf "$entry" -C "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue+=("$new_dir")
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
                [[ "$recursive" == true ]] && queue+=("$new_dir")
            else
                gunzip -f "$entry" > /dev/null 2>&1
            fi
            ;;
        *.zip)
            new_dir="${entry%.*}"
            rm -rf "$new_dir"
            mkdir -p "$new_dir"
            unzip -o "$entry" -d "$new_dir" > /dev/null 2>&1 && rm "$entry"
            [[ "$recursive" == true ]] && queue+=("$new_dir")
            ;;
        *)
            (( failure_counter++ ))
            return
            ;;
    esac
    (( decompressed_counter++ ))
  
}


extract_and_queue() {

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
            
            extract_file "$entry"
            
        done
    done
}


for file in "$@"; do
    if [ -f "$file" ]; then
        extract_file $file
    fi
    
    if [[ -d "$file" ]] && [[ "$recursive" == true ]]; then
        queue+=("$file")
    fi
    
    extract_and_queue

done


echo "Decompressed $decompressed_counter archive(s)"
exit $failure_counter

# TODO : print -v / dont remove archived 