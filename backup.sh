#!/bin/bash
# Set the path for the application configuration
PATHAPP=/etc/ITkha
# Source the configuration file
source $PATHAPP/config.cfg

# Initialize an empty string for virtual machines
VMs=""

# Clear the log file
cp /dev/null $LOG_FILE

# Record the start time of the script
START_TIME=$(date +%s)
FINISH_TIME=""

# Log script start information
bash $PATHAPP/scripts/log_monitor.sh -h "Backup on host: $(hostname) Date: $(date)"
bash $PATHAPP/scripts/log_monitor.sh -i "The script started at $(date --date=@"$START_TIME")"

# Select virtual machines based on specified criteria
bash $PATHAPP/scripts/log_monitor.sh -i "Copy of $TARGET_VMs virtual machines is selected!"
case "$TARGET_VMs" in
  "all")
    VMs=$(virsh list --all --name)
    ;;
  "running")
    VMs=$(virsh list --state-running --name)
    ;;
  *)
    VMs=$(virsh list --all --name)
    ;;
esac

# Iterate through selected virtual machines and perform backup
 for VM in $VMs; do
        IS_BACKUP=0

        # Check if the virtual machine is in the exception list
        for VM_EXEPT in ${VM_EXCEPTION[@]}
        do
                if [ "$VM" = "$VM_EXEPT" ]; then
                IS_BACKUP=1
                fi
        done

        # If the virtual machine is not in the exception list, perform backup
        if [ "$IS_BACKUP" = 0 ]; then

        # Copy virtual machine images and configuration to backup directory
        bash $PATHAPP/scripts/copy_vm_images.sh $VM  $BACKUP_DIR$(date -d "@$START_TIME" +"%d.%m.%Y-%H:%M:%S")/$VM/Images
        bash $PATHAPP/scripts/copy_vm_config.sh $VM  $BACKUP_DIR$(date -d "@$START_TIME" +"%d.%m.%Y-%H:%M:%S")/$VM/Config
        else

        # Log that the virtual machine backup is skipped due to being in the exception list
        bash $PATHAPP/scripts/log_monitor.sh -i "Сopying $VM virtual machine skipped. The virtual machine is in an exception"

        fi

    done

# Record the finish time of the script
FINISH_TIME=$(date +%s)
bash $PATHAPP/scripts/log_monitor.sh -i "The script finished at $(date --date=@"$FINISH_TIME")"

# Remove old backups
bash $PATHAPP/scripts/remove_old_backup.sh

# Display information about current backups
bash $PATHAPP/scripts/show_current_backup.sh


# Calculate the duration of the backup
DURATION=$((FINISH_TIME - START_TIME))

# Log backup duration information
bash $PATHAPP/scripts/log_monitor.sh -h "Information"
bash $PATHAPP/scripts/log_monitor.sh -i "Backup duration: $((DURATION / 60)) minutes $((DURATION % 60)) seconds"

# Log notification information
bash $PATHAPP/scripts/log_monitor.sh -h "Notification"

# Use Telegram script to send a notification about the backup creation
bash $PATHAPP/scripts/Telegram.sh  "The backup was created on the host $(hostname)."
