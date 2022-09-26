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
mkdir -p /var/spool/postfix/vhosts

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

postconf -e "home_mailbox = Maildir/"
postconf -e "mail_spool_directory = /var/spool/postfix"
postconf -e "smtpd_banner = $myhostname ESMTP $mail_name ($mail_version)"

postconf -e "local_transport = virtual"
postconf -e "virtual_mailbox_domains = postfix.devl.justice.gov.uk"
postconf -e "virtual_mailbox_base = /var/spool/postfix/vhosts"
postconf -e "virtual_mailbox_maps = lmdb:/etc/postfix/vmailbox"
postconf -e "virtual_minimum_uid = 100"
postconf -e "virtual_uid_maps = static:1001"
postconf -e "virtual_gid_maps = static:1001"
postconf -e "virtual_alias_maps = lmdb:/etc/postfix/valias"

# Create transport mapping
echo "$RELAY_DOMAIN relay:[$O365_SMART_HOST]" > /etc/postfix/transport_maps
postmap lmdb:/etc/postfix/transport_maps
postconf -e "transport_maps = lmdb:/etc/postfix/transport_maps"

# Disable local recipients checks
postconf -e "local_recipient_maps ="

# IP ranges that are allowed to relay messages through this server
#  13.40.249.195/32 AWS NOC
postconf -e "mynetworks = $IP_ALLOWED_LIST"

# All about security
postconf -e "smtpd_delay_reject = yes"
postconf -e "smtpd_helo_required = yes"
postconf -e "smtpd_sasl_auth_enable = yes"
postconf -e "broken_sasl_auth_clients = yes"
postconf -e "smtpd_sasl_path = smtpd"
# postconf -e "smtpd_helo_restrictions = permit_mynetworks, permit"
postconf -e "smtpd_relay_restrictions = permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination, reject"
postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
postconf -e "smtpd_sasl_security_options = noanonymous, noplaintext"
postconf -e "smtpd_sasl_tls_security_options = noanonymous"
postconf -e "smtp_use_tls = yes"
postconf -e "smtp_tls_security_level = encrypt"

# Create valias mapping
echo "testuser@postfix.devl.justice.gov.uk testuser@postfix.devl.justice.gov.uk" > /etc/postfix/valias
postmap lmdb:/etc/postfix/valias

# Create vmailbox mapping
echo "testuser@postfix.devl.justice.gov.uk postfix.devl.justice.gov.uk/testuser/" > /etc/postfix/vmailbox
postmap lmdb:/etc/postfix/vmailbox

postmap lmdb:/etc/postfix/aliases

# Limit message size to ~50MB 
# ExchangeOnline is 35Mb and Google Workspace 50Mb
postconf -e "message_size_limit = 50000000"

# Sender address rewriting
postconf -e "masquerade_domains = $RELAY_DOMAIN"
postconf -e "remote_header_rewrite_domain = $RELAY_DOMAIN"
postconf -e "append_dot_mydomain = yes"

# Create sender canonical address mapping
echo "$HOSTNAME@$PUBLIC_DNS_ZONE_NAME_STAFF_SERVICE $HOSTNAME@$RELAY_DOMAIN" > /etc/postfix/sender_canonical
postmap lmdb:/etc/postfix/sender_canonical
postconf -e "sender_canonical_maps = lmdb:/etc/postfix/sender_canonical"

# Define local mail delivery location
postconf -e "home_mailbox = Maildir/"

echo
echo 'postfix configured. Ready for start up.'
echo

exec "$@"

exec /usr/sbin/saslauthd -a sasldb -c -d & sleep 2
exec postfix start-fg & sleep 2 # give postfix time to create the newest log
exec tail -f /var/log/mail/postfix
