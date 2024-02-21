#!/bin/bash

backup_dirs=("/tmp/" "/tmp/master/")  # Add your specific path to the master folder
backup_prefix="nms-backup"
max_backups=5

for backup_dir in "${backup_dirs[@]}"; do
    # Change to the backup directory
    cd "$backup_dir" || exit 1

    # List all tar.gz files with the specified prefix and sort by creation time
    backup_files=($(ls -tU "$backup_prefix"*.tgz 2>/dev/null))

    # Calculate the number of files exceeding the limit
    exceeding_files=$(( ${#backup_files[@]} - $max_backups ))

    # If there are more than max_backups files, delete the oldest ones
    if [ $exceeding_files -gt 0 ]; then
      echo "Removing $exceeding_files old backups in $backup_dir..."
      for ((i=0; i<$exceeding_files; i++)); do
        rm -f "${backup_files[$i]}"
        echo "Deleted: ${backup_files[$i]}"
      done
    fi
done

#Here the script backups the new backup to the other server in case it was the master.
if ip addr show dev eth0 | grep  10.150.209.138; then
        if [ ${#backup_files[@]} -gt 0 ]; then
          latest_backup="${backup_files[0]}"
          scp "$latest_backup" root@10.150.209.135:/tmp/master/
          echo "Copied $latest_backup to $target_server"
        else
          echo "No backups available for copying."
        fi
else
  echo "this is a backup server"
fi