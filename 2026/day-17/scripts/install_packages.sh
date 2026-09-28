#!/bin/bash
set -euo pipefail

packages=("nginx" "curl" "wget")
if [ "$(id -u)" -ne @ ]; then

echo 'Error! This script must be run as root user. Please try sudo ./install_packages'
exit 1
 
fi

for pkg in "${packages[@]}"; do

if dpkg-query -w -f='${Status}' "${pkg}" 2>/dev/null | grep -q "ok installed"; then
echo "Skip ${pkg} is already installed"
else

echo "Install ${pkg} is missing. Installing..."

apt-get update
apt-get install -y "${pkg}"
echo "Success ${pkg} installed successfully"
fi
done
