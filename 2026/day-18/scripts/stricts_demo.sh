#!/usr/bin/env bash

# Enable Strict Mode
set -euo pipefail

echo "=========================================="
echo " 1. DEMONSTRATING 'set -u' (Unbound Var)"
echo "=========================================="
# Trying to print a variable that was never declared
# set -u will cause the script to crash immediately here!
echo "Database URL is: ${DATABASE_URL}"

echo "=========================================="
echo " 2. DEMONSTRATING 'set -e' (Exit on Error)"
echo "=========================================="
# Running a command that fails (returns exit code != 0)
# set -e will halt execution before reaching the next echo
ls /path/to/nonexistent_directory

echo "This message will never print under set -e"

echo "=========================================="
echo " 3. DEMONSTRATING 'set -o pipefail'"
echo "=========================================="
# In standard Bash, piping a failing command into a succeeding one hides the failure.
# set -o pipefail ensures the entire pipeline fails if ANY command fails!
cat /nonexistent/file.txt | grep "error"

echo "Script reached the end successfully."
