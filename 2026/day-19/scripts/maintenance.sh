#!/bin/bash

set -euo pipefail

LOG_FILE="/home/ubuntu/maintenance.log"

log_rotation(){
	/home/ubuntu/log_rotation.sh \
	/home/ubuntu/app-logs >> "$LOG_FILE" 2>&1
}

backup(){
	/home/ubuntu/backup.sh \
	/home/ubuntu/project \
	/home/ubuntu/backups >> "$LOG_FILE" 2>&1
}

main(){

	echo "" >> "$LOG_FILE"
	echo "$(date) : Starting Maintenance..." >> "$LOG_FILE"

	log_rotation
	backup

	echo "$(date) : Maintenance completed for today" >> "$LOG_FILE"
}

main

echo "Successfully written logs to $LOG_FILE"
