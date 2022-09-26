#!/bin/bash
set -e

# echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $O365_TEST_RECIPIENT_EMAIL_ADDRESS
# echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $GOOGLE_TEST_RECIPIENT_EMAIL_ADDRESS
echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://testuser:Password@smtp_relay_server -S from=$TEST_SENDER_EMAIL_ADDRESS $OTHER_TEST_RECIPIENT_EMAIL_ADDRESS
echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://smtp_relay_server -S smtp-auth=CRAM-MD5 -S smtp-auth-user=testuser@postfix.devl.justice.gov.
uk -S smtp-auth-password=Password -S from=testuser@postfix.devl.justice.gov.uk tislam@live.co.uk

exec "$@"