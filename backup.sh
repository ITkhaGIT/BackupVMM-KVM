#!/bin/bash
PATHAPP=/etc/ITkha

source $PATHAPP/config.cfg


START_TIME=$(date +%s)
FINISH_TIME=""
bash $PATHAPP/scripts/log_monitor.sh -h "Backup on host: $(hostname) Date: $(date)"
bash $PATHAPP/scripts/log_monitor.sh -i "The script started at $(date --date=@"$START_TIME")"




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
