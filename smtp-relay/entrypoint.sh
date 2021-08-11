#!/bin/bash
set -e

# Create postfix folders
mkdir -p /var/spool/postfix/
mkdir -p /var/spool/postfix/pid

# Disable SMTPUTF8, because libraries (ICU) are missing in Alpine
postconf -e "smtputf8_enable=no"

# Log to stdout
postconf -e "maillog_file=/dev/stdout"

# Update aliases database. It's not used, but postfix complains if the .db file is missing
postalias /etc/postfix/aliases

# Disable local mail delivery
postconf -e "mydestination=localhost"

# Limit message size to 10MB
postconf -e "message_size_limit=10240000"

# Reject invalid HELOs
postconf -e "smtpd_delay_reject=yes"
postconf -e "smtpd_helo_required=yes"
postconf -e "smtpd_helo_restrictions=permit_mynetworks,reject_invalid_helo_hostname,permit"

# Don't allow requests from outside
postconf -e "mynetworks=127.0.0.0/8,10.0.0.0/8,90.195.228.241/32,172.0.0.0/8,10.184.102.0/24"

# Set up hostname
postconf -e myhostname=$RELAY_DOMAIN
postconf -e myorigin=$RELAY_DOMAIN

# Do not relay mail from untrusted networks
postconf -e relay_domains=$RELAY_DOMAIN

# If configuring this relay to relay against Gmail for test purposes, uncomment the next 4 lines and provide the username and password
# echo "$POSTFIX_RELAY_HOST $POSTFIX_RELAY_USER:$POSTFIX_RELAY_PASSWORD" >> /etc/postfix/sasl_passwd
# postmap lmdb:/etc/postfix/sasl_passwd
# postconf -e "smtp_sasl_auth_enable=yes"
# postconf -e "smtp_sasl_password_maps=lmdb:/etc/postfix/sasl_passwd"

# Relay configuration for Office 365
postconf -e "relayhost=$RELAY_SMART_HOST"
postconf -e "smtp_sasl_auth_enable=no"
postconf -e "smtp_sasl_security_options=noanonymous"
postconf -e "smtp_tls_security_level=may"
postconf -e "smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated"

# Use 587 (submission)
sed -i -r -e 's/^#submission/submission/' /etc/postfix/master.cf

echo
echo 'postfix configured. Ready for start up.'
echo

exec "$@"
