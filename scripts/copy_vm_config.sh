#!/bin/bash
# Set the path for the application
PATHAPP=/etc/ITkha/BackupVMM-KVM

# Source the configuration file
source "$PATHAPP/config.cfg"

# Get the virtual machine name and destination path from command line arguments
VM_NAME=$1
DEST_PATH=$2

# Create the destination directory for the virtual machine configuration
sudo mkdir -p $DEST_PATH

# Log information about the start of copying the virtual machine configuration
bash $PATHAPP/scripts/log_monitor.sh -i "Copy config virtual machine $VM_NAME."

# Use virsh to dump the XML configuration of the virtual machine
sudo virsh dumpxml $VM_NAME > "$DEST_PATH/dump-$VM_NAME.xml" 2>&1

# Check the exit status of the previous command
if [ $? -eq 0 ]; then
    # Log success if the configuration is created successfully
    bash $PATHAPP/scripts/log_monitor.sh -s "The configuration for the virtual machine $VM_NAME has been created."
else
    # Log an error if there is an issue creating the configuration
    bash $PATHAPP/scripts/log_monitor.sh -e "The configuration for the virtual machine $VM_NAME has not been created."
fi
