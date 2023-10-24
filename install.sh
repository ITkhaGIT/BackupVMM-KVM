#!/bin/bash
PATH=/etc/ITkha


if [ "$(/usr/bin/id -u)" != "0" ]; then
   echo "This script must not be run as root"
   exit 1
fi


echo "copy config file"
/usr/bin/mkdir -p $PATH
/usr/bin/cp -r ./* $PATH


