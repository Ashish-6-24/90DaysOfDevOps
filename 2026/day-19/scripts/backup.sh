#!/bin/bash

set -euo pipefail

usage(){
	echo "usage: ./backup.sh <source_directory> <backup_destination>"
	echo "example: ./backup.sh /opt/myapp/data /backup/myapp"
	exit 1
}

if [ "$#" -ne 2 ]; then
	usage
fi

source_dir="$1"
backup_dir="$2"

timestamp=$(date +%Y-%m-%d-%H-%M-%S)
archive_name="backup-$timestamp.tar.gz"
archive_path="$backup_dir/$archive_name"

check_source(){
	if [ ! -d "$source_dir" ]; then
		echo "Error: Source directory $source_dir doesn't exist..."
		exit 1
	fi
}

create_backup_dir(){
	if [ ! -d "$backup_dir" ]; then
		echo "Backup directory doesn't exist. Creating $backup_dir..."
		mkdir -p "$backup_dir"
	fi
}

create_backup(){
	echo "Creating backup..."

	tar -czf "$archive_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

	if [ ! -f "$archive_path" ]; then
		echo "Error: Backup archive was not created..."
		exit 1
	fi
}

show_backup_info(){
	archive_size=$(du -h "$archive_path" | cut -f1)

	echo "Backup created successfully!"
	echo "Archive name : $archive_name"
	echo "Archive size : $archive_size"
	echo "Backup path  : $archive_path"
}

delete_old_backups(){
	find "$backup_dir" -type f -name "backup-*.tar.gz" -mtime +14 -delete
}

check_source
create_backup_dir
create_backup
show_backup_info
delete_old_backups

echo "Old backups older than 14 days have been removed."
