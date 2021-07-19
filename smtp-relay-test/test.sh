#!/bin/bash
set -e

echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relays Server" -S mta=smtp://smtp_relay_server:587 -S from=$TEST_EMAIL_ADDRESS -S smtp-auth=none $MAILBOX_FOR_TEST_EMAIL

exec "$@"