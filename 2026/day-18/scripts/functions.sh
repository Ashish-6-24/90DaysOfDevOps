#!/bin/bash
set -euo pipefail

greet(){
local name="${1:-Guest}"

echo "Hello, ${name}!"

}
add(){
local numi="${1}"
local num2="${2}"
local sum=$((num1 + num2 ))
echo "Sum is: ${sum}"
}

read -rp "Please enter your name:
greet "${user_name}"

user_name

read -rp "Enter two numbers: " a b

if [[ "${a:-}" =~ *-?[0-9]+$ ]] 6& [[ "${b:-}" =~ *-?[0-9]+$ ]]; then
add "${a}" "${b}"
else
echo "Error INvalid input."

exit 1
fi
