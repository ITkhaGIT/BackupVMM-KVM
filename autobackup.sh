#!/bin/bash

### Setttings
BACKUP_DIR=/mnt/backupvmm
# target vm list (running)
VM_LIST=`virsh list | grep running | awk '{print $2}'`
LOG_FILE=/var/log/autobackup.log


### Other Variable

NORMAL_COLOR='\033[37m'
ERROR_COLOR='\033[0;31m'
INFO_COLOR='\033[0;33m'
SUCCE_COLOR='\033[0;32m'
BACKUPTIME=`date +"%H_%M_%S-%m_%d_%Y"`

ShowError() {
   echo -e "[ ${ERROR_COLOR}Error${NORMAL_COLOR} ] \t - $(date +%T) - $1"
   echo -e "[ Error ] - $(date +%T) - $1" >> $LOG_FILE
}
ShowSuccessful(){

    echo -e "[ ${SUCCE_COLOR}Ok${NORMAL_COLOR} ] \t\t - $(date +%T) - $1"
    echo -e "[ Ok ] - $(date +%T) - $1" >> $LOG_FILE
}
ShowInfo() {
   echo -e "[ ${INFO_COLOR}Info${NORMAL_COLOR} ] \t - $(date +%T) - $1"
   echo -e "[ Info ] - $(date +%T) - $1" >> $LOG_FILE

}

CheckFile() {
if [ ! -f "$1" ]; then
    sudo touch "$1"
    ShowSuccessful "File $1 created."
 fi
}

CheckFolder() {
if [ ! -d "$1" ]; then
    sudo mkdir  "$1"
    ShowSuccessful "File $1 created."
 fi
}


# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	ShowError 'This installer needs to be run with "bash", not "sh".'
	exit
fi

# Check the script is not being run by root
if [ "$(id -u)" != "0" ]; then
   ShowError "This script must not be run as root"
   exit 1
fi

CheckFile $LOG_FILE
ShowInfo "Start backup of host: $(hostname)"
CheckFolder $BACKUP_DIR
CheckFolder $BACKUP_DIR/$BACKUPTIME

for $VM in $VM_LIST
  do 
    ShowInfo $VM
  done








