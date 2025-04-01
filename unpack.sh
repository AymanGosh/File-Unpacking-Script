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
    msg="Unpacking $entry"
    
    case "$entry" in
        *.tar.gz|*.tgz)
            new_dir="${entry%.*}"  # Remove .tar.gz
            mkdir -p "$new_dir"
            tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1
            [[ "$recursive" == true ]] && queue+=("$new_dir")
            ;;
        *.tar.bz2)
            new_dir="${entry%.*}"
            mkdir -p "$new_dir"
            tar -xjf "$entry" -C "$new_dir" > /dev/null 2>&1
            [[ "$recursive" == true ]] && queue+=("$new_dir")
            ;;
        *.bz2)
            if [[ "$(file "$entry")" == *"tar archive"* ]]; then
                new_dir="${entry%.*}"
                mkdir -p "$new_dir"
                tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1
                [[ "$recursive" == true ]] && queue+=("$new_dir")
            else
                bunzip2 -kf "$entry" > /dev/null 2>&1
            fi
            ;;
        *.gz)
            if [[ "$(file "$entry")" == *"tar archive"* ]]; then
                new_dir="${entry%.*}"
                mkdir -p "$new_dir"
                tar -xzf "$entry" -C "$new_dir" > /dev/null 2>&1
                [[ "$recursive" == true ]] && queue+=("$new_dir")
            else
                gunzip -kf "$entry" > /dev/null 2>&1
            fi
            ;;
        *.zip)
            new_dir="${entry%.*}"
            if [[ -e "$new_dir" ]]; then
                rm -rf "$new_dir" 
            fi
            mkdir -p "$new_dir"
            unzip -o "$entry" -d "$new_dir" > /dev/null 2>&1
            [[ "$recursive" == true ]] && queue+=("$new_dir")
            ;;
        *)
            [[ "$verbose" == true ]] && echo "Ignoring $entry"
            (( failure_counter++ ))
            return
            ;;
    esac
    [[ "$verbose" == true ]] && echo $msg
    (( decompressed_counter++ ))
}


bfs_extract_and_queue() {
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
    
    # Use find to search for both files and directories with the given name and any extension for files
    results=($(find . -name "$file*" ))
    
    for result in "${results[@]}"; do
        
        file=${result#./}
        if [ -f "$file" ]; then
        extract_file $file
        fi
        
        if [[ -d "$file" ]] && [[ "$recursive" == true ]]; then
            queue+=("$file")
        fi
        
        bfs_extract_and_queue

    done
done

echo "Decompressed $decompressed_counter archive(s)"
exit $failure_counter