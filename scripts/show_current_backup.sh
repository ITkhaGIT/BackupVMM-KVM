#!/bin/bash
# Set the path for the application
PATHAPP=/etc/ITkha

# Source the configuration file
source $PATHAPP/config.cfg

# Log header for the backup section
bash $PATHAPP/scripts/log_monitor.sh -h "Backups"

# Log information about current backups
bash $PATHAPP/scripts/log_monitor.sh -i "Current backups:"

# Get the list of current backup directories, sorted by modification time in reverse order
CURRENT_BACKUP_DIR=$(ls -t -r $BACKUP_DIR)

# Loop through each current backup directory and log its path
for CURRENT_BACKUP in $CURRENT_BACKUP_DIR; do
    bash $PATHAPP/scripts/log_monitor.sh -s "$BACKUP_DIR$CURRENT_BACKUP"
done
