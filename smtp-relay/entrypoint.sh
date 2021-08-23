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

# POSTFIX decurity config
postconf -e "smtp_sasl_auth_enable=no"
postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
postconf -e "smtp_sasl_security_options=noanonymous"
postconf -e "smtp_use_tls=yes"
postconf -e "smtp_tls_security_level=encrypt"
postconf -e "smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated"

# Create a transport_maps
echo "/.*@justice.gov.uk*/i relay:$O365_SMART_HOST" >> /etc/postfix/transport_maps
echo "/.*@digital.justice.gov.uk*/i relay:$GOOGLE_SMTP_HOST" >> /etc/postfix/transport_maps
# echo "* relay:$O365_SMART_HOST" >> /etc/postfix/transport_maps
postmap lmdb:/etc/postfix/transport_maps

postconf -e "transport_maps=lmdb:/etc/postfix/transport_maps"

# Use 587 (submission)
sed -i -r -e 's/^#submission/submission/' /etc/postfix/master.cf

echo
echo 'postfix configured. Ready for start up.'
echo

exec "$@"
