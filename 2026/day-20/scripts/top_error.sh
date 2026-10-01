#!/bin/bash

log_file="$1"

if [ $# -eq 0 ]; then
    echo "Error: No log file path provided."
    exit 1
fi

if [ ! -f "$log_file" ]; then
    echo "Error: File does not exist: $log_file"
    exit 1
fi

echo "--- Top 5 Error Messages ---"

# 2. sed -E  : Strip off timestamps and prefix up to [ERROR]
# 3. sort : Group identical error messages
# 4. uniq -c : Count occurrences of each unique error message
# 5. sort -rn : Sort numerically in descending order (highest count first)
# 6. head -n 5 : Limit output to top 5 results

grep -i "error" "$log_file" | sort | uniq -c | sort -nr | head -5
