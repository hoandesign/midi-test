#!/bin/bash

# Navigate to the directory containing the script
cd "$(dirname "$0")"

# Create a temporary directory for case-insensitive operations
TEMP_DIR=$(mktemp -d)

# Function to cleanup on exit
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Find all .mid and .midi files and process them
find . -type f \( -iname "*.mid" -o -iname "*.midi" \) | while read -r file; do
    # Get the directory and filename
    dir=$(dirname "$file")
    filename=$(basename "$file")
    
    # Create a temporary lowercase copy for comparison
    temp_file="$TEMP_DIR/$(echo "$filename" | tr '[:upper:]' '[:lower:]')"
    
    # Convert to lowercase, replace spaces and special chars with hyphens
    newname=$(echo "$filename" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-' | tr -cd '[:alnum:]-_.' | sed 's/-\./\./g' | sed 's/--*/-/g')
    
    # Only rename if the new name is different (case-insensitive check)
    if [ "$(echo "$filename" | tr '[:upper:]' '[:lower:]')" != "$(echo "$newname" | tr '[:upper:]' '[:lower:]')" ]; then
        echo "Renaming: $filename -> $newname"
        # First move to a temporary name to handle case-sensitivity issues
        temp_name="$file.temp_rename_$(date +%s%N)"
        mv -n "$file" "$temp_name"
        # Then move to final name
        mv -n "$temp_name" "$dir/$newname"
    fi
done

echo "All MIDI files have been renamed!"

# Final list of all MIDI files
echo -e "\nCurrent MIDI files:"
find . -type f \( -iname "*.mid" -o -iname "*.midi" \) -exec basename {} \;
