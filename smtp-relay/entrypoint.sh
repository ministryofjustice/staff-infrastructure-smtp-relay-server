#!/bin/bash
set -e

if [ -z "$POSTFIX_HOSTNAME" -a -z "$POSTFIX_RELAY_HOST" -a -z "$POSTFIX_RELAY_USER" -a -z "$POSTFIX_RELAY_PASSWORD" ]; then
    echo >&2 'error: relay options are not specified '
    echo >&2 '  You need to specify POSTFIX_HOSTNAME, POSTFIX_RELAY_HOST, POSTFIX_RELAY_USER and POSTFIX_RELAY_PASSWORD (or POSTFIX_RELAY_PASSWORD_FILE)'
    exit 1
fi

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
postconf -e "mydestination="

# Limit message size to 10MB
postconf -e "message_size_limit=10240000"

# Sets smtp tls security needed for gmail


# Reject invalid HELOs
postconf -e "smtpd_delay_reject=yes"
postconf -e "smtpd_helo_required=yes"
postconf -e "smtpd_helo_restrictions=permit_mynetworks,reject_invalid_helo_hostname,permit"

# Don't allow requests from outside
postconf -e "mynetworks=10.0.0.0/8, 90.195.228.241/32"

# Set up hostname
postconf -e myhostname=$POSTFIX_HOSTNAME

# Do not relay mail from untrusted networks
postconf -e "relay_domains="

# Relay configuration
postconf -e relayhost=$POSTFIX_RELAY_HOST
echo "$POSTFIX_RELAY_HOST $POSTFIX_RELAY_USER:$POSTFIX_RELAY_PASSWORD" >> /etc/postfix/sasl_passwd
postmap lmdb:/etc/postfix/sasl_passwd
postconf -e "smtp_sasl_auth_enable=yes"
postconf -e "smtp_sasl_password_maps=lmdb:/etc/postfix/sasl_passwd"
postconf -e "smtp_sasl_security_options=noanonymous"
postconf -e "smtp_tls_security_level=may"
# postconf -e "smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,reject_unverified_recipient"

# Use 587 (submission)
sed -i -r -e 's/^#submission/submission/' /etc/postfix/master.cf

echo
echo 'postfix configured. Ready for start up.'
echo

exec "$@"