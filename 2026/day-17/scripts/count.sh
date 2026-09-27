#!/bin/bash
set -euo pipefail

Start=1
End=10

for ((i=Start; i <= End; i++)); do
echo "Count: ${i}"
done
