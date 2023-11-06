#!/bin/bash
PATHAPP=/etc/ITkha


if [ "$(id -u)" != "0" ]; then
   echo "This script must not be run as root"
   exit 1
fi


echo "Start installation"
mkdir -p $PATHAPP
cp -r ./* $PATHAPP

bash $PATHAPP/backup.sh

