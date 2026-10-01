#!/bin/bash

# 1. Accept the path to a log file
log_files="$1"

# 2. Check if an argument was provided (-eq 0 means "equal to 0")
if [ $# -eq 0 ]; then
    echo "ERROR: No log file path provided."
    echo "Usage: $0 <path_to_log_file>"
    exit 1
fi

# 3. Check if the file exists (note the space before ']')
if [ ! -f "$log_files" ]; then
    echo "ERROR: File does not exist: $log_files"
    exit 1
fi

# -E : Extended regex (allows '|' for OR operator)
# -i : Case-insensitive match (catches ERROR, error, Failed, failed, etc.)
# -c : Counts and outputs matching LINES directly
# || true : Prevents script exit when 0 matches are found under 'set -e'

error_count=$(grep -Eic 'ERROR|Failed' "$log_files" || true)

echo "Total Error Count: $error_count"
