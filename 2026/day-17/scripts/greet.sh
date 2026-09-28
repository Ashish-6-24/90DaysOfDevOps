#!/bin/bash

if [ -z "$1" ]; then
echo "Usage: ./greet.sh <name>"

exit 1
fi

echo "Hello, $1!"
