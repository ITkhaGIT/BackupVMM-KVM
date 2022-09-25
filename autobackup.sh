#!/bin/bash

### Setttings
BACKUP_DIR=/mnt/backupvmm
# target vm list (running)
VM_LIST=`virsh list | grep running | awk '{print $2}'`
LOG_FILE=/var/log/autobackup.log
MAX_BACKUP=1

### Other Variable

NORMAL_COLOR='\033[37m'
ERROR_COLOR='\033[0;31m'
INFO_COLOR='\033[0;33m'
SUCCE_COLOR='\033[0;32m'
#BACKUPTIME=`date +"%H_%M_%S-%m_%d_%Y"`
BACKUPTIME=`date +"%m_%d_%Y"`
LOG_LOCAL=false

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
    sudo mkdir -p "$1"
    ShowSuccessful "File $1 created."
 fi
}


# Detect Debian users running the script with "sh" instead of bash
if readlink /proc/$$/exe | grep -q "dash"; then
	ShowError 'This installer needs to be run with "bash", not "sh".'
	exit 1
fi

# Check the script is not being run by root
if [ "$(id -u)" != "0" ]; then
   ShowError "This script must not be run as root"
   exit 1
fi


BackupVM(){

	PATH_VM=$BACKUP_DIR/$BACKUPTIME/$1
        # add vm disk names to array
	IMAGES=$(virsh domblklist "$1" --details | grep vda | awk '{print $4}')

 	CheckFolder "$PATH_VM"
        ShowInfo "Start backup: $1"

### Backup VM config
 	CheckFolder "$PATH_VM/config"
	CheckFile "$PATH_VM/config/dumpxml.xml"
	ShowInfo "Start backup config: ../$1/config/dumpxml.xml"

         sudo virsh dumpxml $1 > $PATH_VM/config/dumpxml.xml 2>&1
	 if [ $? -eq 0 ]
                then
		ShowSuccessful "Backup for virsh dumpxml $1 created"
        else
                ShowError "We were unable to create a backup for virsh dumpxml $1"
        fi

	ShowSuccessful "End backup config: $1"
### Backup snapshot 
	CheckFolder "$PATH_VM/snapshot"
	virsh snapshot-current $1 > /dev/null 2>&1
	if [ $? -eq 0 ]
		then
		#It has snapshot
		echo "It has snapshot"
	else
		ShowInfo "$1 has not snapshot "
	fi
### Backup images
	CheckFolder "$PATH_VM/images"
	ShowInfo "Start backup images $1" 
	sudo cp $IMAGES $PATH_VM/images 2>&1
	if [ $? -eq 0 ]
                then
                ShowSuccessful "End backup images $1"
        else
                ShowError "Error backup images $1"
        fi
	ShowSuccessful "End backup: $1"
}

CheckFile $LOG_FILE
ShowInfo "Start backup of host: $(hostname)"
CheckFolder $BACKUP_DIR
CheckFolder $BACKUP_DIR/$BACKUPTIME

#for VM in $VM_LIST
 # do 
     BackupVM prdfs01
#$VM
  #done








