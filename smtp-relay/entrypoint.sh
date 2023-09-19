#!/bin/bash
set -e

# create a HOSTNAME based on the environment
if [ $ENV != "development" ] && [ $ENV != "pre-production" ] && [ $ENV != "production" ];
then
        HOSTNAME="$ENV-smtp-relay"
else
        HOSTNAME="smtp-relay"
fi

# Create postfix folders
mkdir -p /var/spool/postfix/
mkdir -p /var/spool/postfix/pid

# Disable SMTPUTF8, because libraries (ICU) are missing in Alpine
postconf -e "smtputf8_enable = no"

# Log to file. Tail the logs to STDOUT below
postconf -e "maillog_file = /var/log/mail/postfix"

# Update aliases database. It's not used, but postfix complains if the .db file is missing
postalias /etc/postfix/aliases

# All about domains
postconf -e "myhostname = $HOSTNAME.$PUBLIC_DNS_ZONE_NAME_STAFF_SERVICE"
postconf -e "mydomain = $RELAY_DOMAIN"
postconf -e "myorigin = $RELAY_DOMAIN"
postconf -e "relay_domains = $RELAY_DOMAIN"
postconf -e "mydestination = $HOSTNAME.$PUBLIC_DNS_ZONE_NAME_STAFF_SERVICE, $RELAY_DOMAIN"

# Create transport mapping
echo "$RELAY_DOMAIN relay:[$O365_SMART_HOST]" >> /etc/postfix/transport_maps
postmap lmdb:/etc/postfix/transport_maps
postconf -e "transport_maps = lmdb:/etc/postfix/transport_maps"

# Disable local recipients checks
postconf -e "local_recipient_maps ="

# IP ranges that are allowed to relay messages through this server (maintained in AWS SS Parameter Store)
postconf -e "mynetworks = $IP_ALLOWED_LIST"

# All about security
postconf -e "smtpd_delay_reject = yes"
postconf -e "smtpd_helo_required = yes"
postconf -e "smtpd_relay_restrictions = permit_mynetworks, reject"
postconf -e "smtp_sasl_auth_enable = no"
postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
postconf -e "smtp_sasl_security_options = noanonymous"
postconf -e "smtp_use_tls = yes"
postconf -e "smtp_tls_security_level = encrypt"

# Limit message size to ~50MB 
# ExchangeOnline is 35Mb and Google Workspace 50Mb
postconf -e "message_size_limit = 50000000"

# Sender address rewriting
postconf -e "masquerade_domains = $RELAY_DOMAIN"
postconf -e "remote_header_rewrite_domain = $RELAY_DOMAIN"
postconf -e "append_dot_mydomain = yes"

# Create sender canonical address mapping
echo "$HOSTNAME@$PUBLIC_DNS_ZONE_NAME_STAFF_SERVICE $HOSTNAME@$RELAY_DOMAIN" >> /etc/postfix/sender_canonical
echo "$HOSTNAME@ip-10-180-104-23.eu-west-2.compute.internal $HOSTNAME@$RELAY_DOMAIN" >> /etc/postfix/sender_canonical
postmap lmdb:/etc/postfix/sender_canonical
postconf -e "sender_canonical_maps = lmdb:/etc/postfix/sender_canonical"

# Define local mail delivery location
postconf -e "home_mailbox = Maildir/"

echo
echo 'postfix configured. Ready for start up.'
echo

exec "$@"

exec postfix start-fg & sleep 2 # give postfix time to create the newest log
exec tail -f /var/log/mail/postfix
