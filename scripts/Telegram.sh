#!/bin/bash
# Set the path for the application
PATHAPP=/etc/ITkha

# Source the configuration file
source "$PATHAPP/config.cfg"

# Get the message from the command line argument
MESSAGE=$1

# Check if TELEGRAM_BOT_TOKEN is set
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    # Loop through each Telegram user in the TELEGRAM_CHAT_ID array
    for TG_USER in "${TELEGRAM_CHAT_ID[@]}"; do
        # Check if TELEGRAM_ATTACH_LOG_FILE is set to true
        if [ "$TELEGRAM_ATTACH_LOG_FILE" == "true" ]; then
            # Send the log file as a document to Telegram user
            curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" -F "chat_id=$TELEGRAM_CHAT_ID" -F "document=@$LOG_FILE" -F "caption=$MESSAGE" > /dev/null 2>&1
        else
            # Send the message to Telegram user
             curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$MESSAGE" > /dev/null 2>&1

        fi
    done

    # Log success message indicating that the message was sent to Telegram user(s)
    bash $PATHAPP/scripts/log_monitor.sh -s "Message sent to Telegram user(s) $TELEGRAM_CHAT_ID"
fi
