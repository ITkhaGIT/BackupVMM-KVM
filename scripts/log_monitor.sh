#!/bin/bash
# Set the path for the application
PATHAPP="/etc/ITkha"

# Source the configuration file
source "$PATHAPP/config.cfg"

# Function to print a colored message based on the message type
print_colored_message() {
    local type=$1
    local message=$2

    case "$type" in
        "ERROR")
            echo -e "[ \e[31m\u2717\e[0m ] \t - $(date +%T) - $message"  # Red color
            ;;
        "OK")
            echo -e "[ \e[32m\u2713\e[0m ] \t - $(date +%T) - $message"  # Green color
            ;;
        "INFO")
            echo -e "[ \e[34mi\e[0m ] \t - $(date +%T) - $message"  # Blue color
            ;;
        "HEADER")
            echo -e "-----{ $message }-----"
            ;;
        *)
            echo "$message"  # Default without color change
            ;;
    esac

    # Save the notification in the log file
    save_in_file "$type" "$notification_text"
}

# Function to save the notification in the log file
save_in_file() {
    local type=$1
    local message=$2

    # Save the notification in the log file
    echo -e "[ $type ] \t - $(date +%T) - $message" >> "$LOG_FILE"
}

# Accept command line arguments: notification type and notification text
notification_type=$1
notification_text=$2

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case $notification_type in
    -e|--error)
      print_colored_message "ERROR" "$notification_text"
      shift 2
      ;;
    -s|--success)
      print_colored_message "OK" "$notification_text"
      shift 2
      ;;
    -i|--info)
      print_colored_message "INFO" "$notification_text"
      shift 2
      ;;
    -h|--header)
      print_colored_message "HEADER" "$notification_text"
      shift 2
      ;;
    *)
      exit 1
      ;;
  esac
done
