#!/bin/bash
set -euo pipefail 

log_dir="$1"

if [ ! -d "$log_dir" ]; then
    echo "Error: Directory does not exist: $log_dir"
    exit 1
fi

compressed_count=0
deleted_count=0

while IFS= read -r file; do # IFS = Internal Field Separator 
    gzip "$file"
    compressed_count=$((compressed_count + 1))
done < <(find "$log_dir" -type f -name "*.log" -mtime +7) # Compress files older than 7 


while IFS= read -r file; do
    rm "$file"
    deleted_count=$((deleted_count + 1))
done < <(find "$log_dir" -type f -name "*.gz" -mtime +30) # delete .gz files older than 30 daysv

echo "Files compressed: $compressed_count"
echo "Files deleted: $deleted_count"
