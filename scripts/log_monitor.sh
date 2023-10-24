#!/bin/bash
source "/etc/ITkha/config.cfg"

# Функция для отображения сообщения заданного цвета
print_colored_message() {
    local type=$1
    local message=$2


    case "$type" in
        "ERROR")
            echo -e "[ \e[31m$type\e[0m ] \t - $(date +%T) - $message"  # Красный цвет

            ;;
        "OK")
            echo -e "[  \e[32m$type\e[0m  ] \t - $(date +%T) - $message"  # Зеленый цвет

            ;;
        "INFO")
            echo -e "[ \e[33m$type\e[0m ] \t - $(date +%T) - $message"  # Желтый цвет

            ;;
        "HEADER")
            echo -e "-----{ $message }-----"

            ;;

        *)
            echo "$message"  # По умолчанию без изменения цвета
            ;;
    esac

save_in_file  "$type" "$notification_text"

}
save_in_file() {
    local type=$1
    local message=$2

    # Сохраняем уведомление в файл
    echo -e "[ $type ] \t - $(date +%T) - $message" >> "$LOG_FILE"

}
# Принимаем аргументы: тип уведомления и текст уведомления
notification_type=$1
notification_text=$2

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

