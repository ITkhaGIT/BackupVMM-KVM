#!/bin/bash
# Set the path for the application
PATHAPP=/etc/ITkha

# Source the configuration file
source "$PATHAPP/config.cfg"

# Log header for the removal of old backups
bash $PATHAPP/scripts/log_monitor.sh -h "Remove old backups"

# Check if the maximum number of backups to retain is greater than or equal to 1
if [ $MAX_COUNT_BACKUPS -ge 1 ]; then
    # Get the list of old backups, sorted by modification time in reverse order
    OLD_BACKUP=$(ls -t -r $BACKUP_DIR | head -n -$MAX_COUNT_BACKUPS)

    # Loop through each old backup directory and remove it
    for OLD_DIR in $OLD_BACKUP; do
        # Remove the old backup directory
        sudo rm -rf $BACKUP_DIR/$OLD_DIR > /dev/null 2>&1

        # Check the exit status of the removal process
        if [ $? -eq 0 ]; then
             bash $PATHAPP/scripts/log_monitor.sh -s "Removed old backup: $OLD_DIR"
        else
             bash $PATHAPP/scripts/log_monitor.sh -e "Old backup not deleted: $OLD_DIR"
        fi
    done
else
     bash $PATHAPP/scripts/log_monitor.sh -i "No old backups to remove. MAX_COUNT_BACKUPS is not greater than or equal to 1."
fi
