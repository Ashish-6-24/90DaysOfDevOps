#!/bin/bash
set -euo pipefail
DIR_PATH="/tmp/devops-test"

mkdir "${DIR_PATH}" 2>/dev/null || {
echo "Directory already exists"
}

cd "${DIR_PATH}" || {
echo "Failed to enter directory"
exit 1

}

echo "Creating file..."

touch demo.txt 2>/dev/null || {

echo "Failed to create demo.txt"
exit 1

echo "Script completed successfully"
