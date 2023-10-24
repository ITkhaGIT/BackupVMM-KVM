#!/bin/bash
PATH_APP=/etc/ITkha
source "$PATH_APP/config.cfg"

MESSAGE=$1

if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
#curl "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage?chat_id=$TELEGRAM_CHAT_ID&text=$MESSAGE"  > /dev/null 2>&1

 for TG_USER in ${TELEGRAM_CHAT_ID[@]}
        do
    if [ "$TELEGRAM_ATTACH_LOG_FILE" == "true" ]; then
        curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendDocument" -F "chat_id=$TELEGRAM_CHAT_ID" -F "document=@$LOG_FILE" -F "caption=$MESSAGE" > /dev/null 2>&1

    else
        curl -s "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$MESSAGE" > /dev/null 2>&1

    fi
done


bash $PATH_APP/scripts/log_monitor.sh -s "Message sent to telegram user $TELEGRAM_CHAT_ID"
fi
