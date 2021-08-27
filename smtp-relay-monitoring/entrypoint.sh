#!/bin/bash
set -e

FILE=/var/log/mail/postfix

if [ ! -f "$FILE" ]; then
  mkdir -p "/var/log/mail"
  touch "$FILE"
fi

/bin/postfix_exporter --postfix.logfile_path=$FILE