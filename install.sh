#!/bin/bash
# Set the installation path for the application
PATHAPP=/etc/ITkha

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must not be run as root"
   exit 1
fi

# Display a message indicating the start of the installation
echo "Start installation"

# Create the installation directory if it doesn't exist
mkdir -p $PATHAPP

# Copy all files from the current directory to the installation directory
cp -r ./* $PATHAPP

# Execute the backup script located in the installation directory
bash $PATHAPP/backup.sh
