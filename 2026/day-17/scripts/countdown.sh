#!/bin/bash
read -p "Enter the number: " num

while ["$num" -ge @ ]; do
echo "$num"
num=$((num -1 ))
done
echo "Done!"
