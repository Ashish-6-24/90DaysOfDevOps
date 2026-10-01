#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
echo "Error: No log files path provided."
exit 1
fi

log _file="$1"

if [ ! -f "$log_file"]; then
echo "Error: File doesnot exit: $log file"
exit 1

fi

echo "===Critical Events==="
grep -n "CRITICAL" "$log_file" | while IFS=: read -r line_num log_entry # IFS stands for Internal Field Separator
do

echo "Line $line_num $log_entry"
done
