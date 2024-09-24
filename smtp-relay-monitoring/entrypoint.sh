#!/bin/bash
set -e

FILE=/var/log/mail/postfix

if [ ! -f "$FILE" ]; then
  mkdir -p "/var/log/mail"
  touch "$FILE"
fi
output_message() {
  while true; do
    echo "Failed to Scrape, this is a test message"
    sleep 300  # Sleep for 5 minutes (300 seconds)
  done
}
output_message &
/bin/postfix_exporter --postfix.logfile_path=$FILE