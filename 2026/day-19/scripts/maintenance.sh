#!/bin/bash

set -euo pipefail

LOG_FILE="$HOME/day-19/maintenance.log"

log_rotation(){
	"$HOME/day-19/scripts/log_rotation.sh" \
	"$HOME/day-19/logs" >> "$LOG_FILE" 2>&1
}

backup(){
	"$HOME/day-19/scripts/backup.sh" \
	"$HOME/day-19/practice_sh" \
	"$HOME/day-19/backups" >> "$LOG_FILE" 2>&1
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
