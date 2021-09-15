#!/bin/bash
set -e

echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $O365_TEST_RECIPIENT_EMAIL_ADDRESS
echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $GOOGLE_TEST_RECIPIENT_EMAIL_ADDRESS
echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $OTHER_TEST_RECIPIENT_EMAIL_ADDRESS

exec "$@"