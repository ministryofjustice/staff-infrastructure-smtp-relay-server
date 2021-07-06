#!/bin/bash
set -e

echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relays Server" -S mta=smtp://smtp_relay_server:587 -Ssmtp-auth=none postfix-test-user@devl.justice.gov.uk

exec "$@"