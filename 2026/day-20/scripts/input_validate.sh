eee
#!/bin/bash

set -euo pipefail

# Step 1: Check if an argument was passed.
# $# holds the number of positional arguments.

if [ "$#" -eq 0 ]; then
echo "ERROR: No file provided"
exit 1
fi

log_file=$1

# Step 2: Check if the specified path actually points to an existing regular file.
# -f checks if the path exists AND is a regular file.

if [ ! -f "$log_file"]; then
echo "ERROR: $log_file doesnot exit or is not a regular file."
exit 1
fi
echo "Log file found $log_file "
