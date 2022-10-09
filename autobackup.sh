#!/bin/bash

### Setttings
BACKUP_DIR=/mnt/backup1
LOG_FILE=/var/log/autobackup.log
MAX_BACKUP=1
#VM_EXCEPTION=(domain1 domain2 domain3 domainN)
VM_EXCEPTION=()

### Other Variable

NORMAL_COLOR='\033[37m'
ERROR_COLOR='\033[0;31m'
INFO_COLOR='\033[0;33m'
SUCCE_COLOR='\033[0;32m'
BACKUPTIME=`date +"%m_%d_%Y"`
LOG_LOCAL=false
ERROR=0
### Notification
# Telegram
TG_ENABLED=true
TG_BOT_TOKEN=2006604850:AAFg496KSncZm4R0_TCYTvs9XW3NBPrAAXw
TG_CHAT_ID=-1001860620931
TG_MESSAGE="The backup was created on the host $(hostname). Error: %%ERROR%%"
TG_ATTACH_LOG=true


### Don't Change
# target vm list (running)
VM_LIST=`virsh list | grep running | awk '{print $2}'`
PATH_VM=null
IMAGES=null
ShowError() {
   echo -e "[ ${ERROR_COLOR}Error${NORMAL_COLOR} ] \t - $(date +%T) - $1"
   echo -e "[ Error ] - $(date +%T) - $1" >> $LOG_FILE
   ((ERROR++))
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

DeleteOldBackupVM(){
	ShowInfo "=============REMOVE OLD BACKUP============="
	OLD_BACKUP=$(ls -t -r $BACKUP_DIR | head -n -$MAX_BACKUP)
	for OLD_DIR in $OLD_BACKUP
	do
		sudo rm -rf $BACKUP_DIR/$OLD_DIR > /dev/null 2>&1
	        if [ $? -eq 0 ]
        	then
			ShowSuccessful "Removed old backup: $OLD_DIR"
		        else
	                ShowError "Old backup not deleted: $OLD_DIR"
        	fi

  	done

}
BackupVMConfig(){
        ShowInfo "Start backup: $1"
        CheckFolder "$PATH_VM"
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
}
BackupVMImage(){
### Backup images
        ShowInfo "Start backup images $1"
        CheckFolder "$PATH_VM/images"
#######
	ShowInfo "Copying image $1..."
        # add vm disk names to array
	IMAGES=$(virsh domblklist "$1" --details | grep file | awk '{print $4}')
	sudo cp $IMAGES $PATH_VM/images >/dev/null 2>&1
#######
        if [ $? -eq 0 ]
                then
                ShowSuccessful "End backup images $1"
        else
		ShowInfo "VM $1 is being shutdown"
		sudo virsh destroy $1 >/dev/null 2>&1
		ShowInfo "Waiting for shutdown $1"
echo "$IMAGES - $PATH_VM/images"
		sleep 10
			sudo cp $IMAGES $PATH_VM/images >/dev/null 2>&1
			#######
		        if [ $? -eq 0 ]
                		then
		                ShowSuccessful "End backup images $1"
				sudo virsh start $1  >/dev/null 2>&1
				ShowInfo "VM $1 started"

        		else
				ShowError "Error backup images $1"
			fi

        fi
        ShowSuccessful "End backup: $1"
}

BackupVM(){

	PATH_VM=$BACKUP_DIR/$BACKUPTIME/$1

	BackupVMConfig $1
	BackupVMImage $1
}

NotifyOnTG(){
ShowInfo "Sending log to: $TG_CHAT_ID"
MESSAGE=$(echo $TG_MESSAGE | sed 's/ /%20/g' | sed "s/%%ERROR%%/$ERROR/g" )
curl "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=$TG_CHAT_ID&text=$MESSAGE" > /dev/null 2>&1
if [ "$TG_ATTACH_LOG" = "true" ]; then

ShowInfo "Attach log file: $LOG_FILE"
curl "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument?chat_id=$TG_CHAT_ID" -F document=@$LOG_FILE > /dev/null 2>&1
fi

}


CheckFile $LOG_FILE
sudo cp /dev/null $LOG_FILE
ShowInfo "Made by Nikitin Roman <Roman.Nikitin@itkha.com>"
ShowInfo "Start backup of host: $(hostname)"
CheckFolder $BACKUP_DIR
CheckFolder $BACKUP_DIR/$BACKUPTIME
ERROR=0
for VM in $VM_LIST
do
IS_BACKUP=0
	for VM_EXEPT in ${VM_EXCEPTION[@]}
	do
		if [ "$VM" = "$VM_EXEPT" ]; then
		IS_BACKUP=1
		fi
	done

	if [ "$IS_BACKUP" = 0 ]; then
	BackupVM $VM
	else
	ShowInfo "Skipped. $VM add to list Exeption"
	fi
done
DeleteOldBackupVM

ShowInfo "=============Notification============="
if [ "$TG_ENABLED" = "true" ]; then
	NotifyOnTG
fi
