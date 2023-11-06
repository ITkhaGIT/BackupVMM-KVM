#!/bin/bash

PATHAPP=/etc/ITkha
source $PATHAPP/config.cfg


VMs=""

### Clear LogFile
cp /dev/null $LOG_FILE


START_TIME=$(date +%s)
FINISH_TIME=""
bash $PATHAPP/scripts/log_monitor.sh -h "Backup on host: $(hostname) Date: $(date)"
bash $PATHAPP/scripts/log_monitor.sh -i "The script started at $(date --date=@"$START_TIME")"
### COPY VM
bash $PATHAPP/scripts/log_monitor.sh -i "Copy of $TARGET_VMs virtual machines is selected!"
#getting all the data that will be copied
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
 for VM in $VMs; do
        IS_BACKUP=0
        for VM_EXEPT in ${VM_EXCEPTION[@]}
        do
                if [ "$VM" = "$VM_EXEPT" ]; then
                IS_BACKUP=1
                fi
        done

        if [ "$IS_BACKUP" = 0 ]; then


        else
        bash $PATHAPP/scripts/log_monitor.sh -i "Сopying $VM virtual machine skipped. The virtual machine is in an exception"

        fi


    done




sleep 3
FINISH_TIME=$(date +%s)
bash $PATHAPP/scripts/log_monitor.sh -i "The script finished at $(date --date=@"$FINISH_TIME")"

### INFO  
DURATION=$((FINISH_TIME - START_TIME))
bash $PATHAPP/scripts/log_monitor.sh -h "Information"
bash $PATHAPP/scripts/log_monitor.sh -i "Backup duration: $((DURATION / 60)) minutes $((DURATION % 60)) seconds"

### NOTIFY
bash $PATHAPP/scripts/log_monitor.sh -h "Notification"
bash $PATHAPP/scripts/Telegram.sh  "The backup was created on the host $(hostname)."
