#!/bin/bash

set -euo pipefail

sys_info() {
	echo "==== Hostname & System Info ===="
	echo "Host_Name : $(hostname)"
	echo "Kernel    : $(uname -r)"
	echo "OS        : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')"
	echo ""
}

sys_uptime() {
	echo "==== System Uptime ===="
	uptime -p
	echo ""
}

disk_usage() {
	echo "==== Disk Usage ===="
	# Print header line once, then sort remaining lines by size (column 2)
	df -h -x tmpfs -x devtmpfs | awk 'NR==1; NR>1 {print $0 | "sort -hr -k2"}' | head -n 6
	echo ""
}

cpu_consuming_processes() {
	echo "==== CPU-Consuming Processes ===="
	ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6
	echo ""
}

main() {
	sys_info
	sys_uptime
	disk_usage
	cpu_consuming_processes
}

main "$@"
