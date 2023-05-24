#!/bin/bash

# Mitch Test Change
set -e

smtp_relay_client_known_from_range="172.16.0.10"
smtp_relay_client_unknown_from_range="172.16.1.10"

test_o365_relay() {
    echo "Starting o365 relay test "
    echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://$1 -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $O365_TEST_RECIPIENT_EMAIL_ADDRESS
}

test_google_relay(){
    echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://$1 -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $GOOGLE_TEST_RECIPIENT_EMAIL_ADDRESS
}

test_other_relay(){
    echo "This is a Test Email from SMTP Relay Server" | mail -s "Test email from SMTP Relay Server" -S mta=smtp://$1 -S from=$TEST_SENDER_EMAIL_ADDRESS -S smtp-auth=none $OTHER_TEST_RECIPIENT_EMAIL_ADDRESS
}

main() {

    echo "Starting main ..."
    echo $1
    test_o365_relay $1
    test_google_relay $1
    test_other_relay $1
}
main $smtp_relay_client_known_from_range
main $smtp_relay_client_unknown_from_range