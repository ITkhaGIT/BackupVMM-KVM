#!/bin/bash
# Set the path for the application
PATHAPP=/etc/ITkha/BackupVMM-KVM

# Source the configuration file
source "$PATHAPP/config.cfg"

# Wait time in seconds for virtual machine shutdown
WAIT_TIME=10

# Get virtual machine name and destination path from command line arguments
VM_NAME=$1
DEST_PATH=$2

# Function to get the status of the virtual machine
get_vm_status() {
    virsh list --all | grep $VM_NAME | awk '{print $3}'
}

# Get the initial status of the virtual machine
VM_STATUS=$(get_vm_status)
bash $PATHAPP/scripts/log_monitor.sh -i "Virtual machine $VM_NAME is now $(get_vm_status)"

# Log information about starting the copying process
bash $PATHAPP/scripts/log_monitor.sh -i "Start copying $VM_NAME the virtual machine."
bash $PATHAPP/scripts/log_monitor.sh -i "Destination path: $DEST_PATH/$VM_NAME.qcow2"

# Create the destination directory for the virtual machine image
sudo mkdir -p $DEST_PATH

# Try to shutdown the virtual machine
virsh shutdown "$VM_NAME" >/dev/null 2>&1
bash $PATHAPP/scripts/log_monitor.sh -i "Shutdown virtual machine $VM_NAME"
bash $PATHAPP/scripts/log_monitor.sh -i "Please wait..."

# Loop until the virtual machine is shut down or timeout is reached
elapsed_time=0
while [ "$(get_vm_status)" != "shut" ]; do
    sleep 2
    elapsed_time=$((elapsed_time + 1))

    # Check if the waiting time has exceeded the specified limit
    if [ $elapsed_time -ge $WAIT_TIME ]; then
        bash $PATHAPP/scripts/log_monitor.sh -i "Timeout exceeded. Forced shutdown of the virtual machine."
        virsh destroy $VM_NAME >/dev/null 2>&1
        break
    fi
done

# Copy virtual machine image if it is offline
bash $PATHAPP/scripts/log_monitor.sh -s "Virtual machine $VM_NAME is offline"

# Get the names of virtual machine disks and copy them to the destination path
IMAGES=$(virsh domblklist "$VM_NAME" --details | grep file | awk '{print $4}')
bash $PATHAPP/scripts/log_monitor.sh -i "Copying image virtual machine $VM_NAME"
bash $PATHAPP/scripts/log_monitor.sh -i "Please wait..."
sudo cp "$IMAGES" "$DEST_PATH/$VM_NAME.qcow2" >/dev/null 2>&1

# Start the virtual machine if it was running before the copy process
if [ "$VM_STATUS" = "running" ]; then
    virsh start "$VM_NAME" >/dev/null 2>&1
    bash $PATHAPP/scripts/log_monitor.sh -s "Virtual machine $VM_NAME was enabled"
else
    bash $PATHAPP/scripts/log_monitor.sh -s "Virtual machine $VM_NAME has been shut down"
fi

# Log completion of the virtual machine copy process
bash $PATHAPP/scripts/log_monitor.sh -s "Virtual machine copy $VM_NAME completed!"
